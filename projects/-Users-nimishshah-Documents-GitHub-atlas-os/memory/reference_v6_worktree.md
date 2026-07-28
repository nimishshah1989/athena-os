---
name: reference-v6-worktree
description: "v6 worktree path, branch, key file locations, how to run"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 2ff217a8-ee34-4358-b1a3-6ac996e1cccf
---

v6 work lives in an **isolated git worktree** at `/Users/nimishshah/Documents/GitHub/atlas-os-v6` on branch `feat/v6-trading-model`. Created off `main` then merged `feat/atlas-strategy-lab` for the v5 trading-lab migration chain (066-079), then `feat/atlas-consolidation` migrations 080-086 imported and v6 prereqs renumbered to 087.

**No upstream set yet.** Push when ready: `git push -u origin feat/v6-trading-model`.

## Canonical paths

- Spec: `docs/superpowers/specs/2026-05-18-v6-rs-trading-model-design.md`
- Plan 1A (data prereqs): `docs/superpowers/plans/2026-05-18-v6-data-prerequisites.md`
- Plan 2 (backend trading engine): `docs/superpowers/plans/2026-05-19-v6-plan-2-backend-trading-engine.md`
- Morning briefing: `docs/v6-morning-briefing-2026-05-19.md`
- Migration applied to Supabase: `migrations/versions/087_v6_prerequisites.py` (8 tables)
- Backend code: `atlas/trading/v6/` and `atlas/data_prereqs/v6/`
- Real-data query layer: `frontend/src/lib/queries/v6_real.ts` (NOT v6.ts — that one was reverted by linter overnight; v6_real is canonical)
- Live frontend route: `/strategies/v6/live` (real data) — `/strategies/v6` shows mocks
- Backfill scripts: `scripts/v6_macro_backfill.py`, `scripts/v6_fno_ban_backfill.py`

## How to run frontend locally

```bash
cd /Users/nimishshah/Documents/GitHub/atlas-os-v6/frontend
# .env.local was copied from main repo at 2026-05-19 08:26 (gitignored)
npm install   # one-time per worktree
npm run dev
# http://localhost:3002/strategies/v6/live
```

## How to apply v6 migration to a fresh DB

```bash
cd /Users/nimishshah/Documents/GitHub/atlas-os-v6
set -a && source .env && set +a
/Users/nimishshah/Documents/GitHub/atlas-os/.venv/bin/alembic upgrade 087
```

## DB tables created by migration 087

`atlas_macro_daily`, `atlas_index_membership`, `atlas_factor_returns_daily`, `atlas_governance_master`, `atlas_governance_daily`, `atlas_v6_strategy_runs`, `atlas_v6_exclusions_log`, `atlas_v6_recommendations_daily`.

## DB rows populated (real data)

- `atlas_macro_daily`: **2,711 rows**, 2016-01-01 → 2026-05-19 (USDINR + DXY + breadth)
- All other v6 tables: empty (await Plan 2 + future backfills)
- Existing atlas tables already powering `/v6/live`: `atlas_stock_conviction_daily`, `atlas_market_regime_daily`, `atlas_etf_metrics_daily`, `atlas_universe_stocks` (~10y history each)

Related: [[project-v6-state]], [[reference-foundation-docs]]
