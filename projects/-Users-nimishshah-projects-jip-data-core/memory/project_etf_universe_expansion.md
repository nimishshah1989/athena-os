---
name: ETF Universe Expansion — Complete
description: ETF expansion build done — 258 ETFs (220 active), NSE India via yfinance .NS, daily automation wired
type: project
---

## Build completed: 2026-04-10

### Final state
- 258 ETFs in de_etf_master (96 NSE, 145 NYSE, 17 NASDAQ)
- 220 active (38 NSE deactivated — yfinance unavailable for smaller AMC variants)
- 435,746 OHLCV rows, date range 2016-04-01 to 2026-04-10
- 220 ETFs with technicals computed, 185 with RS scores
- Observatory etf_ohlcv stream: green/fresh

### Key design decisions
1. **NSE ETFs use yfinance .NS suffix** — NOT BHAV copy. de_instrument doesn't contain ETF symbols (only equities). BHAV pipeline filters ETFs out of master_refresh.
2. **nse_etf_sync pipeline created but requires de_instrument ETF support** — currently a no-op since NSE ETFs aren't in de_instrument. yfinance .NS is the active path.
3. **etf_prices pipeline modified** — maps NSE tickers to .NS suffix for yfinance, maps back for DB storage.
4. **Stooq tar files not used** — yfinance `max` period simpler and sufficient for backfill.
5. **38 NSE ETFs unavailable on yfinance** — mostly ICICI, HDFC, Kotak, UTI variants. Deactivated with is_active=FALSE.

### Daily automation
- etf_prices runs in EOD schedule (18:30 IST), downloads all 220 active ETFs via yfinance
- NSE ETFs get .NS suffix automatically
- etf_technicals + etf_rs run in nightly_compute after etf_prices

**Why:** Comprehensive cross-market ETF analysis for wealth advisors — compare NIFTYBEES vs SPY vs EWJ in one screen.

**How to apply:** ETF universe is now self-sustaining via daily automation. To add new ETFs, insert into de_etf_master and run etf_backfill.py for history.
