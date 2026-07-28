---
name: project-validator-phase-c-state
description: "Validator Phase C route crawler — fully live as of 2026-05-13; P0=0 across all 6 routes; 1495 data points nightly"
metadata: 
  node_type: memory
  type: project
  originSessionId: ff19039a-176f-47fe-b8ee-1ff077ef2a8c
---

## Status: LIVE — P0=0 across all 6 routes. Nightly cron wired.

**What it does**: Headless Playwright crawler visits 6 frontend routes, extracts
`data-validator-id` DOM attributes, diffs against SQL source-of-truth, persists
findings to `atlas_validator_findings`.

**Active routes + data points (routes.yaml)**:
- `/` — 3 data points (RegimeHeadline: `regime.regime_state`, `regime.india_vix`, `regime.deployment_multiplier`)
- `/etfs` — 34 data points (ETFScreener: `etf.rs_pctile_3m`, `etf.effort_ratio_63`, `etf.above_30w_ma`)
- `/intelligence` — 23 data points (TopConvictionSection: `conviction_score`; RSLeadersList: `stock.rs_pctile_3m`)
- `/sectors` — 24 data points (SectorDecisionTable: `sector.sector_state` per sector_name)
- `/stocks` — 250 data points per page (StockScreener: `rs_state`, `momentum_state`, `ret_1m`, `ret_3m`, `rs_pctile_3m` × 50 rows)
- `/funds` — 1161 data points (FundScreener: `nav_state`, `composition_state`, `rs_pctile_3m` × ~387 funds)
- **Total: ~1495 data points verified per nightly run**

**Nightly trigger**: `/home/ubuntu/run_atlas_nightly.sh` step [7] (after health check).
Runs Mon-Fri at 21:00 IST. Frontend validator step is non-fatal (|| true).
Findings persisted to `atlas.atlas_validator_findings`.

**Key bugs fixed (2026-05-13 session)**:
1. `StockScreener.tsx` rs_state + momentum_state missing `data-validator-raw` — chips abbreviate ("Average"→"Avg") causing 87 P0s → fixed
2. `sql_lookup.py` fund table bugs — wrong table (`atlas_fund_lens_daily` doesn't exist), split into `_fund_metrics_scalar` + `_fund_states_scalar`
3. `atlas_fund_metrics_daily` uses `nav_date` not `date` column — fixed ORDER BY
4. `fund.nav_state` moved to `atlas_fund_states_daily` (correct date column)
5. Removed non-existent `fund.category_state` from LOOKUPS
6. `_TIMEOUT_MS` raised from 60s to 120s — `/sectors` needed >60s
7. `FundScreener.tsx` nav_state + composition_state missing `data-validator-raw` — chips abbreviate → fixed

**Current standing P1s** (not bugs):
- 166 P1s on `fund.rs_pctile_3m`: 166/387 funds have null rs_pctile_3m in frontend because their nav_date doesn't align with the latest compute date. Valid data pipeline gap — logged as P1 each night.

**30-day sampling coverage**:
- Stocks: 50/~750 rows per night = all stocks cycled in 15 days (P0 on all 5 fields)
- Funds: 387 funds, all shown = 100% coverage nightly (all 3 fields checked)
- Sectors: 100% coverage nightly (12 sectors × 2 fields)
- Regime: 100% coverage nightly (1 regime row × 3 fields)
- ETFs: all ~17 ETFs per night = 100% coverage

**sql_lookup.py LOOKUPS dict (final)**:
- `stock.*` → `atlas_stock_metrics_daily` + `atlas_stock_states_daily`
- `sector.*` → `atlas_sector_metrics_daily` + `atlas_sector_states_daily`
- `etf.*` → `atlas_etf_metrics_daily`
- `fund.rs_pctile_3m` → `atlas_fund_metrics_daily` (nav_date col)
- `fund.nav_state`, `fund.composition_state` → `atlas_fund_states_daily` (date col)
- `regime.*` → `atlas_market_regime_daily`

**Pending** (admin page not yet built):
- `/admin/validator` page showing run history + findings table
- `/admin/thresholds` not yet instrumented with data-validator-id
