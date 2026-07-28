---
name: project-us-stocks-backfill-state
description: "US stocks compute backfill state — pipeline complete, two-pass RS fix applied, frontend live"
metadata: 
  node_type: memory
  type: project
  originSessionId: 1bbdb267-f279-40b3-81b8-d8b2761d40a1
---

US stocks full backfill v2 completed 2026-05-13 on frontend EC2 (13.202.162.196).
Elapsed: 917.8 seconds. run_id: 372b1148-35b5-4daf-beef-4aeca6aacec6.

**Why:** First backfill crashed (KeyError: stage1_base_qualifies) because classify_rs_state
reads that column before add_stage1_base creates it. Fixed with two-pass RS classification:
seed False → classify_rs_state (pass 1) → add_stage1_base → classify_rs_state (pass 2).

## Row Counts (as of 2026-05-13 v2)
- `us_atlas.atlas_stock_metrics_daily`: 2,034,209 rows (2008-01-02 → 2026-05-12)
- `us_atlas.atlas_stock_states_daily`: 2,034,209 rows
- `us_atlas.atlas_stock_rs_states`: 9,400 rows (latest date only: 470 tickers × 4 benchmarks × 5 timeframes)
- `us_atlas.atlas_benchmark_returns_cache`: 27,522 rows (6 benchmarks)
- `us_atlas.stock_ohlcv`: 2,034,209 rows via OHLCV loaded

## Live Frontend Data (2026-05-13)
- 506 total tickers, 444 live (history+liquidity pass)
- 53 Leader/Strong, 98 Accel/Improving
- ETFs: 47 total, 11 Sector ETFs, 3 Leader/Strong

## Frontend Pages
- /us/stocks — US Stock Universe (live at atlas.jslwealth.in/us/stocks)
- /us/etfs — US ETF Universe (live at atlas.jslwealth.in/us/etfs)
- Components: USStockScreener, USETFScreener, USSectorBreadthBar, USSectorHeatmap
- Queries: us-stocks.ts (getUSStocks + getUSSectorBreadth), us-etfs.ts (getUSETFs)

## Fixes Applied
1. **ret_12m_1m + atr_21**: Now computed (removed hardcoded pd.NA, wired add_atr())
2. **stage1_base_qualifies**: Two-pass RS fix enables Emerging state
3. **Commit 94d689c**: two-pass RS fix
4. **Commit f639ca8**: US frontend pages

## Known Gaps — YELLOW (not blocking)
1. **34 universe tickers with no OHLCV** — Stooq coverage gap; all is_active=True
2. **Bad single-day prices in Stooq** — wcn (2010-08-13), stag (2013-03-26), avb (2012-12-21)
3. **`Emerging` RS state rate** — now enabled but may be rare; data validates after 1 week of live runs
4. **VIX missing** — `^VIX` not in benchmark cache; no US VIX regime signal
5. **Daily pipeline** — no scripts/us_daily.py yet for incremental updates

**How to apply:** US stocks frontend is live and watchable. Daily pipeline needed before production.
