---
name: V2 session state — what's done, what's pending (2026-04-01)
description: Exact state of all 53 original tasks + 15 live review issues for next session continuity
type: project
---

## Session Summary
- 53 original feedback tasks from PDF — backend/infrastructure mostly done, frontend visual quality gaps remain
- 15 new issues found during Nimish's live review (2026-03-31 evening)
- Key lesson: NEVER mark frontend tasks done without Playwright screenshot proof

## What's Deployed and Working (verified via screenshots)
- Nav: Overview / Fund Universe / Fund 360 / Sectors / Strategy Builder
- Global FilterContext with Plan/Type/AUM bar on Overview page
- Caching layer (kv_cache, CacheWarmer, 3 scheduler jobs)
- Peer logic fix (AUM-sorted, AMC diversity)
- Sector rotation normalized to 100%
- SIP/lumpsum separation
- Lumpsum per-trigger parameter
- Security headers (CORS, CSP, XSS)
- Ops scorecard endpoint
- 404/error pages
- Fund detail page loads (was crashing — fixed)

## Commits on main (latest first)
- 58d28fc: card density + fund count transparency
- fd3b8c2: performance chart NAV string→number, font fix, sort fix, universe filter defaults
- 1366ac7: fund detail 500 fix (peer query)
- b701f83: ESLint build skip
- c766b10: dashboard SSG build error fix
- 2d710eb: FilterContext SSR safe defaults
- 28ebc9c: FilterContext + audit fixes
- fadae48: final batch (universe cards, sector cards, ops scorecard)
- Earlier commits: all Phase 0-1 work

## REMAINING ISSUES FROM LIVE REVIEW (priority order)

### Must Fix Next Session
1. **Info icons (i) NOT placed anywhere** — Component built but never applied to tables/charts/metrics. THE biggest gap.
2. **Compare section broken** — return curves still not rendering even for large funds. Sector comparison empty. Needs much richer comparison with red/amber/green indicators.
3. **Heatmap/treemap no labels** — switching views shows unlabeled charts
4. **Analytics tab broken** — top not populating, "Equity" vs "Allocated" unexplained
5. **Expense Analysis card useless** — needs to be actionable or replaced
6. **Asset allocation + credit quality cards empty** — data not mapped for most funds
7. **Market status always "Market Closed"** — needs investigation
8. **Fund360 filter bar half empty** — design inconsistent with Overview
9. **Design language inconsistency** — filter styles vary across pages

### Partially Fixed (deployed but needs visual verification)
10. Performance chart curve — NAV string→number fix deployed, needs Playwright screenshot to confirm
11. Font dotted zeros — JetBrains Mono removed, Inter used for all numbers
12. Fund sort order — global maxAUM normalization fix deployed
13. Universe filter bleeding — defaults changed to false
14. Card sizes — padding compacted from p-5 to p-4, gaps from 6 to 4
15. Fund count explanation — now shows "X Growth funds (excl. IDCW & segregated)"

## Key Files Modified This Session
- 50+ files across backend and frontend
- New files: FilterContext.jsx, cache_repo.py, cache_warmer.py, cache_keys.py, filters.py, 2 migrations, pyproject.toml, .eslintrc.json, 404.jsx, _error.jsx

## Session 2 Progress (2026-04-01)
Fixes deployed and verified via Playwright screenshots:
- Fund sort: Parag Parikh + HDFC showing first (AUM-dominant composite) — VERIFIED
- Performance chart: NAV curve rendering with real data — VERIFIED
- Market status: "Market Live" during IST hours — VERIFIED
- Font: Inter for all numbers, no dotted zeros — VERIFIED
- InfoIcon tooltips: deployed to risk/portfolio/hero/sector/dashboard — DEPLOYED
- Chart descriptions: scatter/heatmap/treemap all have dimension guides — DEPLOYED
- Expense card: expense vs performance comparison — DEPLOYED
- Analytics explanations: Equity/Allocation explained — DEPLOYED

## Remaining from live review (may need next session)
- Compare section: works for funds with history, data coverage issue for newer funds
- Fund360 filter bar: half empty, design inconsistent — partial
- More InfoIcon placements needed across remaining tables
- Universal filter integration on Universe page (local filters still separate)
- Design language consistency across pages still needs work

**Why:** Nimish explicitly called out that frontend QA was skipped despite being in the plan, CLAUDE.md, and his instructions.
**How to apply:** Start next session by reading this memory + feedback_v2_review_20260331.md, then run visual QA before doing any new work.
