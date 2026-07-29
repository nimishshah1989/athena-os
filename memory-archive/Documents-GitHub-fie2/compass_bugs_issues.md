---
name: compass_bugs_issues
description: Critical bugs, N+1 queries, data re-fetch issues, Pydantic mismatches in Sector Compass engine
type: project
---

## Critical Issues Found (2026-03-21)

### HIGH: N+1 Query Problem in compass_rs.py
- `compute_sector_rs_scores()` loops over COMPASS_SECTOR_INDICES 3x, calling `_get_index_close_map()` each time
- 81 DB queries instead of 27 per sector RS call
- Same pattern in `compute_stock_rs_scores()` — loops constituents 2x
- FIX: Cache all closes in a single dict before loops

### HIGH: Historical Data Re-fetched Daily
- `eod_jobs.py:81` calls `fetch_historical_indices_nse_sync()` daily — re-fetches 365 days of history
- Startup runs BOTH yfinance bulk AND NSE API for same indices (double write to IndexPrice)
- `daily_refresh_compass_prices()` always fetches 5 days even if data exists
- FIX: Remove daily full-history re-fetch, make compass refresh incremental

### MEDIUM: Pydantic Model Missing Fields (silently stripped)
- `TradeResponse` missing: `pnl_pct`, `tax_impact`
- `PositionResponse` missing: `volatility`, `holding_days`, `tax_type`
- `NAVResponse` missing: `max_drawdown`
- Frontend expects all these fields and renders them
- FIX: Add missing fields to Pydantic models in routers/compass.py

### MEDIUM: Model Portfolio Issues
- Position `quantity` hardcoded to 1 (weight_pct computed but not used for sizing)
- Volatility weighting falls back to equal weight if ANY sector missing data
- Silent entry failures — no log when `_get_latest_price()` returns None
- No validation of instrument price availability before trade execution

### MEDIUM: Duplicate Data Tables
- `IndexPrice` vs `CompassStockPrice` vs `CompassETFPrice` — same instruments can exist in multiple tables
- Compass uses Compass* tables, portfolio service uses IndexPrice
- Potential data divergence between tables

### LOW: O(n²) ETF→Sector Lookup
- compass_rs.py:676-679 iterates all sectors for each ETF
- FIX: Build reverse map at module load: `_ETF_TO_SECTOR = {t: sk for sk, etfs in MAP.items() for t in etfs}`

### LOW: P/E Cache Thread Safety
- Global mutable `_pe_cache` with timestamp invalidation
- If fetch fails, `_pe_cache_ts` not updated → infinite retry loop
