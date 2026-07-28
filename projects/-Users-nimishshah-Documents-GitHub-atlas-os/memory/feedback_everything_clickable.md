---
name: everything-clickable
description: "Every card, name, ticker, sector, fund, ETF anywhere in Atlas must be clickable and route to its deep-dive page. No dead text identifiers. Cross-navigation is the default UX rule."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: c880c6b8-5d45-4717-8ecc-d02304a45cd0
---

User direction 2026-05-28: "Every card, every name, every sector etc. should be linked to be clicked to go to that respective page."

**Why:** Atlas is a research tool. The whole point of seeing a sector ranked or a stock named is to drill into it. If a user has to copy the ticker and paste it into a URL bar, the design has failed.

**How to apply** — for every page going forward, audit for these patterns and convert dead text into `<Link>`:

| Dead text → must become Link to |
|---|
| Sector name → `/sectors/[sector]` |
| Stock symbol or company name → `/stocks/[symbol]` |
| ETF ticker → `/etfs/[ticker]` |
| Fund scheme name or mstar_id → `/funds/[mstar_id]` |
| Cell label (e.g., "L 3m POS") → `/admin/composite-proposals?cell=...` or future `/cells/[cell_id]` |
| Signal call row → `/signals/[id]` (page exists; nav-hidden) OR `/calls#signal-{id}` |
| Industry name → future `/sectors/[sector]?industry=...` (TBD) |
| Threshold name → `/admin/thresholds#name` |
| Pipeline-step / table-name in admin → `/admin#tab=health&table=...` |
| Mutual-fund holdings stock → `/stocks/[symbol]` |
| Constituent stock in sector deep-dive → `/stocks/[symbol]` |

**Anti-patterns to reject in code review:**
- `<span>{stock.symbol}</span>` next to data — must be `<Link href={\`/stocks/\${stock.symbol}\`}>`
- A hovered cursor pointer that doesn't navigate (visual cue lie)
- Modal-on-click instead of route-on-click (modal is fine for tooltips; routes are for navigation)
- Tooltip-only context (must ALSO route)

**Style for clickable identifiers:**
- Hover state: subtle underline or color shift (the Atlas teal `#1D9E75`)
- No giant link styling (we don't want a sea of blue)
- The whole row of a table can be clickable when the primary identifier is a tickerable thing

Related: [[atlas-explainer-flywheel]] (the link itself is part of the explainer chain — click takes you to the page where the explanation lives)
