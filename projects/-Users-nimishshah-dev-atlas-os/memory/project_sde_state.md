---
name: project-sde-state
description: "Signal Discovery Engine — library-based autonomous paper-trading bot; replaces v6; spec written 2026-05-20, plan + build next"
metadata: 
  node_type: memory
  type: project
  originSessionId: 2ff217a8-ee34-4358-b1a3-6ac996e1cccf
---

The **Signal Discovery Engine (SDE)** is the v6 replacement: an autonomous bot
that acts like a systematic trader — discovers factors that predict
cross-sectional equity returns, composes them into strategies, paper-trades
them, and learns by promoting/retiring strategies. No real-money execution in
v1.

**Design principle:** integration, not invention. Library stack — `pandas-ta`
(factors), `alphalens-reloaded` (IC/factor analysis), `vectorbt` (backtest),
`quantstats` (reporting) — glued by ~500 lines of custom code. No bespoke
engine, no LLM agents in v1.

**Key decisions (from brainstorming 2026-05-20):**
- Label: cross-sectional relative return rank, horizons 3m/6m/12m.
- Universe: liquidity-defined, self-PIT-correct (no survivorship, no NSE scrape).
- Strategy lifecycle: HYPOTHESIS → BACKTESTED → VALIDATED → PAPER → CONVICTION
  → RETIRED, as a Postgres status column.
- Validation: simple time-based 70/30 holdout + search-count haircut. No
  nested cross-validation.
- Phase 0 = a 1-day IC spike (~100 lines) that decides if any factor has
  tradeable out-of-sample IC. Phase 1 = the thin bot (~500 lines).

**Status: Phase 0 spike BUILT and RUN (2026-05-20).** All on branch
`feat/atlas-strategy-lab` (not pushed). Spec `1d6bd2f`, plan
`docs/superpowers/plans/2026-05-20-sde-phase0-spike.md`. Code lives in
`atlas/research/sde/{data,factors,ic_ranking}.py` + `scripts/sde_phase0_spike.py`
+ `scripts/sde_preflight_checks.py`; 15 unit tests. Built via 6 TDD tasks,
each two-stage reviewed.

**Phase 0 result** (`docs/sde/phase0-ic-results.md`, commit 7d85298): spike
ran on EC2 — 881 liquid instruments, 6y, 19 factors x 3 horizons. Raw gate said
PROCEED (9 survivors) but the **honest read is qualified yellow**: the dominant
effect is non-stationarity — volatility & medium-term-momentum factors invert
sign out-of-sample (real post-COVID→2024-25 regime shift). Only ~2 genuinely
stable factors: `prox_52w_high` (+IC both eras) and `kurt_63` (-IC both eras).
Two "survivors" (cmf_20, obv_chg_21) are gate artifacts (train IC ≈ 0). Better
than v6's IC≈0.009, worse than the headline. Phase 1 (if pursued) must build
around the 2 stable factors, make regime-conditioning first-class, and fix the
gate (min train-IC floor, autocorrelation-corrected t).

**Data note:** SDE reads `public.de_equity_ohlcv` directly (the
`atlas_v6_clean_ohlcv` view from the spec is on the retired v6 branch, absent
here). `close_adj` is 100% covered and genuinely corporate-action adjusted;
`mask_extreme_moves` nulls the ~0.01% artifact tail (unadjusted splits + 2
corrupt tickers).

**EC2 run path:** Mac can't reach DB. tar `atlas/research scripts/sde_*.py` →
scp to `ubuntu@13.206.34.214:/tmp/` → extract in `/home/ubuntu/atlas-os/` →
`.venv/bin/python -m scripts.sde_phase0_spike`.

Related: [[project-v6-state]], [[feedback-simplify-adopt-libraries]], [[project-atlas]]
