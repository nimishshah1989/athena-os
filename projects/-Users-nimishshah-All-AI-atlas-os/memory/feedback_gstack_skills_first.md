---
name: Invoke gstack skills BEFORE any action — non-negotiable
description: Every coding action requires picking + invoking the right gstack skill first; reviews are mandatory
type: feedback
originSessionId: 85e68f27-9b9a-4a5b-ac58-6da306889a19
---
**Rule:** Before any code change, query, migration, audit, or build action,
the agent MUST:

1. Pick the right gstack / superpowers / codex skill from the available list
2. Invoke it via the Skill tool
3. Follow its instructions end-to-end
4. Only then execute the underlying action

The agent is NOT permitted to "just start running" code or queries. The
gstack pipeline (plan-eng-review → TDD → review → security-review → sebi →
codex → ship) is the discipline that keeps Atlas precision-correct.

**Why:** During the M1 universe-lock build (2026-05-06), the agent skipped
every review skill in the name of forward motion. M1 shipped with zero
adversarial review. The user explicitly course-corrected: "you are strictly
supposed to use gstack skills... every time anything needs to be done, you
can't just start running. You have to go to browse and you have to pick up
the right gstack skill, and then only do it. Make sure that reviews are done."

**Skill picking guide:**

| Action | Required skill(s) |
|---|---|
| Plan a milestone | `/plan-ceo-review` then `/plan-eng-review` |
| Implement code | `/superpowers:test-driven-development` |
| Parallel implementation | `/superpowers:dispatching-parallel-agents` |
| Code review (per PR) | `code-review:code-review` and/or `/review` |
| Security review | `/security-review` |
| Fintech / SEBI compliance | `/sebi` |
| Independent second opinion | `/codex` |
| Data / bug investigation | `/investigate` |
| Verify completion claim | `/superpowers:verification-before-completion` |
| Ship / merge / deploy | `/ship` then `/land-and-deploy` |

For tasks that don't fit a single skill (e.g. data quality audit), use the
closest review skill (`code-review:code-review` for code, `/codex` for
findings) rather than skipping reviews.

**M1 retro debt:** M1 code (atlas/universe/, migrations 001-010, scripts/)
needs retroactive `/review`, `/security-review`, `/sebi`, `/codex` runs
before M2 work begins.

**How to apply:** When the user gives any task, the FIRST response should
identify the right skill and invoke it. Even if the task seems urgent
("just run this query"), the discipline holds. Reviews catch what speed
misses. The user prefers correctness over throughput.
