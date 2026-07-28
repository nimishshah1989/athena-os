---
name: project-sp08-state
description: SP08 KiteConnect Intraday Live State Engine — committed to main (f33abbb), EC2 deploy pending
metadata: 
  node_type: memory
  type: project
  originSessionId: cb74b01c-0aea-4d84-a3c3-dd7e6d2d7b4e
---

Full SP08 intraday engine committed to main on 2026-05-12 (commit f33abbb). /review + /qa complete, 108 tests passing, all hooks pass. NOT yet deployed to EC2.

## What was built

- **Migration 042** (`migrations/versions/042_create_intraday_tables.py`): atlas_stock_metrics_intraday + atlas_kite_session (pgcrypto encrypted token) + mv_rs_intraday + pg_cron 15-min refresh jobs (UTC schedule)
- **atlas/intraday/** package: auth.py, ema_engine.py, rs_engine.py, persistence.py, ingester.py, notify.py
- **atlas/api/kite_auth.py**: /api/kite/login + /api/kite/callback (JWT-exempt)
- **atlas/api/intraday.py**: /api/v1/intraday/rs-leaders + /api/v1/intraday/status
- **scripts/**: trading_calendar.py (NSE 2026 holidays), run_intraday.py, kite_daily_notify.py
- **systemd/**: atlas-intraday.{service,timer} (03:40 UTC = 09:10 IST), atlas-intraday-notify.{service,timer} (03:25 UTC = 08:55 IST)
- **Frontend**: IntradayRSLeaders.tsx (30s polling, market-hours gate), /api/intraday proxy route

## Review fixes applied (in commit f33abbb)

1. `threading.Lock` on bar-close — prevents concurrent `_process_bar_close` from `stop()` + `_bar_close_loop`
2. EOD sentinel uses `pgp_sym_encrypt('EOD-SENTINEL', %s)` — was plain string in PGP column
3. `sector` query param: `max_length=100` added

## EC2 deploy — required before going live

User must:
1. Create Kite app at kite.trade/developers, set Redirect URL = `https://atlas.jslwealth.in/api/kite/callback`
2. Add to EC2 `.env`: `KITE_API_KEY`, `KITE_API_SECRET`, `KITE_TOKEN_ENCRYPTION_KEY=$(openssl rand -hex 16)`
3. `pip install kiteconnect` on EC2
4. `git pull && alembic upgrade head` on EC2 (runs migration 042)
5. `sudo cp systemd/*.service systemd/*.timer /etc/systemd/system/ && sudo systemctl daemon-reload`
6. `sudo systemctl enable --now atlas-intraday.timer atlas-intraday-notify.timer`
7. Manual OAuth test: visit `https://atlas.jslwealth.in/api/kite/login`, confirm `/api/v1/intraday/status` returns session row
8. Telegram deferred: add `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID` when ready

**Why:** KiteConnect credentials + Telegram bot were not available during build; user was setting them up in parallel.

**How to apply:** Next session that touches SP08 should verify EC2 setup is complete before suggesting any new SP08 features. Do NOT store credentials here — EC2 .env only.
