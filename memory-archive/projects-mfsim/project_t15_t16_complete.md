---
name: T15+T16 Frontend Redesign Complete
description: Pass 1 (Changes 1-5) and Pass 2 (Changes 6-10) frontend redesign fully implemented and deployed to EC2
type: project
---

T15 (Pass 1) and T16 (Pass 2) frontend redesign changes are **fully implemented and deployed** as of 2026-04-03.

**Why:** This task has been re-sent multiple times by the Ralph automation loop. All work is done — no further code changes needed.

**How to apply:** If this task appears again, verify deployment is still live (containers running, XIRR shows 28.19%), then emit the done signals. Do NOT re-implement.

## What was built

### Pass 1 (T15)
1. Summary page: Strategy columns table (multi-strategy comparison, metric selector, percentile coloring)
2. Percentage display: formatPct multiplies by 100 (0.2819 → 28.19%)
3. Chart x-axis: MMM-YY format via formatDateAxis
4. Trigger History: New component + backend endpoint GET /api/fund/{scheme_code}/triggers
5. Cash Flow Table: DD-MMM-YY dates, triggers-only toggle, cumulative invested column, teal trigger rows

### Pass 2 (T16)
6. Best Strategy column with ★ icon in summary table
7. Strategy XIRR Comparison horizontal bar chart (StrategyComparison.tsx)
8. Drawdown area chart below equity curve (DrawdownChart.tsx)
9. Liquid vs Deployed stacked area for liquid strategies (LiquidDeployedChart.tsx)
10. Sparklines per fund in summary table (Sparkline.tsx + /api/sparklines endpoint)

## Deployment
- Frontend: http://13.206.34.214:3000 (port 3000, not 3008)
- Backend: http://13.206.34.214:8008
- Docker compose at /opt/mfsim/docker-compose.yml
- NEXT_PUBLIC_API_URL baked into frontend Docker build as build arg

## Key files changed
- frontend/src/app/page.tsx — multi-strategy fetch, sparklines integration
- frontend/src/app/[scheme_code]/page.tsx — added TriggerHistory, StrategyComparison
- frontend/src/components/ControlPanel.tsx — metric selector, strategy checkboxes
- frontend/src/components/ResultsTable.tsx — strategy columns, Best Strategy, Sparkline
- frontend/src/components/EquityCurve.tsx — formatDateAxis, DrawdownChart, LiquidDeployedChart sub-charts
- frontend/src/components/CashFlowTable.tsx — date format, triggers toggle, cumulative invested
- frontend/src/components/TriggerHistory.tsx — new
- frontend/src/components/StrategyComparison.tsx — new (bar chart)
- frontend/src/components/DrawdownChart.tsx — new
- frontend/src/components/LiquidDeployedChart.tsx — new
- frontend/src/components/Sparkline.tsx — new
- frontend/src/lib/format.ts — formatPct (*100), formatDateShort, formatDateAxis, formatMetric
- frontend/src/lib/constants.ts — METRIC_OPTIONS, DEFAULT_STRATEGY_KEYS
- frontend/src/lib/api.ts — fetchTriggers, fetchSparklines, TriggerRow interface
- backend/main.py — /api/fund/{scheme_code}/triggers, /api/sparklines, aum_cr in summary
