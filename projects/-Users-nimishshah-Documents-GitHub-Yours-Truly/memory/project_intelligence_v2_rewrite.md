---
name: Intelligence Engine v2 Rewrite — State & Architecture
description: Complete rewrite of intelligence layer + frontend as of 2026-03-23. 4 deep engines, weekly brief connector, new frontend pages. Deployed but needs major quality improvements.
type: project
---

## What Was Done (2026-03-23)

### Problem Statement
Nimish was deeply unhappy with the old intelligence engine. Called it "junior BA level" — just basic data slicing (comparing daily averages). No true actionable insights, no customer insights from KOT data, no deep undercurrents. Wanted a complete rewrite of both the intelligence layer AND frontend.

### Decisions Locked by Nimish
- Weekly Claude analysis (Sunday night → Monday morning brief), NOT daily
- Kill all standalone dashboard pages — everything becomes drill-down from findings
- Chat stays read-only (no action triggers)
- "The 4 areas of optimization are fine" (Menu, Customer, Operations, Cost)
- User said: "yes do all of that; keen to see how the new interface looks"

### Architecture Built

**4 Deep Analysis Engines** (replace 5 shallow pattern detectors):
1. `intelligence/engines/menu_engine.py` (~400 lines) — 6 analyses: item substitution detection, basket co-occurrence, declining items with DOW patterns, pricing vs competitors, category shifts, dead weight
2. `intelligence/engines/customer_engine.py` (~330 lines) — 5 analyses: multi-signal churn prediction, VIP absence with favorites, acquisition quality (returner vs non-returner profiles), preference drift, spending trajectory
3. `intelligence/engines/operations_engine.py` (~350 lines) — 6 analyses: dead zones (consecutive low-revenue hours), staff performance comparison, cancellation patterns, complimentary leakage, DOW underperformance, table economics
4. `intelligence/engines/cost_engine.py` (~365 lines) — 5 analyses: ingredient price creep from consumed[], recipe cost variance (CV%), food cost trend with causal breakdown, margin squeeze, portion drift (AvT)

**Weekly Brief Connector** (`intelligence/engines/connector.py` ~310 lines):
- Gathers findings + health metrics + competitive + city context
- Sends to Claude Haiku as "skeptical restaurant consultant"
- Output: priorities (top 3), watching (top 4), narrative, health KPIs
- Fallback: if no API key, ranks findings by rupee_impact without Claude
- Stores to `weekly_briefs` table (upsert)

**Shared Utils** (`intelligence/engines/utils.py`):
- `sanitize_for_json()` — converts Decimal from PostgreSQL to int/float

**CLI** (`intelligence/engines/__init__.py` + `__main__.py`):
- `python -m intelligence.engines --restaurant-id 5`
- Can run individual engines: `python -m intelligence.engines menu`

### Frontend Rewrite

**New navigation** (4 tabs): Home, Dive, Market, Ask

**Home page** (`web/src/app/page.tsx`):
- Weekly brief display: narrative, health strip (3 cards: Revenue, Food Cost, Repeat Rate)
- Secondary health bar (Avg Ticket, Orders/Week, Rev Trend)
- Priority cards with severity colors, rupee impact, action
- Watching section

**Dive page** (`web/src/app/dive/page.tsx`):
- Category filter chips (Menu, Customers, Operations, Cost & Margin)
- Finding cards with severity dots, category badges, rupee impact
- Links to `/dive/[id]` for drill-down

**Finding detail** (`web/src/app/dive/[id]/page.tsx`):
- Severity/category badges, action card
- `EvidenceCards` component — dynamically renders metrics grids, price fields, list evidence (substitutes, at-risk customers, problem items, etc.), DOW bar charts, hourly revenue charts
- Collapsible raw JSON data
- 22 finding category labels mapped

**Market page** (`web/src/app/market/page.tsx`):
- Stats strip, strategic insights feed, direct competitors list

**SWR hooks** (`web/src/hooks/use-intelligence-v2.ts`):
- `useWeeklyBrief()`, `useHealthMetrics()`, `useFindings(days, category)`, `useFindingDetail(id)`, `useMarketOverview()`

### Backend API

**Router** (`backend/routers/intelligence_v2.py` ~285 lines):
- `GET /api/v2/intelligence/brief` — weekly brief
- `GET /api/v2/intelligence/health` — health strip KPIs
- `GET /api/v2/intelligence/findings` — paginated findings with category/severity filters
- `GET /api/v2/intelligence/finding/{id}` — deep dive on single finding
- `PATCH /api/v2/intelligence/finding/{id}/status` — workflow status
- `GET /api/v2/intelligence/market` — competitive landscape
- `POST /api/v2/intelligence/run-engines` — trigger engine run
- `POST /api/v2/intelligence/generate-brief` — trigger brief generation

### DB Schema

- `intelligence_findings` table (schema_v3) — already existed
- `weekly_briefs` table (schema_v4) — added: id, restaurant_id, brief_date, priorities JSONB, watching JSONB, health JSONB, raw_claude_response TEXT
- `WeeklyBrief` model added to `backend/models.py`

### Deployment State (2026-03-23)

- Docker containers: ytip-backend (port 8009→8001), ytip-frontend (port 3009→3000)
- Server: EC2 13.206.34.214 (jslwealth t3.large)
- All 4 engines ran successfully: 163 findings total (153 menu, 4 customer, 3 ops, 3 cost)
- Weekly brief generated: 3 priorities, 4 watching
- All v2 API endpoints verified working
- Frontend pages all serving (200 status)
- Files deployed via docker cp (not full rebuild)

### Critical Bug Fixed: Decimal Serialization
PostgreSQL returns `Decimal` from `AVG()`, `SUM()` etc. These break:
1. Float arithmetic (`Decimal * 0.10` → TypeError)
2. JSON serialization (`json.dumps` of JSONB detail dicts)
Fix: Cast all SQL numeric results to `int()` or `float()` in every engine + connector. Safety net via `sanitize_for_json()` utility.

## What's Still Wrong / Needs Work

### Nimish's Assessment: "nowhere near where we need it to be"

### Known Quality Issues:
1. **153 menu findings is WAY too many** — most are noise. Need better filtering, deduplication, and significance thresholds. Substitution detection fires for every item with >15% drop, creating dozens of low-value findings.
2. **Brief only uses fallback** (no Claude API key set?) — priorities are just top-3 by rupee impact, no real synthesis or narrative.
3. **Old findings still in DB** — 230 total (67 from old engine + 163 new). Need to clean up or separate v1 vs v2 findings.
4. **Categories mismatch in findings API** — shows `revenue: 2, ops: 3` mixed with `operations: 2` — old vs new naming. Frontend filter chips may not work correctly.
5. **No deduplication** — running engines again would create duplicate findings for the same patterns.
6. **Frontend not tested with real data visually** — pages render but unclear if evidence cards, charts, etc. display correctly with actual finding data.
7. **No scheduled runs** — engines need to run nightly, brief weekly. No cron/scheduler set up.
8. **Chat page** (`/chat`) still exists but may reference old endpoints.
9. **Market page** needs real competitor data to be useful.
10. **Weekly brief should run via Claude** — needs `ANTHROPIC_API_KEY` env var in Docker container.

### Architectural Gaps:
- No intelligence_findings deduplication/expiry mechanism
- No "finding dismissed" → exclude from future briefs logic
- No conversation memory integration yet
- No voice note integration yet
- Menu engine needs smarter thresholds (not just 15% drop → finding)
- Customer engine churn prediction needs validation against actual churn
- Cost engine portion drift depends on `avt_daily` table which may not exist/have data
