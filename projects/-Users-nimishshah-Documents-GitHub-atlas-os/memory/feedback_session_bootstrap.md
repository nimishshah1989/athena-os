---
name: Read foundation docs before milestone work
description: Every session that touches Atlas milestone code must read foundation + relevant milestone doc first
type: feedback
originSessionId: 85e68f27-9b9a-4a5b-ac58-6da306889a19
---
**Rule:** Before writing or modifying any code that touches a milestone (M1–M5), the coding agent MUST read all five foundation docs plus the active milestone's doc, in this order:

1. `docs/00_METHODOLOGY_LOCK.md` — what the system computes (the canonical spec)
2. `docs/01_BACKEND_ARCHITECTURE.md` — how the system is built (conventions, libraries)
3. `docs/02_DATABASE_SCHEMA.md` — every column of every table
4. `docs/03_VALIDATION_FRAMEWORK.md` — what "done" means per milestone
5. `docs/04_THRESHOLD_CATALOG.md` — 35 tunable thresholds + ranges
6. `prds/00_INFRA_DECISIONS.md` — Supabase pivot + F1-F7 fixes + Stage-1 bootstrap + ema_50/atr_21 schema additions
7. `docs/milestones/ATLAS_M<N>.md` — the milestone we're building (only the relevant one)

Plus: skim `docs/06_DEVELOPMENT_PLAN.md` for the strategic cadence (skill sequence per milestone, frontend approach, backend-frontend linking).

**Why:** The methodology lock + foundation docs are dense (>4,000 lines combined) and contain seven internally-cross-referenced rules (threshold discipline, library discipline, suspension states, Below Trend conjunction, Stage-1 bootstrap, divergence flag semantics, dislocation override). Drift between code and these docs is the most common failure mode in the build. The user explicitly asked: "every session before starting the milestone, all the foundation documents are read by the coding agent and has all the required context."

**How to apply:**
- At the start of any milestone-touching conversation, the agent's first action should be to read the foundation docs (use `Read` tool, not `Bash cat`).
- For routine debugging or non-milestone work (e.g. "fix the typo in README"), reading foundation docs is unnecessary — but if in doubt, read.
- The active milestone's milestone doc is mandatory; other milestone docs (M-1 / M+1) are skim-only.
- If foundation docs are updated mid-build, the methodology revision process applies (proposal → sign-off → version bump → recompute) — surface it explicitly, don't silently work to a new spec.

**This rule overrides "don't read files unprompted" — Atlas is a precision-critical fintech project; the cost of a missed methodology rule is days of rework.**
