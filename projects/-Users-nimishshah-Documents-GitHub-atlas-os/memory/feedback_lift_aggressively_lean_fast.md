---
name: lift-aggressively-lean-fast
description: "For Atlas v6, lift v1-v5 substrate aggressively; default LIFT not REBUILD. Vectorized numpy/pandas; fast, lean, elegant code."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 2ff217a8-ee34-4358-b1a3-6ac996e1cccf
---

Two engineering principles locked during /plan-ceo-review on 2026-05-24:

## Principle 1 — Lift aggressively, do NOT reinvent

v1-v5 has thousands of lines of working code. Default action for every
layer is LIFT WHOLESALE. Explicit justification required to rebuild.

**Lift wholesale:** Supabase auth, atlas.db connection/pooling, Bhavcopy +
corp-action ingest, M1 universe filter, MF NAV pipeline (with 251-fund
fix), ETF OHLCV ingest, feature library (29 features), walk-forward
apparatus (rs_phase3*.py), regime classifier, SP07 Hermes specialists +
SEBI guard, Atlas frontend components + visual language.

**Do NOT lift:** v5 state classifier (Weinstein stages), SP04 conviction
composite, risk-managed v2 trading module, Wave-4C state-engine work
(admission gates, breakout_ratio) — all retired per fresh-main v6 strategy.

Phase 1 inventory pass produces the canonical keep/port/retire mapping
as a one-page doc.

**Why:** User explicitly directed (2026-05-24 mid-CEO-review): "Do not do
rework or duplication. Have a very thorough look at all the work that
has been done. Thousands and thousands of lines of code are here, so we
have built a lot, so do not reinvent and rebuild stuff." This is the
opposite of greenfield habits; v6 fresh main means the METHODOLOGY layer
is fresh, NOT the substrate.

**How to apply:** Before writing any new function for Atlas v6, ask:
"is this already implemented in atlas.compute, atlas.intelligence,
atlas.agents, atlas.universe, atlas.db, atlas.frontend?" If yes → lift.
If the lift requires a small adapter (anti-corruption layer), build the
adapter, not a reimplementation.

## Principle 2 — Vectorized, lean, fast, elegant

Methodology is sophisticated; the code is straightforward arithmetic over
vectors. Calculations are not complex.

**Implementation rules:**
- numpy + pandas vectorized operations everywhere.
- No .iterrows(), no .apply(lambda) on >1k rows (enforced by global hook).
- SQL for set operations where data lives in Postgres.
- Decimal for money (enforced); float for ratios.
- Pydantic v2 typed contracts at every module boundary.
- Per-function branching limit: > 5 → refactor.
- Per-file LOC: 600 source / 800 test (enforced).
- Frozen-snapshot data for reproducibility in tests.

**Performance targets:**
- Daily feature compute (727 instruments × 29 features): < 5 min on
  EC2 t3.large.
- Daily inference (regime + 48-cell × 727 instruments): < 2 min.
- Single-tenure walk-forward sweep (7 DD ranges, full history): < 30 min.
- Full multi-tenure sweep: overnight.
- API p99 /v1/scorecard/{iid}: < 200ms.
- API p99 /v1/today/buys: < 500ms.

**Why:** User explicitly directed: "the calculation needs to be super
fast, given the fact that you're not calculating extremely complex
things. Architecturally and code-wise, make sure that the codebase is
clean, efficient, and elegant, and while it might sound complex, it's
still simplified enough for the tool to really come out clean and
error-free."

**How to apply:** Defaults to numpy/pandas vectorized. If a piece of code
needs a loop, that's a signal to look harder. SQL group-by beats Python
group-by every time. Decimal at I/O boundaries; float in the math.
Typed contracts between modules; no Any-typed dicts crossing boundaries.

Related: [[feedback_no_calendar_estimates]], [[project_signal_discovery_2026_05]],
[[feedback_simplify_adopt_libraries]].
