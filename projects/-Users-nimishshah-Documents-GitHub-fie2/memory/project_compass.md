---
name: Sector Compass Feature
description: RS momentum + model portfolio system built for FIE2 — separate from existing pulse/sentiment
type: project
---

## Sector Compass — Built 2026-03-21

### What it is
Interactive 2x2 scatter/bubble chart showing all NSE sector indices + ETFs plotted by RS Score (x) vs Momentum (y) with P/E as bubble size. Click any sector → drill down to constituent stocks on same chart. Includes autonomous model portfolio that paper-trades based on RS signals.

### Architecture (fully separate from existing pulse)
**Backend:**
- `services/compass_data.py` — price backfill for stocks/ETFs into compass-specific tables
- `services/compass_rs.py` — 3-indicator RS engine (score, momentum, volume)
- `services/compass_portfolio.py` — model portfolio rules engine (entry/exit/stops)
- `routers/compass.py` — all API endpoints under `/api/compass/`

**Frontend:**
- `web/src/app/compass/page.tsx` — main page with Sectors + Model Portfolio tabs
- `web/src/components/compass/` — SectorBubbleChart, StockDrillDown, ActionSummary, ModelPortfolioDashboard
- `web/src/hooks/use-compass.ts` — SWR hooks
- `web/src/lib/compass-api.ts` + `compass-types.ts`

**DB Tables:** compass_stock_prices, compass_etf_prices, compass_rs_scores, compass_model_state, compass_model_trades, compass_model_nav

**Scheduler:** 3:40 PM IST daily (after EOD prices at 3:30 and sentiment at 3:35)

### RS Engine — 3 Numbers
1. RS Score (0-100): percentile rank of relative return vs NIFTY across sector universe
2. Momentum: RS score change over 4 weeks
3. Volume: 20d vs 60d avg + price direction → ACCUMULATION/WEAK_RALLY/DISTRIBUTION/WEAK_DECLINE

### Action mapping: Quadrant + Volume → BUY/ACCUMULATE/WATCH/HOLD/SELL/AVOID

### Tests: 55 tests in tests/test_compass.py — all green
