---
name: SP04 Stage 4a — Conviction Auto-Optimization Loop shipped
description: Nightly rolling-IC monitor + candidate weight-set generator + admin approval UI with 15% Bayesian smoothing. T1+T3 industry-grade conviction can now adapt to live IC drift.
type: project
originSessionId: b03c7f67-fe54-4643-8fc6-c6dce97c8b0f
---
**Ran:** 2026-05-12
**Branch:** main
**Plan:** docs/phase2/plans/2026-05-12-sp04-stage4a-auto-optimization-loop.md
**Key commits:** 2c7542f (migration 040), fc8dcba (optimization module), b035e68 (signal validation fix), 13bc861 (admin API), ef2acb8 (frontend UI), e39b3a7 (Next.js proxy), 4e9b3e7 (test auth fix), c9b8cc4 (wire into internal_recompute)

## What shipped

### Backend
- **Migration 040** — 2 new audit-tracked tables:
  - `atlas.atlas_signal_ic_rolling` — rolling per-tier per-signal IC measurements (lookback, horizon, n_obs, IC, t_stat). Unique on (as_of_date, tier, signal, window, horizon).
  - `atlas.atlas_weight_proposals` — candidate weight-sets with JSONB current/proposed. Status: pending → approved | rejected | snoozed | superseded. Unique partial index ensures only one pending per (tier, regime).
- **atlas.intelligence.conviction.optimization** sub-package:
  - `ic_monitor.py` — reuses SP01 `compute_ic_over_window` over (tier, signal) pairs, 90-day lookback × 21-day forward horizon. Skips combinations with n < 20 observations.
  - `candidate_generator.py` — re-weights tier signals proportional to |rolling IC|; skips if max element delta < 0.05. atr_21 (anti-predictive) auto-flips because its weight magnitude rises in the proposed set while the `flipped` flag carries over.
  - `smoothing.py` — pure Decimal `blend_weights`, default lambda=0.15. Renormalizes to sum=1.0.
  - `persistence.py` — atomic apply: bookend old weights with `effective_to=CURRENT_DATE`, insert new with `effective_from=tomorrow`, blend with smoothing, mark proposal approved.
- **CLIs:**
  - `scripts/recompute_signal_ic.py [--as-of YYYY-MM-DD] [--persist]`
  - `scripts/generate_weight_candidates.py [--as-of YYYY-MM-DD] [--persist]`
  - Both anchor `as_of` to `LEAST(metrics_max, ohlcv_max)` — same anchoring guard as Stage 3.

### API
- `atlas/api/admin/proposals.py` — 4 endpoints:
  - `GET  /api/admin/proposals` → pending list
  - `POST /api/admin/proposals/{id}/approve` → apply with smoothing
  - `POST /api/admin/proposals/{id}/reject`
  - `POST /api/admin/proposals/{id}/snooze` (body: `until_date`)
- Auth: `_require_admin` accepts EITHER (a) JWT role=admin via existing middleware OR (b) `Authorization: Bearer <ATLAS_INTERNAL_SECRET>`.
- **Mounted on `atlas.api.internal_recompute:app`** (port 8002, the service running on EC2) — NOT on the main `atlas.api:app` which isn't deployed.
- `ALLOWED_EDGES` in `scripts/hooks/check_module_boundaries.py` now permits `atlas.api → atlas.intelligence`.

### Frontend
- `frontend/src/lib/queries/proposals.ts` — server-only queries (`getPendingProposals`, `getRollingICHistory`, `getRecentProposalsAllStatuses`).
- `frontend/src/components/admin/ProposalDiffTable.tsx` — side-by-side current vs proposed weights, sorted by |delta|, colored green/red.
- `frontend/src/components/admin/ProposalActionBar.tsx` — client island: textarea + Approve / Reject / Snooze-until-date buttons. Calls `/api/admin/proposals/{id}/{action}` on the same host.
- `frontend/src/app/admin/composite-proposals/page.tsx` — full server page with IC summary + rationale + diff per proposal.
- `frontend/src/app/api/admin/proposals/[id]/[action]/route.ts` — Next.js proxy that forwards POST to `ATLAS_INTERNAL_API_BASE_URL` with `Authorization: Bearer ATLAS_INTERNAL_SECRET`.

## Production state (2026-05-12)

