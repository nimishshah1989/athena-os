---
name: feedback-agent-parallelism
description: "Don't launch too many parallel agents at once — server rate limits get hit"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: e0d52c47-d081-44f6-94a6-bef734408e59
---

Don't start with too many agents in parallel. Previous session hit API rate limits when launching multiple parallel research subagents simultaneously.

**Why:** Server-side rate limiting, not user quota limits. Parallel agent fan-outs hit the same rate limit pool.

**How to apply:** For research workflows, launch 2-3 parallel agents max at a time. Sequential is fine. When exploring data science domains, rely on training knowledge for expert-level content rather than web search subagents where possible.
