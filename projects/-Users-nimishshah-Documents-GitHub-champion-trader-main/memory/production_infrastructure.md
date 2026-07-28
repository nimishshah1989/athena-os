---
name: Production Infrastructure
description: CTS production deployment state on jslwealth server
type: project
---

## Server: jslwealth (13.206.34.214)

### Containers
- **Backend**: `champion-trader:latest` → port 8003 (host) → 8000 (container, FastAPI)
- **Frontend**: `champion-frontend:latest` → port 3003 (host) → 3000 (container, Next.js)

### Nginx
- `champion.jslwealth.in` → localhost:3003
- `champion-api.jslwealth.in` → localhost:8003

### Database
- SQLite at `/home/ubuntu/apps/champion/db_data/champion_trader.db`

### Scheduler (10 jobs running)
exit_monitor, entry_monitor, daily_scanner, risk_guardian, regime_classifier, cio_agent, corpus_updater, learning_agent, shadow_portfolio, autooptimize

### API Endpoints
All 15 endpoints verified working (200) as of 2026-03-17.

## Production Bug Fixed (2026-03-17)
- **Root cause**: `DecimalFixMiddleware` rewrote JSON response bodies (converting Decimal strings to floats, making body shorter) but forwarded the ORIGINAL `Content-Length` header. Browser received truncated JSON causing `TypeError: e.trp.toFixed is not a function`.
- **Fix**: Drop stale `content-length` and `content-type` headers before building new Response in middleware.
- **Middleware extracted** to `backend/middleware/decimal_fix.py` (proper module with type hints and docstring). `main.py` reduced from 383 to 316 lines.

## Key Files
- `backend/main.py` — app entry, imports middleware from module
- `backend/middleware/__init__.py` — middleware package
- `backend/middleware/decimal_fix.py` — DecimalFixMiddleware (Content-Length fix)

## Known Issues
- Middleware regex converts ALL pure numeric strings to floats — could theoretically convert a numeric string field (edge case, unlikely with current schema)
- No automated deployment pipeline (manual docker build + restart)
- No production health monitoring or alerting
