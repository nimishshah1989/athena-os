---
name: project_sp10_state
description: SP10 Intraday Live Panels — shipped and live on atlas.jslwealth.in
metadata: 
  node_type: memory
  type: project
  originSessionId: cb74b01c-0aea-4d84-a3c3-dd7e6d2d7b4e
---

SP10 Intraday Live Panels is fully shipped and live as of 2026-05-13.

**Why:** Adds real-time market data panels to the frontend — Nifty strip, sector movers, live stock prices in screener, and per-stock live badge.

**What shipped:**
- Migration 058 applied on compute EC2 (13.206.34.214): `atlas_nifty_intraday` table, `return_since_open` column on `atlas_stock_metrics_intraday`, `mv_rs_intraday` recreated with `return_since_open`
- 3 new FastAPI endpoints on `/api/v1/intraday/`: `/nifty`, `/sector-movers`, `/prices`
- Frontend components: `IntradayNiftyStrip` (Regime page), `IntradaySectorMovers` (Sectors page), `IntradayStockBadge` (stock detail page), live price optional column in StockScreener
- StockScreener refactored from 960→605 lines (screener-utils, ScreenerFilterPanel, CTSTimingCell, SignalCell extracted)
- 51 tests pass

**Deploy architecture:**
- Compute EC2 (13.206.34.214): `atlas-internal-recompute.service` runs on port 8002 and includes intraday router (THIS is what the frontend calls)
- `atlas-api.service` runs on port 8020 (separate — NOT what frontend calls)
- Frontend .env.local: `ATLAS_INTERNAL_API_BASE_URL=http://13.206.34.214:8002` — this is correct
- When deploying new intraday endpoints: restart BOTH `atlas-internal-recompute` AND `atlas-api` services

**Data state:** Nifty intraday table is empty until Kite session is active and ingester runs. Components gracefully show "pre-market" state. Data will populate on next trading day when Kite token is refreshed.

**How to apply:** When deploying future intraday changes, restart `atlas-internal-recompute` (port 8002) not just `atlas-api` (port 8020) — the frontend routes through 8002.
