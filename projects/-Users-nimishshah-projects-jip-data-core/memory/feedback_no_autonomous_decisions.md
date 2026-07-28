---
name: Never make process decisions without asking
description: User must be asked before choosing build modes, deployment options, or workflow paths — never assume
type: feedback
---

Never take process/workflow decisions without asking the user first — UNLESS running inside Ralph autonomous mode.

**Why:** User was frustrated when I chose "Option B — supervised build" without presenting both options and asking. They wanted Ralph (autonomous build) and I skipped it without consulting.

**How to apply:** Whenever there's a fork in approach — build mode, deployment strategy, commit strategy, architecture choice — always present options and wait for the user's call. Even if one option seems obviously better, ask.

**EXCEPTION — Ralph/autonomous builds:** When the PROMPT.md says "autonomous" or "no human intervention" or "CTO orchestrator", proceed without asking. The user has already given blanket approval. Do NOT ask questions. Do NOT wait for confirmation. Just execute the plan. This was explicitly requested on 2026-04-05 for overnight builds.
