---
name: excess_calmar_v2_redesign
description: Excess Calmar optimization — idle capital earns returns (liquid/Nifty), loosen gates for more entries
type: project
---

## Status (2026-03-24) — ALPHA CONFIRMED, PRODUCTION SWEEP RUNNING

### Key Findings (432-config sweep, 18y data, 19 sectors)
- **Best config**: benchmark idle + 2_of_3 gates + 6M RS + 4 positions → 14.0% CAGR vs 10.1% bench = **+3.9% alpha**
- **205 of 432 configs produce positive composite score**
- All top 20 configs use `benchmark` idle mode
- `2_of_3` gates dominate top 50 (38 vs 12 for all_3)
- `6M` RS period best (27 of 50), then 1M (14)
- 4 concentrated positions preferred (29 of 50)

### Train/Test (60/40 split, 10.8y train / 7.2y test)
- 6M RS configs robust: Train +6.8% alpha → Test +0.7% alpha (holds up!)
- 1M RS configs overfit: Train +7% alpha → Test -2% alpha (fails out of sample)
- **Winner: benchmark, 2_of_3, 6M, p4, minRS=1.0, hold=5**

### Root Cause of Prior Failures
- Sector index data in DB had only 262 days (1 year) — simulator needs 273+ minimum
- `.npz` cache was wiped on container rebuilds (no Docker volume mount)
- Fixed: added `compass_data` volume to docker-compose.yml
- Downloaded 4557 days (2007-2026) of sector data from yfinance

### Data Available
- Sectors: 4557 days × 19 sectors (2007-09-17 to 2026-03-20)
- ETFs: 4090 days × 81 instruments (2010-01-03 to 2026-03-23)
- Stocks: 4826 days × 530 instruments (2007-01-01 to 2026-03-23)

### Files Changed This Session
- services/compass_simulator.py — idle_mode/gate_mode in both param grids + focused grid
- services/compass_lab.py — persist + reconstruct with new params
- models.py — idle_mode/gate_mode columns on CompassRegimeConfig
- routers/compass_lab.py — API returns idle_mode/gate_mode
- web/src/lib/compass-api.ts — TypeScript types
- web/src/components/compass/LabDashboard.tsx — UI shows Idle/Gates params
- docker-compose.yml — compass_data volume for persistent cache
- DB migration: ALTER TABLE compass_regime_configs ADD COLUMN idle_mode, gate_mode
