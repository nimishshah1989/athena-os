---
name: data-source-policy
description: "Canonical source-of-truth per asset class — Indian assets must come from NSE bhavcopy ONLY; global from Stooq/yfinance; MFs from AMFI + Morningstar API. No exceptions, no source-mixing."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: c880c6b8-5d45-4717-8ecc-d02304a45cd0
---

**Canonical data sources per asset class** (locked 2026-05-27):

| Asset class           | Source                              | Forbidden alternatives                    |
|-----------------------|-------------------------------------|-------------------------------------------|
| Indian stocks (OHLCV) | NSE bhavcopy                        | yfinance, Stooq, scraping                 |
| Indian ETFs (OHLCV)   | NSE bhavcopy                        | yfinance, Stooq                           |
| Indian indices        | NSE bhavcopy                        | yfinance, Stooq                           |
| Global (US/intl) prices, FX, commodities, yields | Stooq OR yfinance | bhavcopy (irrelevant)         |
| Mutual fund NAVs      | AMFI (NAVAll.txt + history) + Morningstar API (mfapi.in or direct MS) | yfinance, scraping AMC sites |

**Why:** Indian-asset prices from yfinance/Stooq have known divergences from NSE settlement prices (different adjustments for splits/dividends, intraday spike artifacts, missing days). Bhavcopy is the regulatory primary source. Mixing sources poisons RS calculations, signal triggers, and tracking-error math. Globals don't have a bhavcopy equivalent, so Stooq/yfinance is the correct primary.

**How to apply:**
- Before writing ANY ingest, check this table for the correct source.
- If an existing ingest violates this (e.g., uses yfinance for Indian stocks), flag it as drift and re-source.
- ETF ingest (`scripts/amfi_etf_inav_ingest.py`) is correct — uses AMFI for NAV, NSE for market close.
- ETF ISIN backfill (`scripts/backfill_etf_isin_from_nse.py`) is correct — uses NSE master CSV.
- For USDINR / DXY in `atlas_macro_daily`: yfinance is correct (global FX).
- For Indian stock ingest into `de_equity_ohlcv_*`: must be bhavcopy, not yfinance.
- For ETF OHLCV into `public.de_etf_ohlcv`: must be bhavcopy, not yfinance.
- For Nifty index series into `public.de_index_prices`: must be bhavcopy.
- FII/DII flows: NSE archives / Moneycontrol cash market summary (NSE-published is the primary; Moneycontrol mirrors NSE).

Related: [[v6-build-plan-source-of-truth]], [[backend-100-before-frontend-mockups-strict]], [[ec2-access]]
