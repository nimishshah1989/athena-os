---
name: project_regime_indiapulse_fix_chunk
description: "2026-05-30 Regime + India Pulse fix chunk — live handoff state, decisions, deploy steps"
metadata: 
  node_type: memory
  type: project
  originSessionId: a37de76f-0d81-4da5-ae9c-636e22612b49
---

Regime + India Pulse "fine-tuning" chunk (2026-05-30). Days of backend work,
not fine-tuning. User decisions: **deploy=1a** (reconcile alembic then Alembic
owns DDL), **order=2a** (cheap proven MV wins first), RS ~2yr backfill,
RS windows **5→7** (+1d,+24m), days/return = RECOMPUTE ~2yr history + show BOTH
abs+excess. Backfills must be vectorized/set-based (no loops).

## HANDOFF STATE (where to resume)

**Wave 1 = M1 (mv_india_pulse v2) + M2 (breadth EMA-20/100 + 4wk-high). CODE
DONE locally, NOT deployed.** Next session = deploy Wave 1, then M3-M7.

Files written/edited this session:
- `migrations/versions/122_mv_india_pulse_v2.py` — VERIFIED compiles + structural
  greps pass. Adds cols pct_above_ema_100 + pct_4w_high to
  atlas_market_regime_daily; DROP+CREATE mv_india_pulse with v2 body; unique
  index uix_mv_india_pulse_as_of_date; refresh. Reversible (downgrade restores
  migration-100 body). down_revision="121".
- `migrations/sql/mv_india_pulse_v2.sql` — the validated MV body (scratch ref).
- `atlas/compute/breadth.py` — VERIFIED compiles. compute_ma_breadth now returns
  pct_above_ema_20/50/100/200 (ema_100 computed fresh via ewm span=100); NEW
  compute_pct_4w_high (20d rolling-max, tol 0.1%). +3 pyright errors but all the
  SAME pandas-stubs false-positive class already in the file (baseline 13→16).
- `atlas/compute/regime.py` — VERIFIED compiles. Imports compute_pct_4w_high;
  merges p4wh; METRICS_COLUMNS adds pct_above_ema_100 + pct_4w_high; removed the
  old "pct_above_ema_20 not in columns" NaN stub → loop over the 3 cols.
- `scripts/backfill_breadth_ema_4wh.py` — DONE. Compiles + **pyright 0 errors** +
  smoke-tested (compute_ma_breadth returns all 4 EMA cols, compute_pct_4w_high
  works). Surgical: bulk_upsert writes ONLY [date, pct_above_ema_20,
  pct_above_ema_100, pct_4w_high] (ON CONFLICT touches only provided cols →
  regime_state untouched); restricts to existing dates via SQLAlchemy text()
  query. Default range = HISTORICAL_START_DATE (2016-04-07) → today.

M1 was READ-ONLY VALIDATED live: v2 SELECT returns vix_term_structure=-0.99,
8 macro_cards, narrative 10Y=6.84/FII=-2408, sector heatmap all 5 RS windows,
breadth "% above 50 EMA"=57.0; ema_20/100/4wh correctly data_gap=true until
backfill runs. 4wk-high set-based proof: 8.8% on 2026-05-29 over 498 names.

## DEPLOY WAVE 1 (next session, on EC2 jsl-wealth-server / .214)
DB = Supabase atlas-os (nanvgbhootvvthjujkvs). Live alembic_version=**112** in
`public.alembic_version`, files→121. **113-121 ARE effectively applied** (derive_verdict
fn, mv_stock_landscape_trader, tv_metrics+tv_portfolio_exports, 118 cols, 58/59
of 119 cols, tv_screener_nightly + mv_refresh_v6_all crons all live). ONLY gap:
mv_stock_list_v missing (live uses mv_stock_list_v6 — pre-existing drift, NOT my
chunk, leave it). So:
1. ssh atlas; cd /home/ubuntu/atlas-os; git pull
2. `alembic stamp 121` (reconcile: tells Alembic DB is at 121; no DDL runs)
3. `alembic upgrade head` (runs ONLY migration 122)
4. `python scripts/backfill_breadth_ema_4wh.py` (populates the 3 breadth cols)
5. `REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_india_pulse;` (or wait for
   mv_refresh_v6_all 21:45). NOTE: 122 already refreshes once non-concurrently.
6. Verify live: term structure / macro cards / narrative / sector RS 1m-12m all
   populate; breadth shows EMA labels + 20/100 EMA + 4wk-high non-gap.
7. Frontend: NO rebuild needed (RSC reads MV directly) — but hard-refresh to confirm.

## REMAINING BACKEND (after Wave 1)
- M3: rs_1d + rs_24m in atlas/compute/sectors.py (+stock); standardize ALL sector
  RS to relative form (1+rI)/(1+rB)-1 — currently rs_3m relative but rs_1w/1m/6m/12m
  plain diff; ~2yr backfill. Sector RS lives in atlas_sector_metrics_daily.
- M4: 9-baseline×7-window Markets RS grid (mv_markets_rs_grid EXISTS — verify
  coverage, extend). Baselines: Nifty50/100/Midcap150/Smallcap250/500/Gold/SP500/
  MSCIWorld/EEM (see CONTEXT Baseline source registry). Vectorized outer-broadcast.
- M5: backfill cross_sectional_dispersion ≥60 trading days into atlas_regime_daily
  (only 3 dates now → flat-line chart). compute in atlas/regime/cron.py window=20.
- M6: return-since-call abs+excess (price join de_equity_ohlcv→2007) + recompute
  ~2yr signal/scorecard history for real entry dates (fixes d8-for-everyone; engine
  minted 2026-05-22). ledger empty (0 rows).
- M7: macro ingest currency (atlas_macro_daily lags 2d) + nightly refresh ordering.

## FRONTEND WAVE (after backend)
F1 tooltip placement/sizing (frontend/src/components/ui/InfoTooltip.tsx, Radix);
F2 regime 12w table labels-in-colour-blocks (components/v6/landing/RegimeJourney12w.tsx);
F3 Top Conviction buy/avoid toggle + buys-first + abs+excess cols + ETF rows
(components/v6/landing/TodayConvictionTabs.tsx; query lib/queries/v6/landing.ts);
F4 funds return+expectation cols (same TodayConvictionTabs funds tab);
F5 worklist FM enrichment (components/regime/TodayWorklist.tsx);
F6 sort/filter all tables + 1w/1d/24m temporal filters.

Plan doc: docs/v6/2026-05-30-regime-indiapulse-fix-plan.md.
Frontend v6 pages are RSC reading Supabase directly via lib/queries/v6/*.ts +
lib/db.ts (postgres-js, ATLAS_DB_URL session-pooler) — NOT through FastAPI.
Related: [[project_v6_prod_readiness_2026_05_30]],
[[feedback_backend_100_before_frontend_mockups_strict]],
[[feedback_check_v6_components_first]].
