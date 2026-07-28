---
name: SP03 OpenBB BYO Copilot — shipped on EC2, code proven working
description: 9 commits + 39 tests. /v1/agents.json + /v1/query SSE endpoints live in code, smoke-tested end-to-end on EC2 against real production MVs. NOT yet exposed publicly — needs nginx + systemd setup.
type: project
originSessionId: b03c7f67-fe54-4643-8fc6-c6dce97c8b0f
---
**Ran:** 2026-05-12 overnight
**Commits:** fde8130, 1ec6e65, 2864578, c83151b, 6c450be, 99acdcd, e93f311, 2ca0b13, 6e9a4b3 (9 total)
**Plan:** `docs/phase2/plans/2026-05-12-sp03-openbb-copilot.md`

## What shipped

**Code (live on EC2 at `/home/ubuntu/atlas-os/atlas/api/openbb/`)**

- `schemas.py` — Pydantic models for QueryRequest + 5 SSE event types (reasoning_step, message_chunk, table, chart, done)
- `events.py` — typed event builders
- `auth.py` — API-key dependency (reads `OPENBB_BACKEND_API_KEY` from env, returns 401 on missing/invalid)
- `handlers/router.py` — keyword intent classifier (breakouts → rotation → leaders → regime order)
- `handlers/{regime,leaders,rotation,breakouts}.py` — four async handlers, each reads from one materialized view
- `metadata.py` — `GET /v1/agents.json` with agent description + sample queries
- `query.py` — `POST /v1/query` returns `EventSourceResponse` streaming SSE
- `router.py` — APIRouter mounted at `/v1` in main app

**Mods:** `atlas/api/__init__.py` adds one line to mount router; `atlas/api/auth.py` adds `/v1` to JWT-exempt prefixes; `atlas/config.py` adds `OPENBB_BACKEND_API_KEY` field; `pyproject.toml` adds `sse-starlette>=2.0`.

**Tests:** 39 passing (18 router, 9 handlers, 9 metadata, 3 e2e). 4 integration tests gated on `ATLAS_INTEGRATION_TESTS=true`. pyright + ruff clean (per-commit hook).

**Smoke test on EC2 (live data):**
- `/health` → 200 {"status":"ok"}
- `/v1/agents.json` without auth → 401 "openbb_missing_token"
- `/v1/agents.json` with bearer → full metadata JSON
- `/v1/query` regime intent → 4-event SSE stream:
  - reasoning_step
  - message_chunk: "As of 08-May-2026, Indian equity market classified as Risk-On..."
  - table: 11-column regime row with breadth signals
  - done

## What's NOT done (deployment gap)

The compute EC2 (13.206.34.214) does NOT expose `atlas.api:app` publicly. The internal recompute API runs on port 8002 (behind ATLAS_INTERNAL_SECRET). The main atlas API has no systemd service, no nginx route, no public DNS.

OpenBB Workspace can't reach the endpoints until ONE of:
1. **On compute EC2**: create `/etc/systemd/system/atlas-public-api.service` running `uvicorn atlas.api:app --host 0.0.0.0 --port 8004`; nginx config to route `atlas-api.jslwealth.in/v1/*` → `127.0.0.1:8004`; new DNS A record + Let's Encrypt cert
2. **On frontend EC2** (13.202.162.196 where `atlas.jslwealth.in` lives): proxy `/v1/*` from the Next.js app to the compute EC2 via tunnel or VPN

This is a separate deployment task — not Phase 2 code scope.

## API key for OpenBB Workspace

Written to `/home/ubuntu/atlas-os/.env`:
```
OPENBB_BACKEND_API_KEY=lk8-3WX3HACl3rscd-3tmAq6i2NMRTk7GUWCgswy0aE
```

This key is what Nimish pastes into OpenBB Workspace → Settings → Custom Backends → Atlas Intelligence → Authorization Bearer. Rotate after testing.

## OpenBB plan choice

User picked **Workspace Community** (free tier) for testing. Sufficient for BYO Copilot validation.

## Smoke-test curl (run after deployment)

```bash
curl -s -N -X POST \
  -H "Authorization: Bearer $OPENBB_BACKEND_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"show me top rs stocks"}]}' \
  https://atlas-api.jslwealth.in/v1/query
```

## Known scope gaps

1. **No Claude-fallback**: unknown intents return a static "supported queries" message. v2 routes to Claude with Atlas context.
2. **No widgets/citations**: feature flags off in agents.json. Future expansion.
3. **Chart event in rotation handler**: shipped per plan; OpenBB SDK may or may not render scatter charts via this event — easy to drop if needed.
4. **Field names in agents.json** match plan, not necessarily OpenBB SDK current spec. If Workspace rejects, the metadata module is a trivial dict edit.

## Next-up

Phase 5 (validator final scan) + Phase 6 (master plan badges + push). Then stretch: SP05 (Daily Brief) can be built using SP02 MVs directly without waiting on SP04 — pivot decision needed.
