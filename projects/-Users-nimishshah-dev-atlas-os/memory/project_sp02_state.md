---
name: SP02 Materialized Views + RRG Velocity — shipped
description: 5 nightly-refreshed materialized views + rs_velocity column. Live on EC2. Backend ready; frontend pages not yet wired to read from MVs (separate task).
type: project
originSessionId: b03c7f67-fe54-4643-8fc6-c6dce97c8b0f
---
**Ran:** 2026-05-12 overnight
**Commits:** fe9f835, b815b45, c559e89, 9be62b9, 1b00b5a, a4a34cb, 0f432ca (7 total)
**Plan:** `docs/phase2/plans/2026-05-12-sp02-materialized-views.md`

## What shipped

Migrations 034, 035, 036 (head). Applied on local + EC2 Supabase.

**`atlas_sector_metrics_daily.rs_velocity`** — `Decimal(10, 6)` column added. 4-week rate of change of `bottomup_rs_3m`. Currently NULL — populates on next sectors-pipeline run. Implemented in `atlas/compute/sectors.py:compute_rs_velocity` using `merge_asof BACKWARD` with 5-day calendar tolerance.

**Materialized views** (all `REFRESH CONCURRENTLY` enabled via unique indexes):
- `mv_rs_leaders_daily` — 54 rows on EC2
- `mv_sector_rotation_state` — 30 rows on EC2
- `mv_current_market_regime` — 1 row
- `mv_breakout_candidates` — 6 rows
- `mv_deterioration_watch` — 1 row

**pg_cron schedules**: 5 jobs at `30 14 * * *` UTC (20:00 IST), one per MV. Verified on EC2 via `SELECT jobname, schedule FROM cron.job`.

**Frontend query files** (NEW, not yet wired into pages):
- `frontend/src/lib/queries/leaders.ts` — reads `mv_rs_leaders_daily`, `mv_breakout_candidates`, `mv_deterioration_watch`
- `frontend/src/lib/queries/rotation.ts` — reads `mv_sector_rotation_state`, `mv_current_market_regime`
- `frontend/src/components/sectors/SectorRRGPlot.tsx` — Recharts scatter with quadrant overlays, NEW component

## What's NOT wired

Existing pages (`/stocks`, `/sectors`, `/etfs`, `/funds`, `/regime`) still hit their current SQL paths. The new MVs and query files exist but aren't consumed yet — per the SP02 constraint of "zero edits to existing pages". A follow-up sub-project (or a small last-mile task) rewires `frontend/src/app/sectors/page.tsx` and similar to use the new query files.

## Known scope gaps

1. **`rs_velocity` column not yet populated.** The compute function exists and tests pass, but `backfill_sector_metrics()` must run on EC2 to fill the column with real values. Until then, the RRG quadrant column in `mv_sector_rotation_state` defaults to "Leading" (because `COALESCE(NULL, 0) >= 0`).
2. **`rs_6m_nifty500` doesn't exist on `atlas_stock_metrics_daily`.** Plan assumed it did. Substituted `ret_6m` (6-month total return) in `mv_rs_leaders_daily`. If true 6m RS vs Nifty 500 is wanted, upstream pipeline needs a new column.
3. **No tests on the materialized views themselves.** Only the Python `compute_rs_velocity` function has tests. View correctness is verified by row-count checks after migration.

## How to use this

- Frontend developers: import from `@/lib/queries/leaders` and `@/lib/queries/rotation` for new pages or rewired existing pages. The query layer is the boundary; pages should not write raw SQL.
- Backend developers: `compute_rs_velocity` is a pure pandas function in `atlas/compute/sectors.py`. Call it on a `bottomup_rs_3m` time series indexed by date.
- Ops: pg_cron jobs need no manual intervention. To force-refresh a view, `SELECT cron.schedule(...)` or `REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.<mv_name>`.

## Next-up

SP03 (OpenBB BYO Copilot) — uses the new MVs as the SSE-streamed data source for the OpenBB Workspace integration.
