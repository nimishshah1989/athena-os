---
name: M2 milestone state and DB contents
description: What M2 built, what's in the DB, validation results, open items for sign-off
type: project
originSessionId: 8e81118a-d2d6-4373-893a-df3d658699f4
---
**Status:** Backfill complete 2026-05-06. Validation complete 2026-05-07. Full sign-off pending 3 nightly Tier 5 runs (starts 2026-05-08).

**What M2 built:**
- `atlas_stock_metrics_daily`: 41-column daily metrics for every stock — EMAs (10/20/50/200), ATR(21), returns (1d/1w/1m/3m/6m/12m), realized vol(63), max drawdown(252), RS vs tier benchmark + gold, RS percentiles (1w/1m/3m), volume expansion, effort ratio, Weinstein/Stage1 gates, extension_pct, vol_ratio_63.
- `atlas_stock_states_daily`: 4 categorical states per stock per day (rs_state, momentum_state, risk_state, volume_state) + gate flags (history_gate_pass, liquidity_gate_pass, weinstein_gate_pass, stage1_base_qualifies) + sector/tier/compute_run_id.
- `atlas_etf_metrics_daily` + `atlas_etf_states_daily`: same structure for 100 ETFs (ticker as key, not instrument_id).
- Pipeline: pandas-ta for EMAs/ATR, numpy for vol/drawdown, psycopg2 execute_values for bulk upsert (3000-row pages), vectorised across full universe.

**Current DB row counts (as of 2026-05-07):**
- `atlas_stock_metrics_daily`: 1,383,801 rows | 750 instruments | 2016-04-07 → 2026-05-05
- `atlas_stock_states_daily`: 1,383,801 rows | 750 instruments | 2016-04-07 → 2026-05-05
- `atlas_etf_metrics_daily`: 243,657 rows | 2016-04-07 → 2026-05-05
- `atlas_etf_states_daily`: 243,657 rows | 2016-04-07 → 2026-05-05

Note: 1.38M < 2.25M because HISTORICAL_START=2016-04-07 and many stocks listed post-2016. 750 distinct instruments confirmed — row count is correct.

**Latest state snapshot (2026-05-05):**
- rs_state: Average 670K, ILLIQUID 290K, INSUFFICIENT_HISTORY 184K, Weak 129K, Consolidating 36K, Leader 35K, Strong 30K, Emerging 4.6K, Laggard 4.2K
- momentum_state (latest date): Flat 391, Deteriorating 150, Collapsing 136, INSUFFICIENT_HISTORY 49, ILLIQUID 18, Improving 3, Accelerating 1

**Validation results:**
- Tier 2 (hand metric checks): 100% pass (363 checks) — commit 1f5eb29
- Tier 3 (hand state checks): 98.33% pass (120 checks) — 2 NUMERIC(18,4) precision artifacts at Flat/Deteriorating boundary, formally accepted
- Tier 4 (cross-table consistency): 100% pass
- Tier 5 (nightly runs): NOT YET — starts 2026-05-08

**Validation code location:**
- `atlas/validation/samplers.py` — deterministic 15-stock/5-date sampler with bar_seq>=252 filter
- `atlas/validation/tier2_metrics.py` — independent NumPy hand-checks for all metrics
- `atlas/validation/tier3_states.py` — verbatim methodology hand-classifiers for all 4 states
- Validation report: `docs/validation/validation_M2_2026-05-07.md`

**Key bugs fixed during M2 validation (not production bugs — validator bugs):**
1. Sampler excluded stocks with <252 bars at sample date (new listings)
2. EMA lookback pulled pre-2016 data → added lower bound 2016-04-07 + days_back=900
3. max_drawdown hand formula used expanding max, production uses rolling(252).max()
4. _log_run() schema mismatch — fixed to write compute_run_id/stage3_stock_etf_sec/etc.

**Known precision artifact (deferred to M3):**
ema_10_ratio/ema_20_ratio stored as NUMERIC(18,4). Two stocks classified Deteriorating during backfill (r10 < r20 by <0.001%) but read back as Flat (both round to same 4dp value). Fix: migrate columns to NUMERIC(18,8) at M3 threshold calibration.

**JIP data quality issues (read-only, flagged to JIP):**
- IDFCFIRSTB 2020-05-25: close=10,010 (~530x return spike). Current price ~₹69.
- IFCI + JSWSTEEL: extreme return days from JIP adjustment methodology.

**M2 sign-off checklist (per build plan §8):**
- [x] Backfill complete
- [x] Tier 2 validation 100%
- [x] Tier 3 validation 98.33% (documented exceptions accepted)
- [x] Tier 4 cross-table consistency 100%
- [ ] 3 consecutive nightly runs (Tier 5) — started 2026-05-08, still pending
- [ ] /review /security-review /sebi /codex reviews
- [ ] Formal M2 close

**Note (2026-05-07):** Nimish explicitly overrode the M2 Tier 5 gate and started M3 in parallel. M3 code is complete. M2 Tier 5 nightly runs are running in background and will be checked separately.

**Why:** M2 Tier 5 is 3 consecutive nightly run requirement. M3 started in parallel per user decision.
**How to apply:** In future sessions, check nightly run status. Once 3 passes confirmed, run gstack reviews to formally close M2.
