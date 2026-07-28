---
name: Adversarial Review Results (2026-04-02)
description: Full Codex adversarial review — 35 blockers, 112 warnings across 6 categories. Security fixes applied, rest pending.
type: project
---

# Adversarial Review — MF Pulse Engine (2026-04-02)

6 parallel reviewer agents ran against the full codebase. Results:

## Severity Summary

| Category | BLOCKER | WARNING |
|---|---|---|
| 1. Security | 4 | 11 |
| 2. Code Quality | 3 | 14 |
| 3. Bugs | 8 | 14 |
| 4. Race Conditions | 5 | 8 |
| 5. Test Flakiness | 5 | 27 |
| 6. Financial/Decimal/Maintainability | 10 | 38 |
| **TOTAL** | **35** | **112** |

## FIXED (Security Block — same session)

- Auth wired to all mutation endpoints via router-level + per-endpoint Depends
- Path traversal in file upload (sanitized filename + is_relative_to guard)
- Path traversal in FrontendMiddleware (_safe_resolve + .. rejection)
- Morningstar API hashes moved to env vars (config.py + lazy proxies in morningstar_config.py)
- Startup guard: ADMIN_API_KEY required in production or app refuses to start
- Swagger/ReDoc/OpenAPI disabled in production
- Raw exception messages no longer leaked to clients (funds.py, main.py health/ready)
- Codex P1 fix: hashes default to real values so existing deploys don't break
- Codex P2 fix: clear_all_config_caches() clears morningstar config caches too

## UNFIXED — Top 10 Priority (from review)

1. **Monthly return calc WRONG for SIP** — simulation_engine.py:663-676 counts SIP inflow as return, corrupts Sharpe/Sortino
2. **Resilience lens max_drawdown INVERTED** — lens_engine.py:488 higher_is_better=False is backwards for negative values
3. **APScheduler no overlap protection** — scheduler.py: no max_instances=1 on any job
4. **nav_feeds + fetch_nav both at 21:30 IST** — concurrent writes to nav_daily
5. **float() pervasive for money** — sector_rotation, dashboard_service, fund_intelligence, nl_search all use float()
6. **Universe count returns DB total vs filtered** — funds.py:189-195 pagination broken
7. **Signal data defaults missing to 50** — simulation_service.py:204 suppresses crash triggers
8. **Holding detail delete-insert race** — ingestion_repo.py:202-228 no row locking
9. **No test isolation** — global env mutation, shared module-level state
10. **Over-mocking** — nearly every test mocks the layer below, no integration tested

## Other Notable Findings

- 27+ files over 300 lines, 40+ functions over 40 lines
- 14 silent `except Exception: pass` in claude_client.py
- _USAGE_LOG unbounded memory growth
- toLocaleString used 44+ times instead of formatINR
- 3 services missing audit trail (fund_intelligence, dashboard, sector_rotation)
- Hardcoded "top_category": "Large Cap" and "universe_stats": "13,000+ funds"
- Risk-free rate 6% hardcoded in simulation_engine
- Frontend: no API error handling tests, no formatINR boundary tests

**Why:** Comprehensive codebase health baseline before production hardening.
**How to apply:** Work through unfixed items in priority order. Security is done. Next: financial correctness (items 1-2), then race conditions (items 3-4), then decimal precision (item 5).
