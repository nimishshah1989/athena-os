---
name: v6-mv-count-breakdown
description: "v6 has 14 expected MVs (per canonical-backend.md). As of 2026-05-27, 7 are live, 7 are deferred on EC2 Python compute (Phase C1.c/d + C2). Always state both numbers — never just one."
metadata: 
  node_type: memory
  type: project
  originSessionId: c880c6b8-5d45-4717-8ecc-d02304a45cd0
---

**The v6 materialized view contract is 14 MVs total** (per `docs/v6/canonical-backend.md` MV map):

**Live on Supabase atlas-os (`nanvgbhootvvthjujkvs`) as of 2026-05-27 — 7 MVs:**
- `mv_market_regime_landing` (Page 01, 1 wide row)
- `mv_markets_rs_grid` (Page 03 grid, 9 baselines)
- `mv_stock_list_v6` (Page 05 list, 750 rows)
- `mv_stock_deepdive` (Page 05a, 750 rows)
- `mv_fund_list_v6` (Page 06 list, 587 rows)
- `mv_fund_deepdive` (Page 06a, 587 rows)
- `mv_calls_performance` (Page 08, 363 rows)

**Deferred on EC2 Python compute — 7 MVs:**
- `mv_india_pulse` (Page 02 — blocked on Phase C2 macro ingest: dii_flow / us_10y_yield / brent_inr / cpi_yoy / vix_9d columns NULL on `atlas_macro_daily`)
- `mv_markets_rs_detail_charts` (Page 03 detail charts — design pending)
- `mv_sector_cards` + `mv_sector_breadth` + `mv_sector_rrg` + `mv_sector_deepdive` (Page 04 + 04a — blocked on Phase C1.d sector 5y backfill of 8 new cols on `atlas_sector_metrics_daily`)
- `mv_etf_list_v6` + `mv_etf_deepdive` (Page 07 + 07a — blocked on Phase C1.c ETF expand 34→126 on `atlas_etf_scorecard`)
- `mv_stock_landscape` (Page 05 landscape view — bubble + 24-cell matrix data)

**Why:** EC2 has a working Python stack with all the dependencies (psycopg2 broken on Mac per [[ec2-access]]). The overnight session on 2026-05-26 → 2026-05-27 deliberately deferred the compute-heavy backfill work that couldn't be done from local Supabase MCP alone.

**How to apply:**
- When reporting MV status, ALWAYS say "X of 14" not just "X". The user remembers the 14 from yesterday's plan.
- If a user asks "is the backend complete?", the answer is "tables yes (30/30, 10+y history), MVs no (7/14 live, 7 deferred on EC2 Python work)."
- The Phase B/C plan and overnight session log (`docs/v6/2026-05-26-overnight-session-log.md`) are the authoritative source for what was promised vs deferred.
- Related: [[v6-build-plan-source-of-truth]] (the 60-task plan including Phase E MV work).
