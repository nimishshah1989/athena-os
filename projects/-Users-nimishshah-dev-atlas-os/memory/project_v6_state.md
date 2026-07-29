---
name: project-v6-state
description: v6 RS Trading Model — RETIRED 2026-05-20. Superseded by the Signal Discovery Engine. Kept as a record of why.
metadata: 
  node_type: memory
  type: project
  originSessionId: 2ff217a8-ee34-4358-b1a3-6ac996e1cccf
---

**v6 RS Trading Model is RETIRED as of 2026-05-20.** Do not extend it.

It was a comprehensive long-equity model: 9-signal composite, HRP portfolio
construction, macro regime composite, governance exclusions, crisis sleeve,
walk-forward validation, 3y hold-out. Built overnight 2026-05-18→19; pushed to
`origin/feat/v6-trading-model`.

**How it was retired:** branch tagged `v6-retired-2026-05-20` (on origin),
worktree at `atlas-os-v6` removed. Branch and all commits preserved — nothing
deleted. DB objects (migration 087, `atlas_v6_*` tables) left dormant and
harmless. The one v6 artifact still in use: the `atlas.atlas_v6_clean_ohlcv`
view (corrupt-row filter), reused by the SDE.

**Why retired:** the hold-out CAGR (23.6%) was inflated by survivorship bias
(no PIT membership), the alpha t-stat was below the significance bar, and the
build was a bespoke 960-line-simulator monster — exactly the over-engineering
the user wanted to stop. The honest read: v6 produced a working engine but no
proven strategy. See [[feedback-simplify-adopt-libraries]].

**Replacement:** the Signal Discovery Engine — see [[project-sde-state]].

Related: [[project-atlas]], [[project-sde-state]], [[feedback-simplify-adopt-libraries]]
