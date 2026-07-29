---
name: project-v6-build-runbook
description: "Atlas v6 has a written build runbook + canonical glossary that every session reads first. Five context layers, four pre-build gates, per-chunk execution loop."
metadata: 
  node_type: memory
  type: project
  originSessionId: b59586b9-3103-4e5d-91ea-24bffe155f3d
---

Atlas v6 build (post-2026-05-24) runs under a documented process to keep
coherence across the multi-month, 10-phase, 8-bounded-context build.

**Bootstrap order every v6 session:**

1. `docs/v6/runbook.html` — build runbook with bootstrap sequence + per-chunk loop
2. `CONTEXT.md` (repo root) — domain glossary (signal_call_id, cell deprecation, drift detector, rule_dsl, etc.)
3. CEO plan at `~/.gstack/projects/atlas-os/ceo-plans/2026-05-24-atlas-v6-product-spec.md`
4. Eng review at `~/.gstack/projects/atlas-os/eng-plans/2026-05-24-atlas-v6-eng-review.html`
5. Methodology lock at `<consolidation>/docs/atlas-signal-discovery/methodology-lock-2026-05-23.md`

Project CLAUDE.md has been updated with this load order and auto-loads
`CONTEXT.md` with every session.

**The four pre-build gates (must close in order before Phase 0 begins):**

1. `/plan-design-review` on the eng review HTML — Phase 6 UX gate
2. `/to-issues` Pass 1 — Phase 0.5 research lanes decomposed into ~15-20 issues
3. `/codex:adversarial-review` on consolidated plan — outside voice (quota walled in CEO session; re-run when reset)
4. `/to-issues` Pass 2 — Phase 1-9 decomposed into ~30-50 chunks

**Why this matters for future sessions:** the v6 build will span months across many sessions and parallel worktrees. Without this discipline, terminology drifts (e.g., "horizon" vs "tenure") and decisions get re-litigated. The runbook + CONTEXT.md + per-session checkpoints (`/context-save` + `/context-restore`) are the load-bearing primitives.

Related: [[feedback-session-bootstrap]] (older Phase 2 load order; superseded for v6 work but still applies for SP01-SP10 surfaces).