- Migration 040 applied on EC2
- First IC monitor run on as_of=2026-04-09 produced **55 IC measurements** (5 tiers × 11 signals; all combinations succeeded with n>=20)
- First candidate generator run produced **5 proposals** (one per tier — every tier showed material drift from Stage 2 weights)
- `https://atlas.jslwealth.in/admin/composite-proposals` renders pending proposals with diff tables and action bar (verified live)
- Direct curl against the API works with bearer:
  ```bash
  ssh ubuntu@13.206.34.214 'curl -sH "Authorization: Bearer $ATLAS_INTERNAL_SECRET" http://localhost:8002/api/admin/proposals'
  ```

## Open: frontend secret deploy

`ATLAS_INTERNAL_SECRET` is NOT yet set on the frontend EC2 (`13.202.162.196:/home/ubuntu/atlas-frontend/.env.local`). Until it is, the Approve / Reject / Snooze buttons in the UI will return 401 (the page itself renders fine — only the action buttons hit the proxy).

**Fix (manual, one-time):**
```bash
ssh ubuntu@13.202.162.196 'echo "ATLAS_INTERNAL_SECRET=<copy-from-compute-host>" >> /home/ubuntu/atlas-frontend/.env.local && pm2 restart atlas-frontend'
```
The secret lives at `/etc/systemd/system/atlas-internal-recompute.service.d/secret.conf` on the compute host. Best ops practice: update the auto-deploy script that overwrites `.env.local` to include this line so it survives subsequent builds.

## Sample IC measurements (T1 mega-cap, lookback=90d, horizon=21d, as-of 2026-04-09)

| signal | IC | t-stat | n |
|---|---|---|---|
| atr_21 | **-0.2046** | -11.67 | 61 |
| realized_vol_63 | +0.1234 | +8.22 | 61 |
| vol_ratio_63 | +0.1206 | +6.81 | 57 |
| rs_pctile_3m | +0.1035 | +4.28 | 57 |
| max_drawdown_252 | +0.0800 | +7.29 | 61 |
| ret_12m_1m | +0.0768 | +3.25 | 61 |
| extension_pct | +0.0685 | +2.84 | 61 |
| ma_30w_slope_4w | +0.0528 | +2.17 | 61 |
| ret_6m | +0.0492 | +1.92 | 61 |
| ema_10_ratio | +0.0425 | +1.49 | 61 |

atr_21 IC=-0.20 confirms the `flipped=True` decision from Stage 2.

## Tests

- 21 unit + integration tests for the optimization module (green on EC2)
- 5 endpoint tests via FastAPI TestClient (green on EC2)
- ATLAS_AUTH_DISABLED set at module-import time in test fixture so Config picks it up

## Nightly orchestration (not yet wired)

`run_atlas_nightly.sh` on EC2 should be updated to chain:
```
python scripts/compute_conviction.py --persist
python scripts/recompute_signal_ic.py --persist
python scripts/generate_weight_candidates.py --persist
```
after the existing metrics + states recompute. Until that's wired, the loop must be triggered manually.

## What Stage 4b/4c builds on top of this

- **Stage 4b:** per-regime weight conditioning (5 tiers × 4 regimes = 20 weight sets). The `regime` column on both new tables is already there; the candidate generator just needs to loop over regimes too.
- **Stage 4c:** live-IC drift monitoring + auto-revert (compare live conviction IC vs proposal-time predicted IC), hit-rate visibility per stock on deep-dive, drift alerts in Slack / daily brief.

## Critical paths

- **First-time run on a fresh date:**
  ```
  ssh ubuntu@13.206.34.214 'cd /home/ubuntu/atlas-os && source .venv/bin/activate \
    && python scripts/recompute_signal_ic.py --persist \
    && python scripts/generate_weight_candidates.py --persist'
  ```
- **Inspect pending proposals via SQL:**
  ```sql
  SELECT id, tier, ic_delta, rationale, created_at
  FROM atlas.atlas_weight_proposals
  WHERE status = 'pending'
  ORDER BY created_at DESC;
  ```
- **Manually approve via curl (until frontend secret is set):**
  ```bash
  ssh ubuntu@13.206.34.214 'curl -sX POST -H "Authorization: Bearer $ATLAS_INTERNAL_SECRET" \
    -H "Content-Type: application/json" -d "{\"notes\":\"manual approval\"}" \
    http://localhost:8002/api/admin/proposals/<id>/approve'
  ```
