---
name: feedback-autonomous-execution
description: "User wants high autonomy during v6 build execution. Stop asking small \"which one next\" questions. All 66 issues need to be done — order matters less than progress. Check in only at major milestones."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: b59586b9-3103-4e5d-91ea-24bffe155f3d
---

User's explicit instruction (2026-05-24, mid-Wave-0):

> "also - i am not liking this small little questions you are asking me about which one needs to be done first and all.. we have to do everything as it is; why dont you limit checkins with me to major milestones and keep going with autonomy !"

**Why:** The user has approved the v6 plan (CEO + eng + grill + design + adversarial-remediation). All 66 issues are scoped and approved. Ordering questions between AFK-ready issues add no value — they all need to be done. Repeated "which next?" prompts feel like manufactured ceremony.

**How to apply:**

1. **No more "which issue next?" questions** during v6 Wave 0 / Phase 0.5 / Phase 1-9 execution. Pick a sensible next issue using runbook §05 worktree discipline (E schema first, A1/A2 longest-pole research, parallel where possible) and start.

2. **Use `superpowers:subagent-driven-development`** for parallelizable AFK issues. Dispatch multiple subagents simultaneously. Each subagent owns one issue end-to-end (grill if needed → implement → test → commit → PR).

3. **Major milestones = check-in points.** For v6, these are:
   - Phase 0.5 workstream completion (per workstream: 0.5a, 0.5b, 0.5c, 0.5d, 0.5e, 0.5f, 0.5g, 0.5h-prime, 0.5h, 0.5i, 0.5j)
   - Phase 1 inventory complete
   - Phase 2 schema complete (all 7 migrations merged)
   - Phase 3 features pipeline complete
   - Phase 4 decision engine complete
   - Phase 5 ledger+portfolio+drift complete
   - Phase 6 alpha-0 (frontend + Phase 4 backend deployed)
   - Phase 6 alpha-1 (with Phase 5)
   - Phase 6 public launch
   - Phases 7/8/9 complete

4. **Decisions that DO need user input** (still surface, but only these):
   - Hard architectural forks not already locked in CEO/eng/grill (rare now)
   - Hook bypasses (`--no-verify`, etc.) — user must explicitly authorize each
   - Push to remote of risky operations (force-push, branch delete, etc.)
   - Anything destructive (DROP TABLE, git reset --hard, etc.)
   - Anything that changes the locked methodology
   - When stuck > 3 attempts on the same chunk (escalation per CLAUDE.md)

5. **Routine acceptance criteria choices** — pick the obvious one and document the choice in the PR body. User can override post-hoc.

6. **Mid-execution reports** (not check-ins): single-line status updates as PRs ship or subagents complete. Format: "✓ #N shipped — title — branch+SHA". No questions.

Related: [[project-v6-build-runbook]] — the runbook codifies the per-chunk loop; autonomy means executing the loop, not asking permission for each chunk.
