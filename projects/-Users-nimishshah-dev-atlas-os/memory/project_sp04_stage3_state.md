---
name: SP04 Stage 3 — Conviction Composite shipped to production
description: v2 tiered conviction composite live on atlas.jslwealth.in. T1+T3 industry-grade (holdout IC>=0.05), T2/T4/T5 baseline pending Stage 4 auto-optimization.
type: project
originSessionId: b03c7f67-fe54-4643-8fc6-c6dce97c8b0f
---
**Ran:** 2026-05-12 morning
**Branch:** main (commits d78101b → f040e8d, 5 commits + 1 hotfix)
**Plan:** docs/phase2/plans/2026-05-12-sp04-stage3-conviction-production.md

## What shipped

### Backend
- **Migration 039** — three audit-tracked tables + 1 materialized view:
  - `atlas.atlas_signal_weights` — per-tier weight sets with effective_from/effective_to history, unique partial index on active rows
  - `atlas.atlas_tier_membership_daily` — 20-day ADV rank → 5 liquidity tiers
  - `atlas.atlas_stock_conviction_daily` — computed conviction with JSONB per-signal breakdown
  - `atlas.mv_top_conviction_daily` — latest-date top conviction (industry_grade + baseline), refreshed by pg_cron at 20:15 IST
- **Seeded weights** (46 rows): T1=11, T2=10, T3=7, T4=9, T5=9 signals. atr_21 flipped in every tier. Holdout IC stored per row.
- **atlas.intelligence.conviction** module: weight_loader.py, tier_assignment.py, composer.py, persistence.py (~600 LOC + 17 tests, all green)
- **scripts/compute_conviction.py** — nightly CLI. Critical: `as_of` defaults to `LEAST(MAX metrics, MAX validated OHLCV)` because OHLCV is currently 33 days stale (2026-04-09 vs metrics 2026-05-11). Without this guard the ADV window would be empty.
- **scripts/seed_signal_weights.py** — idempotent seeder

### Agent layer
- `query_top_conviction()` added to atlas/agents/tools/atlas_queries.py (whitelist-validated filters; bogus categorical values silently dropped)
- Registered in `atlas/agents/tools/registry.py` (TOOL_NAMES now 11, was 10)
- `stock_screener` system prompt updated to prefer conviction over RS for generic "best/top/high conviction" queries
- Live invoke verified: agent returns SEBI-safe narratives like "PFOCUS ranks highly in the upper mid-cap tier with Conviction 95"
- Known Groq Llama XML-function-call bug still hits ~30% of invocations; SEBI guard returns "Data unavailable" rather than hallucinating

### Frontend
- `frontend/src/lib/queries/conviction.ts` — getStockConviction, getConvictionBreakdown, getConvictionMap, getTopConvictionByTier
- `frontend/src/components/stocks/ConvictionCell.tsx` — bar + score + tier-conditional Industry/Baseline badge
- `frontend/src/components/stocks/ConvictionBreakdownPanel.tsx` — per-signal contribution chart on deep-dive (shows was_neutral_fill ⚠ flag for NaN signals)
- `frontend/src/components/intelligence/TopConvictionSection.tsx` — top 5 per tier on /intelligence
- /stocks page: Conviction column added to OPTIONAL_COLS (defaultVisible: true)
- /stocks/[symbol] page: ConvictionBreakdownPanel rendered below existing body
- /intelligence page: TopConvictionSection rendered below the two-column grid (allow-large marker added — composition layer justifies 261 LOC)

## Production data (as of 2026-04-09 anchor)

- 1000 instruments tiered (50 mega + 100 large + 150 upper mid + 200 lower mid + 500 small)
- 728 conviction scores computed (some instruments lack metrics data)
- 190 industry_grade rows + 538 baseline rows
- Top picks: PFOCUS, STLTECH (T3 industry_grade), VIYASH (T5 baseline), GAEL (T5 baseline), ATHERENERG (T3)

## Methodology evidence (Stage 2 holdout, 2023-2025 OOS)

| Tier | Holdout IC | Confidence label |
|---|---|---|
| T1 mega-cap (1-50) | 0.0511 (t=6.19) | industry_grade |
| T2 large-cap (51-150) | 0.0068 (t=1.12) | baseline |
| T3 upper mid (151-300) | 0.0538 (t=8.53) | industry_grade |
| T4 lower mid (301-500) | 0.0268 (t=3.81) | baseline |
| T5 small-cap (501-1000) | 0.0413 (t=5.70) | baseline |

## Eng-review fixes applied during build

1. `composer.py` SQL composed from `SIGNAL_COLUMNS` module constant — added `# noqa: S608` with whitelist justification.
2. Dead join through `atlas_stock_states_daily` simplified — composer queries `atlas_stock_metrics_daily` directly.
3. `was_neutral_fill: bool` field added to each breakdown entry so UI can flag NaN→0.5 fills with a ⚠ icon.
4. `assign_confidence_label(Decimal("0.05"))` boundary test asserts industry_grade (>= threshold, not >).
5. CLI `as_of` defaults to `LEAST(metrics_max, ohlcv_max)` after pre-flight surfaced 33-day OHLCV lag.

## Tests

- 17 conviction unit + integration tests in `tests/intelligence/conviction/` — green on EC2
- 5 new query tests + 1 registry test in `tests/agents/tools/` — green on EC2
- Frontend build passes (next build with all conviction code, 23 routes)
- Live agent invoke succeeds 4/5 attempts (1 hit Groq XML bug, fell back to SEBI-safe message)

## Known limitations / Stage 4 scope

- T2/T4/T5 holdout IC below 0.05 industry bar — they ship with `baseline` label, pending Stage 4 auto-optimization loop
- OHLCV data 33 days stale on EC2; metrics fresh through 2026-05-11. Conviction anchored to 2026-04-09 until OHLCV catches up
- pg_cron MV refresh scheduled 20:15 IST; manual REFRESH was run today
- Groq Llama tool-call bug still ~30% on stock_screener queries (mitigated by SEBI guard)

## Critical paths for future sessions

- To recompute conviction: `ssh ubuntu@13.206.34.214 'cd /home/ubuntu/atlas-os && source .venv/bin/activate && python scripts/compute_conviction.py --persist'`
- To inspect top picks: `SELECT u.symbol, c.tier, c.conviction_score, c.confidence_label FROM atlas.atlas_stock_conviction_daily c LEFT JOIN atlas.atlas_universe_stocks u USING(instrument_id) WHERE c.date = (SELECT MAX(date) FROM atlas.atlas_stock_conviction_daily) ORDER BY c.conviction_score DESC LIMIT 10`
- To re-seed weights: `python scripts/seed_signal_weights.py` (idempotent)
- Frontend lives on 13.202.162.196 at /home/ubuntu/atlas-frontend, served via PM2 (atlas-frontend process); auto-deploys on push to main
