---
name: Frontend V2 Design — 3 Priority Pages
description: Approved design spec for Universe Explorer, Fund 360, and Dashboard redesign with Claude API narratives, AUM bubbles, benchmark curves
type: project
---

## Approved Design (2026-03-28)

User explicitly approved this design. Focus on 3 pages first, then remaining 2.

### Universe Explorer 2.0 — "Intelligence Map"

1. **Smart Filters Sidebar** (left, 240px collapsible):
   - AUM sliders: <100Cr, 100-500Cr, 500-2000Cr, >2000Cr (toggle buttons)
   - Multi-select dropdowns with checkboxes for: Category, AMC, Broad Category
   - Lens score range sliders (0-100) for any lens
   - Quick presets: "Large Cap Leaders", "Low-Cost Alpha", "Fortress Funds"
   - Active filters as removable chips

2. **Scatter with real AUM bubbles** (center):
   - Bubble size = AUM from fund_holdings_snapshot
   - Quadrant annotations with fund counts per quadrant
   - Density heatmap underlay for crowded areas
   - Click bubble → inline Fund Card (not navigate away)

3. **Live Intelligence Panel** (right, 280px):
   - Top 5 funds in current view (by selected lens)
   - "Undercurrents" section — Claude-generated insight about current filter set
   - Quick stats: avg return, avg risk, median AUM

4. **Temporal linking**: Period buttons switch scatter from lens scores to returns (return_1y, return_3y, etc.) on X-axis

### Fund 360° 2.0 — "Fund Intelligence Dossier"

1. **Fund Search → Card Grid** with Smart Buckets row at top
2. **Fund Detail**:
   - Hero: name, AMC, AUM, age, TER, risk level, headline_tag, color-coded tier tags
   - Claude Narrative Card: AI 3-4 sentence brief (Haiku 4.5 for top 1000, ~$1.50 budget)
   - Left column: NAV chart with category returns + Nifty 50 overlay, period pills, return bars
   - Right column: Six Lens Cards (clickable, expand inline with sub-metrics)
   - Full-width: Holdings (sorted, weight bars), Sectors (stacked bar + MarketPulse quadrants), Asset Allocation (donut with cap splits), Risk Profile (hero cards), Peer Positioning

### Dashboard 2.0 — "Pulse Command Center"

1. Morning Briefing Hero (regime, Nifty price, one-line summary)
2. Smart Buckets Row (6 functional cards with live counts)
3. 4 Metric Cards (Nifty, Sentiment, Breadth, Universe health)
4. Two-column: Sector Compass mini + Strategy alerts
5. Top Funds carousel with lens tabs

### Backend Changes Required

1. Fix holdings sort: ORDER BY weighting_pct DESC NULLS LAST
2. Add aum to universe endpoint (JOIN fund_holdings_snapshot)
3. New GET /api/v1/funds/{id}/asset-allocation
4. New GET /api/v1/funds/{id}/narrative (Claude API, cached)
5. New GET /api/v1/market/nifty (bridge to MarketPulse)
6. Enrich peers with lens scores and returns

### Claude API Budget
- Top 1000 funds pre-generated narratives
- Haiku 4.5: ~$0.0014/fund = ~$1.40 for 1000
- Cached in DB, regenerated weekly
- On-demand for remaining funds when viewed
