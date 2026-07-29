---
name: two-up-chart-layout
description: "When a chart isn't dense enough to need full container width, lay it out as two side-by-side cards (1fr 1fr) instead of one long horizontal — same vertical space, twice the information density."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 8e01e1a5-9292-458d-860a-0087a1c78a5c
---

When laying out charts in v6 pages, **if a single chart doesn't carry enough data to justify the full 1400px container width, pair it with a second related chart in a 2-up grid (`display: grid; grid-template-columns: 1fr 1fr; gap: 16px`) — same vertical space, twice the information density.**

**Why:** the locked mockup pages (especially Funds 06a and ETFs 07/07a) have long horizontal charts (drawdown, tracking-error, NAV-vs-price) that are sparse — each could share its row with a related view (e.g. drawdown + drawdown-distribution histogram, or NAV-vs-price + TE side-by-side).

**How to apply:**
- Default to **2-up** for non-dense single-metric charts (one-line series, single-axis bar chart, histogram).
- Stay **full-width** only when the chart is genuinely dense (multidim 4-lane chart, RRG bubble plot, 24-cell matrix, scatter plot with many labels, 60-month quartile calendar, AMC leaderboard with 12+ rows).
- The pattern is already used correctly in: Funds 06 (AMC leaderboard + quartile heatmap), Sectors 04 (RRG + side cards), India Pulse 02 (dispersion + concentration).
- Apply on next rev pass to: 06a (drawdown could pair with rolling-Sharpe or DD-distribution); 07a (NAV-vs-price could pair with TE chart) — both currently sequential full-width sections.

Related: [[multidim-chart-pattern]].
