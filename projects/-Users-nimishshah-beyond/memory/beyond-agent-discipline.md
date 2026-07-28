---
name: beyond-agent-discipline
description: "Beyond's non-negotiable product laws for the agent layer — how every agent must behave"
metadata: 
  node_type: memory
  type: project
  originSessionId: 5e6a13b9-8a58-46ea-bef9-06af1be65cc2
---

Beyond Relationship OS agent layer (built 13-Jul-2026). Every agent, present and future, obeys these — they are product law from SYSTEM-DESIGN.md, not preferences:

- **Agents DRAFT, advisors SEND.** Nothing client-facing goes out autonomously. Agents write to the `approvals` table (draft_payload + evidence_pack); a human approves/edits/rejects in the Inbox. The actual send rail is deliberately UNWIRED until it has its own controls.
- **Deterministic math in code; the model only touches language.** XIRR, valuations, scores, occasion dates — all deterministic Decimal code. `beyond/model.py` (Bedrock Mumbai GLM) is only for drafting/extraction/phrasing, and every model call degrades gracefully (ModelError → structured result, never a 500).
- **Provenance on every derived row.** Facts carry source_interaction_id + quote_span + source_tier; supersede-never-delete via `beyond/reconcile.py`. No PII in logs (ids + counts only).
- **Org-scoped always** (advisor's token, never client-supplied id). Every agent has its own test file; **run only that file** in parallel builds — the shared local Supabase has a concurrent-pytest wipe race (authoritative run is `pytest tests/ -p no:randomly` solo).
- **Orchestration pattern that worked:** strict per-agent file ownership; agents FORBIDDEN to touch main.py/layout.tsx (the orchestrator wires routers + nav centrally); agents commit only their own files; orchestrator reconciles, runs the scripts to populate data, builds frontends, deploys once, screenshot-verifies.

See also [[parallelize-with-agents]], [[founder-zero-friction-law]].
