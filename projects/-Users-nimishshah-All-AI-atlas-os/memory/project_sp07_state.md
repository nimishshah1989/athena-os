---
name: project-sp07-state
description: SP07 Hermes Agent Runtime current state — tool-retry fix uncommitted
metadata: 
  node_type: memory
  type: project
  originSessionId: cb74b01c-0aea-4d84-a3c3-dd7e6d2d7b4e
---

SP07 specialists live on EC2 via Groq Llama 3.3 70B. CLI + REST endpoint at /api/agents/invoke.

Tool-call retry fix (atlas/agents/specialists/base.py):
- Added _TOOL_CALL_RETRIES = 2
- Retry loop on tool_use_failed / Failed to call a function errors
- Falls back to SEBI guard after all retries exhausted
- Fix is in working tree but NOT yet committed (user must `git add atlas/agents/specialists/base.py && git commit`)

**Why:** Groq Llama 3.3 70B emits XML-style function calls ~30-50% of the time causing HTTP 400; retrying the same payload usually succeeds.

**How to apply:** SP07 is stable for use; commit the fix before pushing to EC2.
