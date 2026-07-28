---
name: project_fund_methodology_v2
description: "Fund ranking methodology v2 (2026-05-30) — IC-derived weights replacing gut picks; momentum+consistency dominate, drawdown/vol have zero IC, holdings/style are priors"
metadata: 
  node_type: memory
  type: project
  originSessionId: 72283616-4be3-409c-88d0-5b99787f2bda
---

Fund scorecard methodology v2 shipped 2026-05-30 (PR #95, main). Replaced gut-picked layer weights with weights derived from a forward-IC backtest after the user (correctly) pushed back on weighting "from our tummy."

**The analysis** (`scripts/ops/fund_factor_ic.py`): 195 months of de_mf_nav_daily (deep — back to 2006; 752 funds ≥3y), monthly factors, within-category Spearman IC vs forward 12m return, ~47k fund-month obs. Findings that OVERTURNED the gut design:
- **Momentum (6m/12m return) = strongest forward predictor** (IC ≈ +0.114/+0.110); wasn't even in v1. **Consistency** (peer win-rate) close behind (+0.101).
- **Max-drawdown and volatility had ~ZERO forward IC** (−0.003 / −0.012) → a planned "1.5× downside-emphasis tilt" was REFUTED and dropped. Lesson: don't tilt toward downside-protection metrics for fund *selection*; they don't predict peer outperformance.
- **Holdings-conviction + style have NO pre-2026 history** (de_mf_holdings starts 2026-01, stock_conviction 2026-04) → literally cannot be empirically weighted → kept as small priors the live IC loop grows.

**v2 design (in `atlas/inference/fund_scorecard.py`):** Performance layer (`mf_weight_risk_adj`, 65%) = momentum 40% / consistency 35% / risk-adjusted [Sharpe,Sortino,Calmar] 25%. Drawdown/vol/alpha/captures excluded from scoring (kept in sub_metrics for display; alpha/captures are degenerate in prod anyway — `benchmark_daily_returns=[]` in the loader). Top-line 65/15/10/10 (was 50/25/15/10; `atlas_thresholds` updated on EC2 — DB rows override code defaults, so both must change). Consistency = peer-relative (fraction of months beating category median), computed in the scoring pass from new `FundInput.monthly_returns` (month-anchored; loader builds month-end NAV returns).

**BUG FIXED:** holdings-conviction layer read the DEAD `atlas_conviction_daily` (frozen 05-22) → 25% of every score silently frozen at neutral 50. Now reads live `atlas_stock_conviction_daily`, mapping conviction_score → verdict via `(score-0.5)*20` ±4 bands (same as stock pages). Same dead-table issue still affects the ETF scorecard's conviction layer — a follow-up.

**Result:** composites now spread 71–82 at top (was flat 65–67); holdings scores vary 26–69 (was frozen 50). Leaderboards shifted to momentum+consistency+real-conviction winners. 147 tests pass. Links: [[project_overnight_audit_fix_sequence]], [[project_sp04_stage3_state]] (stock IC machinery this mirrors).
