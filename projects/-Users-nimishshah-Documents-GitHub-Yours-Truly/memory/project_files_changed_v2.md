---
name: Intelligence v2 Files Created/Changed
description: Complete list of files created or modified during intelligence v2 rewrite for quick reference when resuming work
type: project
---

## Backend Files Created (new)
- `intelligence/engines/__init__.py` — CLI runner, `run_all_engines()`, `main()`
- `intelligence/engines/__main__.py` — enables `python -m intelligence.engines`
- `intelligence/engines/utils.py` — `sanitize_for_json()` Decimal→int/float converter
- `intelligence/engines/menu_engine.py` — 6 menu analyses (~400 lines)
- `intelligence/engines/customer_engine.py` — 5 customer analyses (~330 lines)
- `intelligence/engines/operations_engine.py` — 6 ops analyses (~350 lines)
- `intelligence/engines/cost_engine.py` — 5 cost analyses (~365 lines)
- `intelligence/engines/connector.py` — weekly brief generator (~310 lines)
- `routers/intelligence_v2.py` — v2 API endpoints (~285 lines)
- `database/schema_v4_weekly_briefs.sql` — weekly_briefs table migration

## Backend Files Modified
- `models.py` — added `WeeklyBrief` model (after CommunityHealthSnapshot)
- `main.py` — added `intelligence_v2_router` import and registration

## Frontend Files Created (new)
- `web/src/hooks/use-intelligence-v2.ts` — SWR hooks + TypeScript interfaces
- `web/src/app/dive/page.tsx` — findings list page
- `web/src/app/dive/[id]/page.tsx` — finding detail drill-down with EvidenceCards
- `web/src/app/market/page.tsx` — competitive landscape page

## Frontend Files Modified
- `web/src/app/page.tsx` — rewritten for weekly brief display
- `web/src/components/layout/bottom-nav.tsx` — 4 tabs: Home, Dive, Market, Ask

## Key Data Points from Last Run (2026-03-23)
- 163 new findings generated (153 menu, 4 customer, 3 ops, 3 cost)
- Brief priorities: food cost spiral, customer acquisition leaky bucket, premium drinks collapsed
- Health: ₹12.9L weekly revenue, 19.6% food cost, 9.5% repeat rate, ₹1,447 avg ticket, 887 weekly orders
