---
name: ""
metadata: 
  node_type: memory
  chunk: mv-sector-rrg
  project: atlas-os
  date: 2026-05-27
  status: success
  originSessionId: c880c6b8-5d45-4717-8ecc-d02304a45cd0
---

# MV 5 of 9 — `atlas.mv_sector_rrg` State

## What was built

Migration 104: `atlas.mv_sector_rrg` materialized view powering the
Relative Rotation Graph (RRG) on Page 04 Sectors.

## Approach chosen

Single source: `atlas_sector_metrics_daily.bottomup_rs_3m_nifty500`.

Formula:
- `rs_ratio = 100 + (bottomup_rs_3m_nifty500 * 100)` — parity = 100.0
- `rs_momentum = rs_ratio - LAG(rs_ratio, 20) OVER (PARTITION BY sector_name ORDER BY date)`
- Quadrant: CASE on (rs_ratio >= 100, rs_momentum >= 0) → Leading/Improving/Lagging/Weakening

6-week trail: ROW_NUMBER DESC % 5 = 1 selects every 5th row (weekly anchors),
then LATERAL with LIMIT 6 + ORDER BY date ASC assembles oldest-first trail_6w JSONB.

## Key decisions

- Did NOT use `rs_velocity` stored column (uses configurable window from atlas_thresholds;
  RRG spec requires fixed 20-day lag — self-contained SQL is safer)
- LATERAL over weekly_filtered CTE avoids correlated subquery per row (which caused MV 4 timeout risk)
- trail_6w COALESCES to '[]'::jsonb when no weekly anchors found
- NULL propagated throughout — never zeroed

## Files

- `migrations/versions/104_mv_sector_rrg.py`
- `tests/migrations/test_104_mv_sector_rrg.py` (40 unit + 9 integration tests)
- `docs/v6/mvs/2026-05-27-mv-sector-rrg-design.md`
- `docs/v6/audits/2026-05-27-mv-sector-rrg-final.md`

## Test result

40/40 unit tests PASS. ruff clean. 9 integration tests EC2-gated (SKIP locally).

## Apply status

Committed locally. Parent to push + apply via Supabase MCP execute_sql
in order: CREATE MV → CREATE UNIQUE INDEX → REFRESH → CRON SCHEDULE.

Cron: `mv_sector_rrg_nightly` at `20 15 * * *` (20:50 IST).
