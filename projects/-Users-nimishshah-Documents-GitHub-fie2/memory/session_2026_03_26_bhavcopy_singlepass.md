---
name: session_2026_03_26_bhavcopy_singlepass
description: Bhavcopy master OHLCV downloader + single-pass sector breadth engine + sector detail UI
type: project
---

## 2026-03-26 Session: Master OHLCV + Single-Pass Breadth

### What was done

1. **NSE Bhavcopy downloader** (`services/bhavcopy.py`)
   - Downloads daily equity bhavcopy ZIPs from NSE archives
   - Supports old format (≤2023) and new format (2024+) with auto-detection
   - Stores ALL traded securities (EQ, ETFs, bonds) — not just equity
   - Bulk upserts into `index_prices` table with ON CONFLICT handling
   - Gap-fill mode: skips dates already having ≥1000 stocks
   - Rate-limited (1.5s delay) to avoid NSE blocking
   - API: `POST /api/data/bhavcopy/backfill?days=1825`, `GET /api/data/coverage`

2. **Single-pass sector breadth** (`services/breadth_engine.py`)
   - New `_single_pass_breadth()` replaces the O(N×M) per-sector approach
   - Loads ALL stock prices in ONE query, computes indicators ONCE per stock
   - Groups by sector using IndexConstituent, stores overall + all sectors
   - 588 sector indicators computed in ~30 seconds (was hours before)
   - Functions: `_compute_all_stock_indicators()`, `_aggregate_sector_counts()`

3. **Sector detail UI** (`SectorBreadthDetail.tsx`)
   - Charts + Stocks toggle tabs
   - Stocks tab: passing/failing per indicator with collapsible table
   - 6 indicator selector buttons (EMA21, EMA200, RSI 50/40, 52W H/L)
   - `useBreadthStocks` hook now supports optional `sector` param

4. **Removed sector sentiment grid** — redundant with sector breadth heatmap

### Key commits
- `2a04acb` feat(data): add NSE Bhavcopy downloader for master OHLCV database
- `b4f3047` feat(breadth): single-pass sector breadth computation
- `3e673d9` feat(breadth): inline sector detail with stocks table, remove sector sentiment
- `b4804be` feat(data): parallelize bhavcopy backfill with ThreadPoolExecutor

### Data status (in progress)
- Parallel backfill deployed and triggered (5 workers)
- Before parallel: 165K records, 268 trading days, 717 tickers
- Target: ~3.75M records, ~1250 trading days, ~4500+ tickers
- NSE bhavcopy URL patterns:
  - Old: `nsearchives.nseindia.com/content/historical/EQUITIES/YYYY/MMM/cmDDMMMYYYYbhav.csv.zip`
  - New: `nsearchives.nseindia.com/content/cm/BhavCopy_NSE_CM_0_0_0_YYYYMMDD_F_0000.csv.zip`
  - Old works ≤mid-2024, new works from 2024-01-03+

### Data consolidation (COMPLETED)
- All compass reads (RS, data, history) now use `index_prices` — no more CompassStockPrice/CompassETFPrice
- Startup backfill uses bhavcopy + NSE API for indices — no yfinance for stocks/ETFs
- Daily EOD uses bhavcopy single-day + nsetools live — no yfinance for stocks/ETFs
- Compass intraday refresh only updates index prices via nsetools (stock RS is EOD)
- Net -110 lines of code removed
- Commit: `4940cf3` refactor(data): consolidate all price reads to master index_prices table

### Remaining
- Add ANTHROPIC_API_KEY to production .env for AI commentary
- Phase 5 cleanup: deprecate CompassStockPrice/CompassETFPrice tables, yfinance bulk functions
- Run historical breadth backfill
