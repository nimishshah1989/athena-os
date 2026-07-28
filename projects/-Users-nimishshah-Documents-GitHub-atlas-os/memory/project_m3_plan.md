---
name: M3 build plan and gstack skill sequence
description: Scope, phases, skill sequence, and session bootstrap for Atlas M3 — Sector Aggregation + Market Regime
type: project
originSessionId: 8e81118a-d2d6-4373-893a-df3d658699f4
---
**Status:** CODE COMPLETE (2026-05-07). All 44 M3 unit tests passing (10 indices + 12 breadth + 15 sectors + 9 regime = 46 total new tests; full suite 255 passing). EC2 backfill NOT YET RUN — next step. Then Tier 2/3/4 validation, then gstack reviews.

**What was written this session:**
- `atlas/compute/indices.py` — Phase A index metrics pipeline
- `atlas/compute/breadth.py` — shared A/D, McClellan, highs/lows, MA breadth (used by Phase B + C)
- `atlas/compute/sectors.py` — Phase B bottom-up + top-down aggregation, sector states
- `atlas/compute/regime.py` — Phase C market regime classification + dislocation override
- `scripts/m3_backfill.py` — CLI with --phase A/B/C, --start-date, --end-date
- `scripts/m3_daily.py` — incremental daily update
- `atlas/validation/tier4_consistency.py` — cross-table consistency checks
- `tests/unit/test_indices.py`, `test_breadth.py`, `test_sectors.py`, `test_regime.py`

**Key locked decisions made:**
- de_market_cap_history is EMPTY → bottom-up weights = avg_volume_20 × close_approx (traded value proxy)
- Power+Energy share primary_nse_index='NIFTY ENERGY' → explicit divergence_flag=FALSE guard
- AD line: full history recompute from scratch every run (not incremental)
- leadership_concentration uses absolute rank with floor of 1 (`max(1, ceil(n×0.20))`)
- Python venv rebuilt with 3.12 (pandas-ta==0.4.71b0 requires ≥3.12)
- pyproject.toml [tool.pyright] updated: pythonVersion="3.12", venvPath=".", venv=".venv"

**Pending to complete M3:**
1. EC2 backfill: copy modules, run `scripts/m3_backfill.py` (all 3 phases)
2. Tier 2 validation: hand-metric checks on atlas_index_metrics_daily + atlas_sector_metrics_daily
3. Tier 3 validation: hand-state checks on atlas_sector_states_daily + atlas_market_regime_daily
4. Tier 4 validation: run atlas/validation/tier4_consistency.py
5. /review → /security-review → /sebi → /codex
6. 3 consecutive nightly Tier 5 runs → M4 starts

---

## M3 Scope

Three deliverables:

**1. Index Metrics (Phase A)** — `atlas_index_metrics_daily`
- 75 indices x ~3,000 days = ~225K rows
- Returns (1d/1w/1m/3m/6m/12m), RS vs Nifty 500, EMA(10/20/50), realized vol, max drawdown
- No volume, no state classification — indices are not ranked
- India VIX gets special handling (used by regime dislocation override)

**2. Sector Aggregation (Phase B)** — `atlas_sector_metrics_daily` + `atlas_sector_states_daily`
- ~20 sectors x ~3,000 days = ~60K rows each
- Two signals per metric, per sector per day:
  - Bottom-up: market-cap-weighted aggregation of all stock metrics in sector (uses de_market_cap_history; if no actual cap values, fall back to trailing 60d median traded value)
  - Top-down: direct read from NSE sectoral index prices (via de_index_prices)
- Three breadth measures: participation_50 (% stocks above EMA50), participation_RS (% stocks with positive RS), leadership_concentration (top-quintile share of RS)
- Divergence flag when bottom-up vs top-down disagree by >1 rank
- Four sector states: Overweight / Neutral / Underweight / Avoid

