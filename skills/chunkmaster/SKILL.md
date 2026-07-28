---
name: chunkmaster
version: 0.1.0
description: |
  Take a slice/phase spec, break it into runnable forge-runner chunks, and seed
  them into orchestrator/plan.yaml + orchestrator/state.db so `forge run` can
  pick them up. Generic version (no Spec Kit dependency) — reads a spec file,
  drafts chunks as Claude, writes specs under docs/specs/chunks/, and upserts
  rows into state.db with correct schema.

  Use when the user says: "chunk this spec", "chunkmaster V2", "break down the
  phase J plan into chunks", "seed chunks from docs/specs/chunk-plan-phase-j.md".

  Voice triggers: "chunk master", "chunk this", "run chunkmaster".
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
argument-hint: "<SLICE_TAG> [--spec <path>]  e.g. J  or  V2 --spec docs/specs/my-plan.md"
user-invocable: true
disable-model-invocation: false
---

# /chunkmaster

Turn one phase/slice spec into N forge-runner chunks, without a PRD file and without human-in-the-loop clarification rounds.

**Arguments**: `$ARGUMENTS`
- First positional = slice tag (e.g. `J`, `V2`, `PHASE-K`). Becomes the chunk ID prefix.
- Optional `--spec <path>` = path to the source spec file. Default: `docs/specs/chunk-plan-<slice>.md`, then `docs/specs/design-doc-<slice>.md`, then ask the user.

## Hard rules

1. **Never create a PRD file.** The spec you read IS the source of truth. Do not duplicate it.
2. **Never modify the source spec** — read-only.
3. **Never start the runner.** Your job ends when chunks are seeded. Print the kickoff command for the user.
4. **Never commit.** Stage files if you want, but leave the commit for the user or a separate `/commit` invocation.
5. **Only touch**: `docs/specs/chunks/<prefix>-*.md`, `orchestrator/plan.yaml`, `orchestrator/state.db`.
6. **Resume-safe**: if a chunk ID already exists in `state.db`, skip it (print a "already seeded" line). Never overwrite DONE/IN_PROGRESS chunks.
7. **Self-answer clarifications.** Read `CLAUDE.md`, `.forge/CONDUCTOR.md`, and the project's auto-memory BEFORE asking the user anything. Only escalate if a fact is genuinely not in the repo.

## Preflight (fail fast, don't auto-fix)

Check these before touching anything:

```bash
test -f .forge/project.yaml || { echo "chunkmaster: run 'forge init' first"; exit 1; }
test -f orchestrator/state.db || { echo "chunkmaster: state.db missing — 'forge init'"; exit 1; }
test -f orchestrator/plan.yaml || { echo "chunkmaster: plan.yaml missing"; exit 1; }
test -f CLAUDE.md || { echo "chunkmaster: CLAUDE.md missing"; exit 1; }
git status --porcelain | grep -q . && echo "chunkmaster: WARN — dirty tree, proceeding anyway"
```

Halt if the spec file doesn't exist. Do not create it.

## Pipeline

### Step 1 — Parse arguments

- Extract SLICE tag from `$ARGUMENTS`. Must match `^[A-Z]+[0-9]*$` or `^[A-Z]+-?[0-9]+$`. If malformed, print usage and exit.
- Resolve `--spec`:
  - If `--spec <path>` given, use it.
  - Else try `docs/specs/chunk-plan-phase-<slice-lowercase>.md` and `docs/specs/chunk-plan-<slice>.md` and `docs/specs/design-doc-phase-<slice-lowercase>.md`.
  - If nothing matches, Glob for `docs/specs/*<slice>*.md` and ask the user which to use via AskUserQuestion.

### Step 2 — Build the in-memory SLICE_BRIEF

**Do NOT write this to disk.** Keep it in your context.

Pull the following into a structured brief:
1. The raw spec section(s) for this slice.
2. From `CLAUDE.md`: conventions, hard stops, stack pins relevant to the files this slice touches.
3. From `.forge/CONDUCTOR.md`: project-specific hard stops.
4. From auto-memory (`~/.claude/projects/<slug>/memory/`): any relevant decisions or feedback.
5. Upstream deps (chunks from prior slices that must be DONE) and downstream consumers (so chunk order is stable).

### Step 3 — Draft the chunk list

Break the slice into chunks where each chunk is:
- **Buildable in one ≤45m Claude session.** If you can't describe the work in 2 sentences, split it.
- **Single responsibility.** A chunk touches one layer (ingestor, service, agent, router, test set). No "and also" chunks.
- **Self-contained acceptance criteria.** 3–6 checkboxes the runner's verifier can satisfy.
- **Explicit deps.** If chunk `<slice>-3` needs `<slice>-2` to exist, declare it.

Naming: `<SLICE>-<N>` where N is zero-padded if the slice has ≥10 chunks (`J-01`, `J-02`, ..., `J-12`). Lexicographic sort matters to the picker.

### Step 4 — Draft a Q&A self-check

