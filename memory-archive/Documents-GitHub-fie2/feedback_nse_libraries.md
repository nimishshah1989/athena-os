---
name: feedback_nse_libraries
description: ALWAYS prefer NSE Python libraries (jugaad-data, nsetools, nse-data) over yfinance for Indian market data — faster, no rate limiting
type: feedback
---

User has repeatedly emphasized: use NSE Python libraries instead of yfinance for Indian stock/index data.

**Why**: NSE libraries are much faster and have no rate limiting. yfinance is slow for bulk Indian stock downloads (500 stocks × 5 years takes 10+ minutes).

**Libraries to prefer**:
- `jugaad-data` — historical OHLCV for NSE stocks, fast bulk download
- `nsetools` — live NSE index/stock prices (already used in price_service.py)
- `nse-data` — alternative NSE data library

**When yfinance is acceptable**: Only as a fallback when NSE libraries don't have the specific data needed (e.g., certain ETFs, international tickers).

This feedback has been given multiple times — treat it as a hard rule for FIE2 project.
