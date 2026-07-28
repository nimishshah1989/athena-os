---
name: Use the FULL Forge Engineering OS — no shortcuts
description: Every Forge tool must be used as specified — ralph, review, ship, guard, forge-compile. Never skip any step
type: feedback
---

NEVER skip or bypass any part of the Forge Engineering OS. The user built this system deliberately and every tool exists for a reason.

**Why:** User was furious that I ignored the forge-build sequence, skipped /review, /ship, /guard, /forge-compile, and bypassed Ralph. Despite clear instructions in CLAUDE.md listing all gstack skills and forge commands, I only used the bare minimum (implementer + raw git). This is unacceptable.

**How to apply:** 
- Every chunk MUST go through: implement → /review → /ship → /forge-compile
- /guard MUST be activated before building
- Ralph MUST be offered/set up for autonomous builds — never assume supervised mode
- ALL gstack skills listed in CLAUDE.md are active and expected to be used
- When /forge-build specifies a sequence, follow it EXACTLY — no skipping steps
- If a step seems unnecessary, ASK before skipping — never decide unilaterally
