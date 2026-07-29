---
name: audit_wave1_progress
description: Health audit Waves 1-3 DONE. Wave 2 split 3 files→7 modules. Wave 3 added 68 tests. Remaining: autonomous trader tests, 3 compass_lab assertions, Alembic.
type: project
---

## Health Audit (2026-03-24)

### Wave 1 — DONE (commits: be753fa, 2f9f282, c33945f)
- Env var validation (RuntimeError in prod if missing DB/API key)
- Error sanitization (no str(e) in HTTPExceptions)
- OpenAPI docs disabled in prod
- API key header-only (query param removed)
- CORS restricted (specific methods/headers)
- 21 endpoints typed with -> dict
- Specific exception types (ValueError, TypeError vs bare Exception)
- EOD job threading lock
- Dependencies pinned (>=)
- FIE_API_KEY=mp-prod-2026 on prod container

### Wave 2 — DONE (commit: 37c2bba)
Split completed:
- routers/pms.py (1004→328) + pms_metrics.py (370) + pms_holdings.py (349) ✅
- routers/alerts.py (1025→604) + alerts_performance.py (446) ✅
- price_service.py (834→299) + price_history.py (574) ✅

Still oversized (lower priority — cohesive by concern):
- services/compass_rs.py (974), compass_simulator.py (961), compass_lab.py (949), compass_history.py (920)
- models.py (887) — shared Base makes split risky
- dashboard.py (1514) — standalone Streamlit app

### Wave 3 — PARTIAL (commit: c7f620d)
Done:
- PMS test suite: 30 tests ✅
- Sentiment test suite: 38 tests ✅
- Fix compass_lab stale assertion (len==12) ✅
Remaining:
- Autonomous trader tests (0% coverage)
- Fix remaining 3 stale compass_lab assertions
- Alembic for DB migrations

### Estimated scores after Wave 3
- Security: ~88/100 (B+)
- Code Health: ~78/100 (B)
- Test/Stability: ~75/100 (B-) — +68 new tests (PMS + sentiment)
