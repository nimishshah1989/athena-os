---
name: no-calendar-estimates
description: "Don't put weeks/days estimates in Atlas build plans. They're consistently wrong (often 5-10x too high)."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 2ff217a8-ee34-4358-b1a3-6ac996e1cccf
---

Rule: For Atlas v6 build plans (and any phased work plan), do NOT include calendar
estimates like "Days 13-14" or "~2 weeks" or "4 weeks." Sequence phases by
**dependency and exit criteria** instead: "After Phase 3", "Parallel with Phase 6",
"Gates Phase 1", "Until walk-forward TN ≥ 65%."

**Why:** User pointed out (2026-05-24) that we ship things overnight or in a couple
of sessions that I had estimated as 1-4 weeks. The estimates are anchored on
human-team velocity, not Claude Code + EC2 velocity. They're not just wrong —
they're load-bearingly wrong, because the plan reads as "this is a 14-week
project" when it's actually a "couple of weeks of dependency-ordered work plus
some long-pole data assembly."

**How to apply:**
- Replace "Days X-Y / N weeks" with dependency language: "After Phase N",
  "Parallel with Phase M", "Gates Phase K".
- If pressed for an estimate, frame as "overnight" / "a couple of sessions"
  / "a few sessions" — never weeks unless it's truly large scope (frontend
  rebuild, full survivorship data assembly).
- The three things in Atlas v6 that ARE genuinely calendar-heavy: frontend
  rebuild, survivorship-corrected universe data assembly, and production-grade
  daily inference pipeline (the engineering-reality 10x gap). Everything math
  is overnight-class.

Related: [[project_signal_discovery_2026_05]], [[feedback_simplify_adopt_libraries]],
[[feedback_focused_scope]].