**3. Market Regime (Phase C)** — `atlas_market_regime_daily`
- One row per trading day, ~3,000 rows
- 18 input measures across 4 breadth families: Trend, MA Breadth, A/D Breadth, New Highs/Lows, Strength Breadth, Volatility
- Four states: Risk-On / Constructive / Cautious / Risk-Off
- Deployment multipliers: 1.0 / 0.7 / 0.4 / 0.0
- Dislocation override: if 5d vol > 4× 252d median VIX → DISLOCATION (multiplier = 0)

---

## New Code Modules

```
atlas/compute/
├── indices.py          # Phase A — index metric pipeline (Stage 4)
├── sectors.py          # Phase B — sector aggregation (Stage 5)
├── regime.py           # Phase C — market regime classification (Stage 6)
├── breadth.py          # Shared breadth computation (sectors + regime share code)
└── aggregation.py      # Market-cap-weighted aggregation utilities

scripts/
├── m3_backfill.py
└── m3_daily.py

atlas/validation/
├── tier2_metrics.py    # extend with sector aggregation + regime breadth hand-checks
├── tier3_states.py     # extend with sector state + regime state hand-classifications
└── tier4_consistency.py  # new: bottom-up reconstruction, breadth reconstruction
```

---

## Gstack Skill Sequence (per-milestone cadence from project_skill_cadence.md)

1. **/plan-eng-review** — before writing any code
   - Reviews the M3 milestone doc + methodology §9/10/11 for engineering risks
   - Confirms JIP data availability (de_index_prices, de_market_cap_history, de_index_constituents)
   - Confirms India VIX index_code, confirms de_market_cap_history has usable weights
   - Confirms breadth.py and aggregation.py design decisions
   - Output: confirmed build plan with time budget

2. **Build in 3 phases** (each phase: code → unit tests → EC2 backfill → validation):
   - Phase A: indices.py + m3_backfill phase A → Tier 2 index metric checks
   - Phase B: breadth.py + aggregation.py + sectors.py → Tier 2 sector checks + Tier 3 sector states
   - Phase C: regime.py → Tier 3 regime hand-check + Tier 4 consistency

3. **/review** — after all 3 phases complete on EC2
4. **/security-review** — scan for SQL injection in dynamic queries, credential exposure
5. **/sebi** — check financial calculation correctness against SEBI/methodology norms
6. **/codex** — final code quality review

Then 3 consecutive nightly Tier 5 runs, then M4 starts.

---

## Session Bootstrap for M3

When starting M3 in a new session, read in this order:
1. `docs/00_METHODOLOGY_LOCK.md` §9 (index metrics), §10 (sector aggregation), §11 (market regime)
2. `docs/milestones/ATLAS_M3_SECTOR_AND_MARKET.md` (full)
3. `docs/02_DATABASE_SCHEMA.md` §3.3, §3.4, §3.5, §4.3 (M3 tables)
4. `docs/04_THRESHOLD_CATALOG.md` sector + regime threshold keys
5. `prds/00_INFRA_DECISIONS.md` §13 (M2 outcomes that M3 builds on)
6. Check JIP data: `SELECT DISTINCT index_code FROM public.de_index_prices LIMIT 20` + verify India VIX code + `SELECT DISTINCT cap_category FROM public.de_market_cap_history`
7. Then invoke /plan-eng-review

---

## Key Pre-Build Questions to Answer in /plan-eng-review

1. India VIX: what is its exact index_code in de_index_prices? (needed for dislocation override)
2. de_market_cap_history: does it have actual market cap values or only cap_category (Large/Mid/Small)? If only category, confirm fallback to 60d median traded value.
3. de_index_constituents: are NSE sector indices mapped to their constituent stocks? (needed for top-down vs bottom-up divergence cross-check)
4. de_index_prices: do all 75 atlas_universe_indices have price history? Any coverage gaps?
5. atlas_sector_master.primary_nse_index: are all 31 sectors mapped to an NSE sectoral index for top-down?
6. Time budget: 225K + 60K + 3K rows — should be much faster than M2 (no 1.38M row backfill)
