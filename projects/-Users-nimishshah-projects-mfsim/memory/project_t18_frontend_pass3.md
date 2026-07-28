---
name: T18 Frontend Pass 3
description: Frontend redesign — unified filter bar, strategy rankings matrix, AUM removal, sticky headers
type: project
---

T18 frontend pass 3 deployed to EC2 on 2026-04-04.

Changes:
- Unified filter bar on fund detail page (period/indicator/threshold) — all sections share one filter
- Strategy Rankings matrix on summary page — 10×10 grid showing rank distribution by XIRR
- AUM column removed from summary table (data unavailable)
- Sticky table headers and fund name column on summary table
- Sticky control panel with strategy selector

**Why:** Per-section duplicate filters were confusing; ranking matrix gives cross-strategy insights at a glance.

**How to apply:** Fund detail components (StrategyComparison, EquityCurve, ScenarioGrid, CashFlowTable, TriggerHistory) now accept indicator/threshold/period as props from parent page. Summary page fetches ALL 10 strategies for ranking matrix, then filters to selected strategies for main table.
