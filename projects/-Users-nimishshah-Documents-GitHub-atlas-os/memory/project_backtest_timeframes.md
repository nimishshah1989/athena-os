---
name: Multi-timeframe backtest — pending run
description: 3Y/5Y/7Y backtest windows coded but not yet seeded; also covers why Leader stocks underperform
type: project
originSessionId: 5474097b-6a48-4ba8-b125-dfe2f86af340
---
## Status: code merged to local main, NOT pushed to GitHub, NOT run on EC2

The multi-timeframe backtest seeding is ready to run but was parked.

**Commit:** `9fb7a00` — "feat(backtest): multi-timeframe seed — 3Y, 5Y, 7Y windows"

### What was changed

- `atlas/simulation/backtest/report.py`: added "3y", "5y", "7y" to `BacktestType` / `_VALID_TYPES`
- `scripts/seed_strategy_backtests.py`: replaced `--start`/`--end` CLI args with `--windows 3y,5y,7y` (default: all three); `run_strategy_backtest()` now accepts `backtest_type` param

### Windows (fixed right-anchor at 2025-12-31)

| Window | Start | End |
|--------|-------|-----|
| 3y | 2023-01-01 | 2025-12-31 |
| 5y | 2021-01-01 | 2025-12-31 |
| 7y | 2019-01-01 | 2025-12-31 |

Data goes back to 2016-04-07 so all three are fully supported.

### To run (after pushing to GitHub so EC2 can pull)

```bash
# On EC2 (sequential, ~2.5h total)
cd /home/ubuntu/atlas-os && source .venv/bin/activate
python scripts/seed_strategy_backtests.py              # all 3 windows × 15 strategies
python scripts/seed_strategy_backtests.py --windows 3y # just one window
```

### Why Leader stocks underperform (design insight, not a bug)

The RS system grades stocks on TRAILING momentum. A stock earns "Leader" only after it has already significantly outperformed Nifty 500. The entry signal fires on day 1 of Leader status — meaning you're buying after the move has already happened.

- `stocks_momentum_aggressive` (sharpe=-2.29, CAGR ~1.85%) — most concentrated (15 slots), most selective (Leader-only), buys the most "already-moved" stocks
- `stocks_momentum_conservative` (sharpe=-0.05, CAGR ~6%) — broader state filter (Leader+Strong+Emerging) catches momentum earlier

**Root causes of negative alpha:**
1. Entry at peak momentum (buy-high problem)
2. 2022 was brutal globally — high-momentum stocks fell hardest in rate-hike cycle
3. Cash drag from idle slots (only 15 positions, often fewer Leaders available)
4. ~2% annual transaction cost drag (4,114 entries × 0.2% round-trip)

**What would improve it:** enter at Emerging/Strong state (before Leader), or fixed 20-60 day holding period rather than state-transition exit.

**Why:** User asked to park and focus on core platform tool. Will revisit.
**How to apply:** When resuming, push commit 9fb7a00 to GitHub, pull on EC2, then run the seed command above.
