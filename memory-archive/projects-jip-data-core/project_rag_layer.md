---
name: RAG layer — pgvector + local embedder + semantic search
description: Goldilocks qualitative content now has a full RAG pipeline: fastembed bge-small-en-v1.5 (384 dim, local, free) → pgvector HNSW → /observatory/search. Built 2026-04-13.
type: project
originSessionId: 2f310c99-51f6-4ae3-91ae-f37729895270
---
## Architecture

```
de_qual_documents.raw_text           de_qual_extracts.view_text
          │                                    │
          ▼                                    ▼
   fastembed(bge-small-en-v1.5)       fastembed(bge-small-en-v1.5)
   (local, ONNX, 384 dim)              (local, ONNX, 384 dim)
          │                                    │
          ▼                                    ▼
   de_qual_documents.embedding     de_qual_extracts.embedding
   (vector(384), HNSW cosine)      (vector(384), HNSW cosine)
          │                                    │
          └──────────┬─────────────────────────┘
                     ▼
       GET /api/v1/observatory/search?q=...&k=...&table=extracts|documents|both
```

## Key decisions

- **Model**: `BAAI/bge-small-en-v1.5` — top of MTEB for small models,
  384 dim, ~130MB ONNX weights. Accessed via `fastembed` (qdrant's
  ONNX-based library — no PyTorch, no GPU, works on CPU in ~50ms/text
  on t3.large). Chose this over:
  - OpenAI `text-embedding-3-small` (1536) — needs paid API key,
    user placeholder was `your-ope...`
  - sentence-transformers + torch — ~500MB install footprint
  - Groq — doesn't offer embedding models
- **Dimension**: migrated columns from `vector(1536)` to `vector(384)`
  via alembic `006_embedding_384_and_hnsw.py`. Safe at migration time
  because both columns were empty (NULL for all 500 rows). Downgrade
  path restores 1536 if we ever want to switch to an OpenAI-class model.
- **Index**: HNSW with `m=16, ef_construction=64`, `vector_cosine_ops`.
  Default pgvector params — good balance of build time and recall for
  sub-1M-row tables.

## Files

**app/pipelines/qualitative/local_embedder.py** — lazy singleton model
load (first call downloads ~130MB of ONNX weights into
`~/.cache/fastembed`, ~10-30s; subsequent calls instant). Exposes:
- `embed_texts(list[str]) → list[list[float]]` — batched
- `to_pgvector_literal(list[float]) → str` — `'[0.1,0.2,...]'` format
  that psycopg2 binds as a text parameter and SQL casts to
  `::vector(384)`
- `MAX_CHARS = 2000` — input truncation since bge has a 512-token
  window (~2000 chars at English averages)

**scripts/ingest/embed_qual_content.py** — idempotent backfill. SELECTs
rows where `embedding IS NULL`, batches through the model, UPDATEs the
row. Safe to re-run — only touches missing ones. `--table`,
`--batch-size`, `--max-rows` flags. Takes ~70s for 493 rows on t3.large.

**scripts/ingest/run_goldilocks_extraction.py** — the LLM extraction
script now embeds inline. After every doc transitions to 'done', the
new `_embed_doc_and_extracts()` helper embeds the document itself
(title + first 3000 chars) plus any newly-inserted qual_extracts rows
for that document, in the same DB transaction. Embedding failures are
logged and swallowed; the backfill script picks up any gaps.

**app/api/v1/observatory.py** — new `GET /api/v1/observatory/search`
endpoint. Params: `q` (required), `k` (1-50), `table`
(`extracts|documents|both`). Embeds the query via local_embedder,
queries via the HNSW index with `embedding <=> (:qv)::vector`
(cosine distance), returns rows with `1 - distance` as similarity.
Errors from the embedder (model not installed, etc.) return
`{"error": "embedder unavailable: ...", "results": []}` gracefully.

## Live state

- **493 rows embedded** (180 docs + 313 extracts) at first backfill,
  climbing as new extractions happen.
- **HNSW indexes** `ix_de_qual_documents_embedding`,
  `ix_de_qual_extracts_embedding` both built.
- **Search quality** (session verification):
  - `"nifty bearish breakdown"` → "Nifty is in a downward trend...
    no bottoming signs" (0.81)
  - `"buy call on banking sector"` → banking sector views with
    direction tags (0.75-0.78)
  - `"inflation RBI interest rate"` → "India bonds trim losses as
    soft CPI spurs value buying" (0.74)
  - `"Gautam Shah market view March 2026"` → con-call doc as top
    match (0.69) + tactical views (Silver buy 60-65, Gold buy dips)
- **Inline embedding verified** — the `onnxruntime` log line appears
  after every run_goldilocks_extraction "General views: N extracted"
  entry, confirming the inline path runs.

## How to apply

- **Never re-add the OPENAI_API_KEY branch** to the embedder. User
  wants free local. If quality needs to improve, swap to a bigger
  local model (`bge-large-en-v1.5` 1024 dim, `mxbai-embed-large-v1`
  1024 dim) and alembic-downgrade/upgrade the column type.
- **Don't run the backfill script and the inline path simultaneously**
  on the same set of rows — both do `UPDATE ... WHERE embedding IS NULL`
  so they're safe, but it wastes compute.
- **Search endpoint runs on the uvicorn workers**, not a background
  task — each query loads a query vector via fastembed and does one
  HNSW lookup. Sub-100ms end-to-end.
- When adding new sources to de_qual_documents/de_qual_extracts, the
  nightly `embed_qual_content` step will catch them automatically —
  no per-source wiring needed as long as they populate raw_text or
  view_text.
