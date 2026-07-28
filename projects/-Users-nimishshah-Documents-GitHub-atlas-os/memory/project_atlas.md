---
name: Atlas project context
description: What Atlas is, the four pillars, current milestone state and gating
type: project
originSessionId: 85e68f27-9b9a-4a5b-ac58-6da306889a19
---
**What:** Atlas — Adaptive Technical Lens for Asset States. An Indian wealth-management decision engine that answers three questions per instrument per day: is this investable, when to enter, when to exit. Stocks + ETFs + mutual funds. Sub-product within a larger family (Beyond / Jhaveri Tech).

**Why:** Replaces a discretionary research workflow with a systematic, threshold-tunable, fully-traceable framework. Fund managers (Bhaven Shah is the named user) review states and decisions surfaced by the system rather than running ad-hoc analyses.

**How:** OHLCV + NAV in → four primitives (RS, RS Momentum, Risk, Volume) → categorical states → decisions via logical AND/OR over states. Pre-computed nightly; UI reads materialised tables only.

**Four pillars (non-negotiable):**
1. Price + volume sufficient (no fundamentals as ranking inputs)
2. Stock is the atom (sectors/funds are aggregations)
3. States not scores (categorical, not weighted composites)
4. Pre-computed never live (no compute at request time)

**Plus a fifth principle (operating model):** all 35 numeric thresholds tunable via the database (`atlas_thresholds` + `atlas_threshold_history` audit), never hardcoded in code.

**Universe (locked at M1):** 750 stocks, 100 ETFs, 75 indices, 592 mutual fund schemes. History: 2016-04-07 to today (10yr, not 12yr — JIP index prices only go back to 2016-04-07; adjusted from original plan).

**Milestones (M0-M5, hard sequential gating):**
- M0 — Data Core Prep: COMPLETE
- M1 — Schema + Reference: COMPLETE as of 2026-05-06. All 7 reference tables populated (750 stocks, 100 ETFs, 75 indices, 592 funds, 31 sectors, 10 benchmarks, 35 thresholds).
- M2 — Stock + ETF Metrics + States: BACKFILL COMPLETE as of 2026-05-06. Validation COMPLETE as of 2026-05-07. Awaiting 3 consecutive nightly runs (Tier 5) starting 2026-05-08 for full sign-off. Then run /review /security-review /sebi /codex.
- M3 — Sector Aggregation + Market Regime: IN PROGRESS — started 2026-05-07 (Nimish overrode M2 Tier 5 gate; M2 data quality confirmed). See project_m3_plan.md.
- M4 — Mutual Fund Three-Lens: not started
- M5 — Decision Engine: not started

**Stack:** Python 3.11+, Polars-first compute (pandas-ta + empyrical for indicators), SQLAlchemy + Alembic, FastAPI thin serving layer, Next.js + Supabase JS for v1 frontend (replacing the architecture's original Streamlit choice — see project_skill_cadence.md).

**Domain:** fintech, regime SEBI + DPDP. Hooks enforce no-float-on-money, no-PII-in-logs, FastAPI Decimal encoder for monetary endpoints.

**How to apply:** Frame every conversation about Atlas in terms of the milestone we're in + which pillar / pre-flight check / methodology section is at stake. Methodology-lock changes require explicit re-sign-off; everything else is iteration.
