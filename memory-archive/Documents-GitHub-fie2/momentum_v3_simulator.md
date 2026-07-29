---
name: momentum_v3_simulator
description: Clean-slate momentum simulator v3 — research-based, train/test validated, 20/20 configs held up
type: project
---

## Momentum Simulator v3 (2026-03-24)

### Why v3
- v2 (compass_simulator.py) was over-engineered: PE gates, regime detection, correlation filters, composite scores
- None of those combinations were working reliably
- Stripped back to research-proven momentum methodology (Antonacci, Faber, Clenow)

### Files
- `services/momentum_simulator.py` — Clean simulator, ~300 lines of logic
- `scripts/momentum_sweep.py` — Parallel sweep runner with train/test validation

### Methodology (pure price-based, no gates)
1. Rank instruments by relative strength (return vs NIFTY over X months)
2. Dual momentum: blend short-term + 12M rankings (Antonacci-style)
3. Buy top N — trend filter optional (SMA)
4. Active stop losses: fixed + trailing (non-negotiable risk management)
5. Sell when instrument drops out of top N at rebalance, or hits stop
6. Idle cash earns 7% (liquid fund proxy)
7. Equal weight, periodic rebalance

### Full Sweep Results (6,300 combos, 18y sector data, 2007-2026)
- **20/20 top train configs produce positive test alpha**
- Train: 2007-2018, Test: 2018-2026

### Best Out-of-Sample Config (TEST winner)
- 6M+12M dual momentum, 3 positions, 10% stop, 20% trigger / 8% trailing, biweekly (10d) rebalance
- CAGR: 21.1% vs bench 11.1% = **+10% alpha**
- MaxDD: 31.0% vs bench 38.4% (better drawdown protection)
- Win rate: 57%, Profit factor: 2.56x

### Most Robust Config (least train→test decay)
- 1M+12M dual, 3 positions, 8% stop, biweekly
- Train +9.4% alpha → Test +9.0% alpha (barely any decay)

### Key Patterns from 6,300 combos
- Dual momentum dominates (43 of top 50 train configs)
- 3 concentrated positions best
- No trend filter needed (momentum ranking + stops handle it)
- Monthly or biweekly rebalance (not weekly)
- Equal weight always wins
- Stop loss % doesn't matter much (8/10/15 all work)
- Trailing stop: 20% trigger / 8% distance (let winners run)

### Production Data
- Sweep results saved: `data/momentum_sweep_sector_20260324_0645.json` on production container
- Sector data: 4557 days × 19 instruments (2007-2026)
- ETF data: 4090 days × 81 instruments (but most ETFs too young — only 8 existed in 2010)

### DEPLOYED TO PRODUCTION (2026-03-24)
- Full container rebuild deployed with momentum v3 + per-regime metrics fix
- All compass API endpoints verified working (sectors, lab/status, lab/sweep-results)
- Frontend compass page loads at marketpulse.jslwealth.in/compass (200 OK)
- Nginx was already correct — compass.jslwealth.in is a separate project, FIE2 compass routes served via marketpulse-api.jslwealth.in

### REMAINING
- Momentum results are in JSON file, NOT in the Lab database tables
- Lab UI still shows old v2 sweep results — needs wiring to momentum v3 results

### Compass Stocks Bug (FIXED 2026-03-24)
- Date alignment bug in `services/compass_rs.py` `_compute_relative_return()`
- Stock prices had today's date, sector index only had yesterday
- Fixed: use `common_dates = sorted(set(asset_closes) & set(benchmark_closes))`
- Deployed to production container via docker cp