Before writing any chunk, ask yourself (as the model):
- Does every chunk have a clear "done" state that tests or file existence can verify?
- Are there chunks that would violate a CLAUDE.md hard stop (e.g., float money, port 8000, modifying `backend/etl/`)? If yes, rewrite or drop.
- Are any two chunks actually one chunk in disguise (same files, same tests)? Merge.
- Is any chunk missing a dep on an upstream chunk? Add it.

Do NOT ask the user these questions — answer them yourself from repo context.

### Step 5 — Write per-chunk spec files

For each chunk, write `docs/specs/chunks/<id>.md` with this structure:

```markdown
# <ID> — <Short title>

## Goal
<One paragraph.>

## Scope
<Bulleted list of files to create/modify and what to change.>

## Acceptance criteria
- [ ] <Specific, testable statement>
- [ ] <...>
- [ ] Commit subject starts with `<ID>:` or `<ID> `
- [ ] `state.db` shows `<ID>` with `status='DONE'`
- [ ] Tests still green: `<project test command>`

## Steps for the inner session
1. <Ordered steps>

## Out of scope
<What not to touch, explicit.>

## Dependencies
- Upstream: <list of chunk IDs or "none">
- Downstream: <list of chunk IDs or "none">
```

Do not exceed 80 lines per spec. If you need more, the chunk is too big — split.

### Step 6 — Append to plan.yaml

Read `orchestrator/plan.yaml`. Under `chunks:`, append one entry per new chunk:

```yaml
  - id: <ID>
    title: <title>
    spec: docs/specs/chunks/<ID>.md
    deps: [<upstream IDs>]
    status: PENDING
```

If `chunks: []` becomes `chunks:\n  - ...`, replace the empty list. If a chunk with the same ID already exists, skip it (do not overwrite).

### Step 7 — Upsert into state.db

Use the Bash tool with a python3 heredoc — DO NOT try to write binary directly:

```bash
python3 - <<'PY'
import sqlite3, datetime, json
now = datetime.datetime.now(datetime.timezone(datetime.timedelta(hours=5, minutes=30))).isoformat(timespec="seconds")
chunks_to_seed = [
    # List of (id, title, spec_path, deps_json_str)
    ("J-1", "Migrate scheduler to pipeline+cli", "docs/specs/chunks/J-1.md", "[]"),
    # ...
]
con = sqlite3.connect("orchestrator/state.db", isolation_level=None)
for cid, title, spec, deps in chunks_to_seed:
    row = con.execute("SELECT status FROM chunks WHERE id=?", (cid,)).fetchone()
    if row and row[0] in ("DONE", "IN_PROGRESS"):
        print(f"[chunkmaster] skip {cid} — already {row[0]}")
        continue
    con.execute("""INSERT OR REPLACE INTO chunks
        (id, title, spec, deps, depends_on, status, attempts, created_at, updated_at, plan_version)
        VALUES (?, ?, ?, ?, ?, 'PENDING', 0, ?, ?, '1.0')""",
        (cid, title, spec, deps, deps, now, now))
    print(f"[chunkmaster] seeded {cid}")
PY
```

Both `deps` and `depends_on` columns must be written — the forge-os init schema uses `deps` but the runner's state.py reads `depends_on`. Until forge-os fixes this upstream, write both.

### Step 8 — Final report

Print a single block:

```
chunkmaster: seeded <N> chunks for slice <SLICE>
  source spec:   <path>
  chunks:        <list of IDs>
  plan.yaml:     +<N> entries
  state.db:      +<N> rows (PENDING)
  skipped:       <N> (already DONE/IN_PROGRESS)

next:
  forge run --dry-run              # verify picker sees them
  forge run --filter '<SLICE>-.*'  # run the slice
  forge run --once                 # run one chunk
```

Do not run any of those commands yourself. The user runs them.

## Failure modes

| Symptom | Fix |
|---|---|
| `chunks: []` parse fails | Edit plan.yaml to `chunks:\n  - id: ...` — do not rewrite the file |
| `UNIQUE constraint failed` on state.db insert | Use `INSERT OR REPLACE` guarded by the skip-if-done check |
| Schema mismatch on insert | Run `.schema chunks` — if columns missing, bail and tell user to run schema migration |
| Source spec has no clear slice boundary | Ask user once via AskUserQuestion which section is this slice; do NOT guess |
| Would create > 15 chunks | Stop at 15, tell the user the slice is too big and needs splitting into sub-slices |

## What you MUST NOT do

- Do not edit `CLAUDE.md`, `.forge/CONDUCTOR.md`, `.forge/project.yaml`, or any file outside `docs/specs/chunks/`, `orchestrator/plan.yaml`, `orchestrator/state.db`.
- Do not run `forge run`, `forge ship`, or `git commit`.
- Do not create a "PRD" file, a "clarifications" file, a "plan.md", or any intermediate doc. The in-memory brief is ephemeral.
- Do not ask the user anything answerable from CLAUDE.md, the source spec, or auto-memory.
- Do not write chunks that touch `backend/etl/` or `backend/ingestion/` (frozen per YTIP's CLAUDE.md).
- Do not use `float` for money in any chunk spec. Decimal + paise always.
