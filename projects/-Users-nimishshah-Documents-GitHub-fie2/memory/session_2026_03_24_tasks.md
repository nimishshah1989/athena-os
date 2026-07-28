---
name: session_2026_03_24_tasks
description: Pending tasks for MarketPulse — pulse drill-down, portfolio allocation, sentiment gauges, sentiment actionables
type: project
---

## Pending Tasks (2026-03-24)

### Task 1: Pulse Index Drill-Down
**Status:** DONE — deployed 2026-03-24
**What:** Each index row in the Pulse page gets a (+) button. Click → expands to show constituent stocks with price, change%, weight.
**Backend:** New endpoint `GET /api/indices/{name}/constituents` — calls existing `fetch_nse_index_constituents()` in price_service.py (line ~775)
**Frontend:** Modify `web/src/components/index-table.tsx` — add expand state per row, lazy-fetch constituents on click, render sub-table. New hook `use-index-constituents.ts`. New type `Constituent` in types.ts.
**Key files:** routers/indices.py, web/src/components/index-table.tsx, price_service.py (already has fetch_nse_index_constituents)

### Task 2: Portfolio Allocation Overhaul
**Status:** DONE — deployed 2026-03-24
**What:** Replace current dual-pie + asset class view with a sector × time period table. LIQUIDBEES/liquid funds = "Cash". Show how sector allocation shifts over 12 months. Table: rows=sectors, cols=time snapshots, current composition highlighted.
**Key files:** web/src/components/pms/pms-allocation.tsx, routers/pms.py (sector-history endpoint already exists), web/src/lib/pms-api.ts (fetchSectorHistory exists)
**Note:** Backend `GET /api/pms/{id}/sector-history` already returns snapshots with sector allocations over time. Frontend just needs rewrite from pie+heatmap+stacked-bar to a clean table.

### Task 4: Sentiment Gauge Visuals
**Status:** DONE — deployed 2026-03-24
**What:** Add mini gauge/clock SVGs to each of the 5 indicator cards (Short-Term, Broad Trend, A/D, Momentum, Extremes). Currently just shows a number + color. Also enrich the 20-week composite score chart — make it bigger, add more data (layer breakdown? zone bands?).
**Key files:** web/src/app/sentiment/page.tsx (indicator cards at lines 177-192), web/src/components/sentiment/CompositeGauge.tsx, web/src/components/sentiment/SentimentHistoryChart.tsx

### Task 5: Sentiment Actionables Page
**Status:** DONE — deployed 2026-03-24
**What:** New section within sentiment page identifying top sectors and top stocks based on combined short-term + long-term indicators. Should tie into compass recommendations. Use sentiment scores + compass RS scores to rank.
**Backend:** May need new endpoint combining sentiment + compass data, or compose on frontend from existing endpoints (GET /api/sentiment/sectors + GET /api/compass/sectors).
**Key files:** web/src/app/sentiment/page.tsx, web/src/components/sentiment/SectorSentimentGrid.tsx, routers/sentiment.py

### Task 7: Broad Market Constituents Missing
**Status:** NOT DONE — carry to next session
**What:** Broad market indices (NIFTY 50, NIFTY 100, NIFTY 200, NIFTY NEXT 50, MIDCAP 50/100/150, SMALLCAP 50/100/250, etc.) have NO constituents in the IndexConstituent table. Only sector/thematic indices were populated by the EOD job (`refresh_sector_constituents` in routers/recommendations.py lines 402-451 — it only iterates `SECTOR_INDICES_FOR_RECO`).
**Fix needed:**
1. Add broad market index names to the EOD constituent refresh loop (or create a separate list)
2. The NSE API `fetch_nse_index_constituents("NIFTY 50")` works — just needs to be called for broad indices too
3. This runs from EC2 where NSE API is geoblocked — may need the local India-IP backfill script instead
4. Alternative: use the NIFTY 500 superset (already in DB with 500 stocks) and filter by membership — but we don't have per-index membership data without the NSE API

**Also pending:** Slow page loads investigation beyond the live indices cache fix:
- /api/indices/live first cold call is still ~15s (nsetools failing + 6 period DB queries)
- Compass /sectors takes ~1.5s
- Consider adding caching to compass endpoint too

### Task 6: ETF Mapping
**Status:** Plan created, execution pending
**See:** etf_index_mapping_plan.md for full mapping table
**Action:** Add unmapped ETFs to compass ETF universe in services/compass_history.py, add missing indices to constants.ts, run ETF sweep overnight
