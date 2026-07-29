---
name: SP04 Stage 4c — Live Monitoring + Auto-Revert + Hit-Rate shipped
description: Realized-IC tracker, hit-rate primitive, and auto-revert detector on top of Stage 4a's auto-optimization loop. Stage 4c gives the system its safety telemetry.
type: project
originSessionId: b03c7f67-fe54-4643-8fc6-c6dce97c8b0f
---
**Ran:** 2026-05-12
**Plan:** docs/phase2/plans/2026-05-12-sp04-stage4c-live-monitoring.md
**Commits:** 8058778 (migration 041), 4af9262 (monitoring module + CLIs), 47b4462 (admin API + frontend), 271d551 (unified nightly script)

## What shipped

### Backend
- **Migration 041** — three audit tables:
  - `atlas_signal_weights_live_perf` — per (weight_set_version, as_of_date) realized IC + ratio vs predicted
  - `atlas_stock_hit_rate_daily` — per (instrument_id, date, lookback_window) hit-rate vs tier-median forward return
  - `atlas_weight_revert_log` — audit row per auto-revert event
- **`atlas.intelligence.conviction.monitoring`** sub-package:
  - `live_ic_tracker.py` — realized IC of every active composite. Reuses SP01 `compute_ic_over_window`, builds composite via the same percentile-rank-then-weight method as Stage 3 composer
  - `hit_rate_engine.py` — per-stock hit-rate primitive over 20-day lookback × 21-day forward horizon
  - `drift_detector.py` — flags active sets with `ic_ratio < 0.5` for 60 consecutive days; `execute_revert` is atomic (bookend current → restore previous → audit row)
  - `persistence.py` — UPSERT batch helpers for all three tables
- **CLIs:** `scripts/track_live_ic.py`, `scripts/compute_hit_rates.py`, `scripts/check_weight_drift.py`. All accept `--as-of` and `--persist` (or `--apply` for drift); all anchor `as_of` defaults to `LEAST(metrics_max, ohlcv_max)`.
- **Unified orchestrator:** `scripts/run_atlas_intelligence_nightly.sh` chains Stage 4a + 4c + Validator A+B + MV refresh. Single cron entry installs the full pipeline.

### API
- `GET /api/admin/weight-performance` mounted on `internal_recompute:app` (port 8002). Returns active sets with 30-day realized-IC trail + days-below-threshold + in_revert_territory flag, plus recent reverts. Same dual auth (JWT role=admin OR ATLAS_INTERNAL_SECRET bearer).

### Frontend
- `frontend/src/lib/queries/weight_performance.ts` — `getActiveWeightSetsWithTrail`, `getRecentReverts`, `getHitRateForStock`
- `RealizedICSparkline.tsx` — Recharts line chart with red 0.5×predicted threshold line + grey predicted line
- `RevertBanner.tsx` — top-of-page alert when any auto-revert fired in last 24h
- `HitRateRow.tsx` — single-line hit-rate summary on stock deep-dive (colored green/red ≥60% / ≤40%)
- `/admin/weight-performance` — new page with status pills (OK / Watch / Revert imminent / Bootstrap)
- `/admin/composite-proposals` — now shows RevertBanner at top
- `/stocks/[symbol]` deep-dive — HitRateRow slotted into the breakdown panel above the per-signal bars

## First live-IC measurement (anchor 2026-04-09, lookback 90d, horizon 21d)

| Tier | Realized IC | Predicted IC | Ratio | Status |
|---|---|---|---|---|
| T1 mega-cap | +0.0854 | +0.0511 | 1.67 | Outperforming |
| T2 large-cap | +0.0572 | +0.0068 | **8.41** | Massively outperforming — predicted IC was very low |
| T3 upper-mid | +0.0922 | +0.0538 | 1.71 | Outperforming |
| T4 lower-mid | **-0.0325** | +0.0268 | **-1.21** | Anti-predictive — would auto-revert if sustained 60d |
| T5 small-cap | +0.0476 | +0.0413 | 1.15 | Slightly outperforming |

T4 is the canary the Stage 4c system is built for. After 60 days of consecutive ratio < 0.5, auto-revert would restore the previous weight set. Currently we have 1 day of data so revert detector returns 0 findings — correct.

## Tests

- 11 unit + integration tests in `tests/intelligence/conviction/monitoring/` — green on EC2 (unit pass, some integration skip due to bootstrap window)
- 3 endpoint tests via FastAPI TestClient inherit auth pattern from Stage 4a (`ATLAS_AUTH_DISABLED=true` at module import)
- Synthetic drift-trigger test: insert 60 days of bad perf rows → detector fires; insert 59-of-60 → detector skips (one-day-above-threshold guard)

## Known issues / open

1. **Hit-rate batch is slow** — currently loads price matrix per-instrument (728 calls). Should hoist load_price_matrix out of the inner loop. Stage 4d optimization. Acceptable for nightly cron (~15 min runtime).
2. **OHLCV validation lag** — `data_status='validated'` is stuck at 2026-04-09 due to JIP-side EOD pipeline HTTP 500s every weekday since 2026-05-05. Atlas methodology pipelines run on raw OHLCV and are fresh through 2026-05-11; only Stage 4a/4c IC anchoring is affected. **Action: ask Nimish to fix the JIP `eod` pipeline at `/home/ubuntu/jip-data-engine/`.** The auto-healer (`agent3_cron.log`) is itself broken.
3. **Auto-revert disabled until 60 days of data accumulate** — drift detector runs in dry mode (no `--apply`). Promote to `--apply` once any active set has 60+ rows in `atlas_signal_weights_live_perf`.

## Nightly orchestration (script written, NOT yet installed in cron)

`scripts/run_atlas_intelligence_nightly.sh` chains:
1. `compute_conviction.py --persist` (Stage 3)
2. `recompute_signal_ic.py --persist` (Stage 4a)
3. `generate_weight_candidates.py --persist` (Stage 4a)
4. `track_live_ic.py --persist` (Stage 4c)
5. `compute_hit_rates.py --persist` (Stage 4c)
6. `check_weight_drift.py` (Stage 4c — dry mode)
7. `run_validator.py --scope sensibility` (Validator A)
8. `run_validator.py --scope schema` (Validator B)
9. `REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_top_conviction_daily`

Install command in the script header. After running M5 (UTC 21:30), this script should fire at UTC 22:00.

## Production URLs

| What | URL | Status |
|---|---|---|
| `/stocks/[symbol]` hit-rate row | https://atlas.jslwealth.in/stocks/PFOCUS | Will render once `atlas_stock_hit_rate_daily` is populated (script run in progress) |
| `/admin/composite-proposals` revert banner | https://atlas.jslwealth.in/admin/composite-proposals | Renders empty banner today (no reverts yet) |
| `/admin/weight-performance` | https://atlas.jslwealth.in/admin/weight-performance | Renders 5 active sets, sparkline trails are 1 point each today; will fill out over days |

## Stage 4b (deferred) — per-regime weight conditioning

The `regime` column is already on every Stage 4a + 4c table. Stage 4b would:
1. Compute regime per `as_of_date` via existing `mv_current_market_regime`
2. Loop over (tier × regime) instead of just tier in `generate_weight_candidates` and `track_live_ic`
3. Surface per-regime breakdown in `/admin/weight-performance`

Defer until 4c has 60 days of single-regime data to validate the loop works end-to-end.
