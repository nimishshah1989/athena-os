---
name: Loud-fail ops overhaul
description: de_cron_run table + jip_trigger.sh wrapper + Agent 3 self-heal + dashboard Cron Runs panel — every scheduled job now has a visible row. Built 2026-04-13 after silent Friday EOD gap.
type: project
originSessionId: 2f310c99-51f6-4ae3-91ae-f37729895270
---
Overhaul of the data engine's cron and monitoring layer, triggered by a
**Friday 2026-04-10 EOD gap** where the crontab was installed at 13:28
UTC, 25 minutes after the 13:03 EOD slot, and the failure was invisible
until the user checked the dashboard 3 days later.

## What exists now

**de_cron_run table** (alembic `005_add_cron_run.py`) — one row per
scheduled fire. Columns: schedule_name, business_date, started_at,
finished_at, duration_seconds, http_code, curl_exit_code, status
(started|success|failed|timeout), error_body, host. Indexed on
schedule_name and (schedule_name, started_at).

**scripts/cron/jip_trigger.sh** — wraps every cron line. Does:
1. INSERTs a 'started' row
2. curl POSTs the trigger API with the pipeline key header
3. UPDATEs the row with finish state (http_code, exit code, duration,
   error body)
4. Exits non-zero on failure so cron-level monitors see it
5. Writes a per-schedule `*_run.log` with stdout+stderr
Env vars: PIPELINE_API_KEY, DATABASE_URL_SYNC. The DATABASE_URL_SYNC
is the SQLAlchemy-flavoured `postgresql+psycopg2://...` so the script
strips the driver prefix before handing to plain psql.

**scripts/cron/jip_agent3.sh** — real self-healing agent, replaces what
was a markdown-only design in `docs/agents/agent-3-health-check.md`.
Calls `/observatory/health-action` → triggers each broken pipeline via
`/pipeline/trigger/single/{pipeline}` → verifies via `/pulse` → writes
`de_healing_log`. Respects weekend skip list. Two cron passes daily.

**scripts/cron/jip_scheduler.cron** — rewritten. 9 data-pipeline lines:
- `3 13 * * 1-5` EOD (wrapper → /trigger/eod)
- `0 17 * * 1-5` **amfi_late** (new — AMFI publishes ~22:00 IST so the
  old 18:33 EOD always missed same-day NAVs)
- `0 19 * * 1-5` nightly_compute (moved from 19:33 so it runs after
  amfi_late has fresh NAVs)
- `3 13 * * 0,6` eod_weekend + `3 14 * * 0,6` etf_global
- `3 18 * * *` Agent 3 pass 1
- `3 21 * * *` Agent 3 pass 2 (after nightly_compute)
- `30 22 * * 6` morningstar_weekly
- `30 21 1 * *` holdings_monthly

**Dashboard "Cron Runs (last 48h)" panel** — renders de_cron_run rows
with failed rows highlighted red. Added to `app/static/observatory.html`,
feeds from GET `/api/v1/observatory/cron-runs?hours=N`.

## Pipeline bug fixes shipped alongside (same session)

All were pre-existing bugs masked by the lack of visibility:

- `apply_data_status()` assumed `business_date` column; now takes
  `date_column` param. MF uses `nav_date`, equity uses `date`.
- `india_vix` FK violation: INDIAVIX missing from de_macro_master. Fixed
  by seeding + adding `_ensure_vix_master()` self-seed to vix.py. Run
  time dropped from 300s (retry loop) to 0.33s.
- FRED FK violations: `_seed_macro_master()` helper existed but was
  never invoked. Ran it directly — 54 FRED tickers + INDIAVIX seeded.
- `breadth_regime.py` had 3 stacked SQL bugs: `AS dec` (DEC is a
  reserved data-type alias), `start_date` as str to asyncpg DATE param,
  and the regime WHERE-clause replace broke the CTE/JOIN structure.
- `fund_metrics.py` was UPDATE-only; added an `INSERT ... ON CONFLICT
  DO NOTHING` seed step that pulls from validated NAVs.
- `mf_category_flows` wasn't scheduled anywhere — added to
  `holdings_monthly`. Container was missing xlrd/openpyxl — installed
  + declared in pyproject.toml. Anomaly types remapped to the values
  the `chk_data_anomaly_type` CHECK allows.
- Observatory `_freshness_status()` was one-size-fits-all; now accepts
  per-stream `fresh_hours`/`stale_hours` overrides. `mf_holdings`,
  `mf_flows`, and the goldilocks streams get wider windows.

## Pulse before vs after

Start of session: `fresh 2 / stale 17 / critical 7`
End of session:   `fresh 24 / stale 1 / critical 1`

The 1 stale + 1 critical are `mf_nav` and `mf_derived`, both waiting on
AMFI's same-day NAV publication which happens ~22:00 IST via the new
amfi_late cron.

## Commits (all on origin/main)

```
a013227 fix(goldilocks): cap raw_text at 25K chars to stay under Groq payload limit
ede2d9a feat(goldilocks): audio/video transcription via Groq Whisper + ffmpeg
54f8f7f feat(rag): pgvector embeddings + semantic search for qualitative content
216454b feat(goldilocks): Groq primary + always extract general views
344f767 fix(observatory): SLA thresholds for goldilocks streams
ecd1526 fix(goldilocks): OpenRouter fallback chain + transient error handling
ba84be8 fix(goldilocks): switch to gemini-2.5-flash + retry transient errors
c283b35 fix: data engine reliability — loud-fail cron, agent 3, and pipeline bugs
```

## Why

User's core complaint: *"the database is not updating per cron jobs; i
shouldnt be required to come back to these systems and keep checking"*.
The fix isn't just repairing the Friday gap — it's making future gaps
impossible to hide. Every cron fire now produces a visible row; every
pipeline failure now produces a visible row; the dashboard shows both.

## How to apply

- Before diagnosing "why is X stale", always check de_cron_run first.
  If the row is missing, the cron didn't fire. If it's there with
  status=failed, error_body has the response body.
- New cron lines MUST go through `jip_trigger.sh`. Direct curl is
  banned because it regresses the loud-fail property.
- Agent 3 runs nightly — don't expect to manually trigger pipelines
  for routine recovery. Let it run first, then investigate what Agent 3
  itself flagged as unfixable.
- Container recreate (`docker compose up -d --no-deps --force-recreate
  data-engine`) is needed to pick up new `.env` values — `docker
  restart` alone doesn't reload env_file.
