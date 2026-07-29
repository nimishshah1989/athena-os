---
name: Production readiness standard
description: User demands task-by-task updates, clean everything (tables/code/docker/git), zero stale code, absolutely production-ready
type: feedback
---

System must be absolutely production-ready. No shortcuts.

- Task-by-task updates on every item — never batch silently
- Tables clean (no orphan data, no stale cache entries)
- Code clean (no unused imports, no dead endpoints, no orphan components, no commented-out code)
- Docker clean (no dangling images, proper health checks, minimal layers)
- Git clean (no untracked junk, no abandoned files, all changes committed properly)
- No stale or unnecessary code lying around anywhere
- Main agent is the orchestrator monitoring all subagents — nothing ships without verification

**Why:** Nimish is non-technical founder making real money decisions on this system. He needs to trust the engineering is bulletproof.
**How to apply:** Every phase ends with a cleanliness check. Every agent output is verified. Every task gets a status update with proof.
