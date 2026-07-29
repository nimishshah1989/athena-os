---
name: project-atlas-decision-engine
description: Atlas v2 Decision Engine + State Engine — the live trading-product thread; lives in the atlas-os-consolidation worktree
metadata: 
  node_type: memory
  type: project
  originSessionId: 2ff217a8-ee34-4358-b1a3-6ac996e1cccf
---

The **active trading-product thread** as of 2026-05-20. Lives in the worktree
`/Users/nimishshah/Documents/GitHub/atlas-os-consolidation`, branch
`feat/atlas-consolidation` (build history from commit 528c607). v2 frontend
deployed at `http://13.206.34.214:3002/`; production `atlas.jslwealth.in`
untouched.

**State Engine** — a 7-state Weinstein classifier (Uninvestable, Stage 1 Base,
2A/2B/2C, 3 Top, 4 Decline), pure price+volume, stock-atomic. Built:
`atlas/intelligence/states/` (classifier, threshold_optimizer, component_validator,
dwell, ic_harness), migrations 072-083, wired into nightly. IC-validated at the
component level (`docs/audits/state-engine-phase2-ic-2026-05.md`): RS rank is the
load-bearing signal (Leader IR +0.62); volume-confirmation + NATR dropped as
decorative. **Caveats:** validation is in-sample on a single 2023-2024 window
(θ_rs picked in-sample); the engine has NOT yet won the 30-day live burn-in vs
the incumbent; its `within_state_rank` weights `realized_vol` positively,
calibrated to the 2023-24 high-beta regime (the SDE spike found vol IC inverts
in 2025+).

**Decision Engine** — the layer on top: `recommendation = engine_signal ∩
policy_constraint`. The **Policy** = a fund manager's mandate as per-portfolio
config (entry states, sizing caps, exit rules, universe, cadence). A 6-step flow
(Regime → Sector → Fill → Conviction → Act → Deterioration), human-in-the-loop.
Spec `docs/superpowers/specs/2026-05-20-atlas-decision-engine-design.md`, plan
`docs/superpowers/plans/2026-05-20-atlas-decision-engine.md` (20 tasks, 3 waves:
Wiring / Policy / Act). Migration 092 `atlas_portfolio_policy` landed.

**V5-RP-TREND** — the proven rank-1 strategy on the existing leaderboard
(alpha_oos 0.2018, hit_rate 0.631). The state engine is a challenger to it, not
yet a winner.

**Trading-bot direction (2026-05-20):** the Decision Engine is a trading bot
minus autonomy + execution. The agreed direction is a **"Wave 4 — close the
loop"**: an autonomous scheduler + paper-execution + per-Policy attribution that
turns it into a fleet of paper-trading bots (one bot per Policy), competing on
the existing leaderboard. Paper-first; real execution gated on burn-in. First
Policy wraps the proven V5.

Related: [[project-sde-state]], [[project-v6-state]], [[feedback-simplify-adopt-libraries]], [[reference-ec2-access]]
