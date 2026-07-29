---
name: compass_agentic_lab
description: Architecture of the agentic Lab v2 — Calmar composite, train/test split, bootstrap, overnight sweep
type: project
---

## Agentic Lab System v2 (redesigned 2026-03-22)

### Key Design Decisions (from Nimish)
- **Fixed guardrails**: stop_loss=8%, trailing_trigger=15%, trailing_stop=10% — NOT optimized
- **No arbitrary weights**: gate-based AND/OR logic, not weighted scoring
- **No discovered rules system**: removed — regime configs convey what's needed
- **Calmar ratio as optimization target**: CAGR / MaxDrawdown, not Sortino
- **Diversification mandatory**: 6-12 positions minimum
- **PE as capital allocation** (not filter): VALUE→1.3x, FAIR→1.0x, STRETCHED→0.6x
- **Cash reserve**: regime-dependent variable (0-30% in steps of 5)
- **Sector correlation filter**: block entry if >0.8 correlated with existing holdings
- **Train/test split**: 2007-2020 train, 2021-2026 test (40/60 weighting)
- **Bootstrap validation**: 500+ resamples for confidence intervals
- **Min 30 trades per regime** for statistical significance

### Composite Score Formula
```
Composite = Calmar × DivBonus × ConsistencyBonus × DrawdownPenalty
DivBonus = avg_positions_held / max_positions
ConsistencyBonus = min(regime_cagrs) / max(regime_cagrs)
DrawdownPenalty: <15% → 1.0, 15-25% → 0.8, 25-35% → 0.5, >35% → 0.2
```

### Components
- `services/compass_simulator.py` — Stateless NumPy simulator with fixed guardrails + new variables
- `services/compass_lab.py` — Sweep orchestrator with train/test split + bootstrap + Calmar composite
- `services/compass_autonomous_trader.py` — Fully autonomous daily trader
- `services/compass_history.py` — Downloads/caches NIFTY + sector prices from yfinance as .npz
- `routers/compass_lab.py` — Monitoring API endpoints
- `scripts/overnight_lab_sweep.py` — Overnight program: full grid + meta-experiments + bootstrap

### Parameter Grid (v2): 21,168 combos
- rs_period: 1M, 3M, 6M, 12M (4)
- max_positions: 6,7,8,9,10,11,12 (7)
- min_rs_entry: 0,1,2,3,4,5 (6)
- min_holding_days: 5, 10, 20 (3)
- pe_allocation_mode: equal, pe_weighted, pe_gated (3)
- cash_reserve_pct: 0,5,10,15,20,25,30 (7)
- correlation_filter: true/false (2)

### First Overnight Sweep Results (2026-03-22, 1.9 hours)
- **Data**: 4,557 days × 21 sectors (Sep 2007 → Mar 2026)
- **Train**: 3,267 days (2007-2020), **Test**: 1,290 days (2021-2026)
- **Meta winner**: pe_weighted (composite 0.0829 vs 0.0696 baseline)
- **Top configs converge to**: 1M RS, 6 positions, 0 min RS, 20 hold days, pe_gated, 15-30% cash
- **Regime results**: BULL Calmar=1.67 CAGR=15.5%, CAUTIOUS Calmar=13.7, CORRECTION Calmar=3.8
- **BEAR**: insufficient trades (<30) for statistical significance
- **Bootstrap concern**: only 21-25% of resamples had positive Calmar — strategy not robust across random samplings
- **Cash reserve insight**: 15% = best Calmar (0.378), 0% = best CAGR but worst drawdown

### Production
- Server: 13.206.34.214, container `marketpulse`, port 8004
- Env file: `~/apps/marketpulse/.env` (RDS database)
- URL: marketpulse.jslwealth.in
- Docker doesn't include `scripts/` dir — overnight script run via `docker cp` + `docker exec`

### Tests
- 50 unit tests in tests/test_compass_lab.py
- Covers: simulator, gates, regimes, grid gen, sweep, extraction, composite score, train/test split
- Note: full test suite has a pre-existing hang in some price-related test (not compass-related)
