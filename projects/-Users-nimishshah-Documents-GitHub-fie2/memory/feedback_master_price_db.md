---
name: feedback_master_price_db
description: Never re-download existing price data — use incremental gap-fill only. Single master OHLCV database pattern, not per-feature fetches.
type: feedback
---

User frustration (2026-03-25): Stop doing full data fetches when partial data already exists.

**The rule**:
1. `index_prices` is the SINGLE master OHLCV store for all stocks, indices, and ETFs
2. Before ANY price fetch, check what already exists (`SELECT MIN(date), MAX(date) FROM index_prices WHERE index_name = :ticker`)
3. Only fetch the GAP — never re-download existing data
4. No feature (breadth, compass, sentiment) should trigger its own price download — they all READ from index_prices
5. One deep initial load (5Y all N500 + indices + ETFs), then daily incremental via EOD job only

**What went wrong**: Had 1.5 years of data for 500 stocks. Needed 2 more years. Downloaded 5 years for all 500 stocks instead of just the missing 2-year gap. Massive waste of time.

**Future architecture**: Consolidate all price fetching into a single `services/price_backfill.py` that handles gap-filling intelligently. Remove duplicate fetch logic from compass_data, backfill, eod_jobs etc.
