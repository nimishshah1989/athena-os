---
name: compass_architecture
description: Sector Compass data flow, refresh schedule, model portfolio engine architecture
type: project
---

## Data Flow Architecture (as of 2026-03-21)

### Tables
- `IndexPrice` — sector index OHLCV (yfinance + NSE API), used by portfolio/sentiment/alerts
- `CompassStockPrice` — constituent stock OHLCV (yfinance), used by compass RS engine
- `CompassETFPrice` — ETF OHLCV (yfinance), used by compass RS engine
- `IndexConstituent` — sector index constituents (NSE API), ticker + weight
- `CompassRSScore` — persisted RS scores per date/instrument
- `CompassModelState` — open/closed portfolio positions
- `CompassModelTrade` — trade log (BUY/SELL with reason, P&L, tax)
- `CompassModelNAV` — daily NAV snapshots (model + benchmark + FM)

### Refresh Schedule
- **Startup**: Full 1Y backfill (indices, ETFs, stocks, constituents)
- **Every 15 min** (market hours): Compass prices refresh (5d window), RS recompute
- **3:30 PM IST**: EOD index prices (nsetools live)
- **3:40 PM IST**: EOD compass rebalance (exit checks, new entries, NAV update)
- **RS Cache**: 15-min TTL in routers/compass.py
- **P/E Cache**: 24h TTL in compass_rs.py

### Model Portfolio Engine (compass_portfolio.py)
- 3 types: etf_only, stock_etf, stock_only
- Max 6 positions, inverse-volatility weighted (cap 25% per position)
- Entry: action=BUY, RS>0, not held, instrument price available
- Exit: action=SELL/AVOID, stop-loss (8% index, 12% stock), trailing stop (10% from +15% peak)
- Tax-aware: LTCG (≥365d, 12.5%) vs STCG (<365d, 20%)
- NAV: base 100, benchmarked vs NIFTY and FM portfolio
- Rebalance: weekly check (runs daily, checks day_of_week)
- Initial capital: ₹1 Cr (hardcoded)

### Gate-Based Decision Engine
- G1: absolute_return > 0 (is it going up?)
- G2: rs_score > 0 (is it beating benchmark?)
- G3: momentum > 0 (is it getting stronger?)
- 8 combinations → 7 actions: BUY, HOLD, WATCH_EMERGING/RELATIVE/EARLY, AVOID, SELL
- Volume override: DISTRIBUTION on BUY → downgrade to HOLD
- Market regime override: BEAR → cap at HOLD; CORRECTION + weak volume → HOLD
