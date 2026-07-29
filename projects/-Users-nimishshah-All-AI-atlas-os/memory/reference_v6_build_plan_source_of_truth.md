---
name: v6-build-plan-source-of-truth
description: "docs/superpowers/plans/2026-05-26-v6-frontend-build.md is the 60-task spine for the v6 frontend. Adversarially reviewed twice (Opus 4.7 + code-reviewer, both SHIP_WITH_FIXES). It is THE source of truth for what got built."
metadata: 
  node_type: memory
  type: reference
  originSessionId: c880c6b8-5d45-4717-8ecc-d02304a45cd0
---

The canonical v6 frontend implementation spec is `docs/superpowers/plans/2026-05-26-v6-frontend-build.md`. It defines:

- **6 phases** (A: primitives + skeletons + query modules · B: portfolio-awareness · C: page composites · D: FM-critic gaps · E: audit + methodology · F: QA + ship)
- **60 discrete tasks** with explicit dependencies
- **Tech stack lock:** Next.js 15.3.9 App Router · React 19 · postgres-js 3.4.5 · Tailwind v4 `@theme` tokens · **Recharts 3.8** · D3 v7 · Radix Tooltip · `@tanstack/react-virtual` · Vitest + Testing Library · Playwright + axe-core
- **Vocabulary lock** (cell states POSITIVE/NEUTRAL/NEGATIVE → BUY/ACCUMULATE/WATCH/HOLD/AVOID/SELL with ownership-aware rendering, `drift_status` enum `{healthy, drift_warn, deprecated}` per migration 080, `predicted_excess` sourced from `atlas_signal_calls` not `atlas_cell_definitions`, etc.)
- **20 adversarial-review patches applied** documented inline (critical CRITICAL, HIGH, MEDIUM categories)

Companion inputs the plan synthesizes:
- `docs/v6/design-application.md` — the locked design language (paper/ink/teal palette, FT-paper aesthetic, table contract, Recharts styling)
- `~/.gstack/projects/atlas-os/eng-plans/2026-05-26-v6-design-build-eng-review.md` — the 40-task spine the build plan extends
- `~/.gstack/projects/atlas-os/design-plans/2026-05-26-v6-fund-manager-critique.md` — FM-lens 6 critical gaps
- `CONTEXT.md` — v6 vocabulary
- `~/.gstack/projects/atlas-os/designs/v6-redesign-20260526-mockups/*.html` — 13 visual mockups

**How to apply:**
- When asked to "build a v6 page", read this plan first to find which Phase C/D task corresponds to it
- Check git log for the task's commit (e.g., `git log --grep="C.16"` for stock detail)
- The components from Phase A/B should already exist in `frontend/src/components/v6/` (114 components as of 2026-05-27)
- Don't propose alternative architectures — this plan went through adversarial review

Related: [[check-v6-components-first]], [[v6-mv-count-breakdown]].
