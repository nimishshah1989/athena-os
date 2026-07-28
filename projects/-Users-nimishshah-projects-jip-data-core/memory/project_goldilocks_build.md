---
name: Goldilocks Intelligence Engine Build
description: Content pipeline (scrape → PDF/Whisper → LLM extract → embed) for Goldilocks Research, now running 5-step chain via Groq + fastembed on EC2. Daily cron, dashboard visible, RAG-searchable.
type: project
originSessionId: 2f310c99-51f6-4ae3-91ae-f37729895270
---
## Current state (2026-04-13)

Goldilocks content is fully flowing end-to-end:

```
goldilocksresearch.com  (Playwright login + BS4 scrape)
    │
    ▼
/data/goldilocks/{pdfs,audio,video}/        ← host volume, mounted into container
    │
    ├─ PDF   → extract_goldilocks_pdfs.py (PyMuPDF)           → raw_text + report_type
    └─ MP3/MP4 → transcribe_goldilocks_media.py
                ├─ ffmpeg extract mono/16kHz/32kbps mp3 (70MB → 14MB)
                ├─ chunk if >24MB (10-min segments)
                └─ Groq whisper-large-v3                       → raw_text
    │
    ▼
run_goldilocks_extraction.py (Groq chain: gpt-oss-120b → llama-3.3-70b
  → qwen/qwen3-32b → kimi-k2-0905 → llama-3.1-8b; fallback to OpenRouter
  then Gemini)
    ├─ trend_friend     → de_goldilocks_market_view
    ├─ big_catch        → de_goldilocks_stock_ideas
    ├─ sector_trends    → de_goldilocks_sector_view
    └─ ALWAYS           → de_qual_extracts    (general thematic views)
    │
    ▼
inline embed via fastembed bge-small-en-v1.5 (384 dim)
    │
    ▼
de_qual_documents.embedding + de_qual_extracts.embedding (HNSW cosine)
    │
    ▼
GET /api/v1/observatory/search?q=...&k=...&table=...
```

## Pipeline wiring

**Nightly cron chain** (`__goldilocks_compute__` in
`app/api/v1/pipeline_trigger.py`), fires Mon–Fri 00:30 IST via
`nightly_compute`:

1. `scripts.ingest.goldilocks_scraper --mode daily`           (600s)
2. `scripts.ingest.extract_goldilocks_pdfs`                   (600s)
3. `scripts.ingest.transcribe_goldilocks_media --max-files 10` (1800s)
4. `scripts.ingest.run_goldilocks_extraction --max-docs 100`   (1800s)
5. `scripts.ingest.embed_qual_content`                         (900s)

## Data state (2026-04-13 end of session)

| Table | Rows |
|---|---|
| de_qual_documents (total) | 187 |
| de_qual_documents (done) | 56 |
| de_qual_documents (embedded) | 180 |
| de_qual_extracts | 351 (all embedded) |
| de_goldilocks_market_view | 23 |
| de_goldilocks_sector_view | 205 |
| de_goldilocks_stock_ideas | 13 |

The 7 docs without embeddings are legitimately empty navigation stubs
("Subscribe now", "India Pack" bare titles). Not worth chasing.

## Key settings

- **Groq primary** (reliable free tier). OpenRouter secondary (shared
  ~50 req/day cap — exhausts fast under load). Gemini tertiary (user's
  existing AIzaSy... key has `free_tier_requests limit=0` on the
  paid-tier project and is effectively dead).
- **MAX_TEXT = 25_000 chars** in `run_goldilocks_extraction.py`. Groq
  returns HTTP 413 on `openai/gpt-oss-120b` and `qwen/qwen3-32b` above
  ~60KB request body — transcripts of hour-long con-calls are 50-66K
  chars, so full payload fails.
- **Always extract general views** — unknown report_types (concall,
  big_picture, sound_byte, empty) skip structured extraction but still
  run GENERAL_VIEWS_PROMPT and land rows in de_qual_extracts. This
  unlocked ~75% of the corpus that had no custom handler.
- **Audio/video transcription** via Groq `whisper-large-v3`. `ffmpeg`
  extracts audio track at mono/16kHz/32kbps mp3 to fit under the 25MB
  free-tier upload limit. A 65MB MP4 con-call → 14MB compressed audio
  → 62,251 char transcript in 38 seconds. `transcribe_audio()` in
  `goldilocks_scraper.py` (was a TODO stub) now delegates here.

## Report types

| Report type | Handler | Lands in |
|---|---|---|
| trend_friend | TREND_FRIEND_PROMPT | market_view + general |
| big_catch, stock_bullet | STOCK_IDEA_PROMPT | stock_ideas + general |
| sector_trends, fortnightly | SECTOR_VIEWS_PROMPT | sector_view + general |
| concall, big_picture, sound_byte, qa, snippet, NULL | — (generic only) | general extracts only |

The `--report-type` CLI flag on `run_goldilocks_extraction.py` lets you
target a single type (useful for reprocessing e.g. all concalls after a
prompt improvement).

## Credentials in .env (EC2)

```
GROQ_API_KEY=gsk_uM2c...         primary LLM (inference + Whisper)
OPENROUTER_API_KEY=sk-or-v1-15... secondary fallback
GOOGLE_API_KEY=AIzaSyBg...       tertiary, but the project has limit=0
PIPELINE_API_KEY=Nnjxox4Y...     internal trigger API auth
```

The container MUST be recreated (`docker compose up -d --no-deps
--force-recreate data-engine`) after any `.env` change because env_file
is read at container creation, not restart.

## Known gaps (next session)

- **5 "India Pack /Sound Bytes" MP3 files** have audio_url set but
  aren't on disk. Scraper daily mode tonight should redownload.
- **1 Goldilocks YouTube channel link** captured; enumerating
  individual videos needs yt-dlp + channel fetcher. Not wired.
- **~68 non-goldilocks RSS articles** (ET: 50, Mint: 35, Fed: 20)
  sit pending because `run_goldilocks_extraction.py` hard-filters on
  `source_name ILIKE '%goldilocks%'`. Lifting that filter is ~10 min
  of work.
- **divergence_signals** table exists in schema but no pipeline writes
  to it. Dashboard shows "unknown".
- **130 of 187 docs have `report_type = NULL`** — the
  classify_report_type keyword matcher doesn't recognise their titles.
  Those get general-view extraction only (no structured rows). Adding
  keywords or a LLM classifier would unlock them.

## Why

Assimilating Gautam Shah's decision framework into JIP. The 5-step
chain replaces the earlier manual transcription + one-off extraction
pattern with a fully-automated nightly loop that lands both structured
trade signals (targets/stops/timeframes) and a fuzzy RAG-searchable
thematic layer.

## How to apply

- Before debugging "why isn't X extracted", check the full chain path:
  which step is the bottleneck? Look at de_qual_documents
  processing_status + LENGTH(raw_text) first.
- For manual reprocessing, use `run_goldilocks_extraction.py
  --report-type X --max-docs N`.
- For failed LLM calls at scale, the fallback chain is doing its job —
  rate limits leave docs pending, not failed. Next cron picks them up.
