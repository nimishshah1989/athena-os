---
name: Use Opus 4.7 for code implementation
description: Nimish wants Opus 4.7 delegated for all M3+ code building (not planning/review)
type: feedback
originSessionId: 9c0f4d4f-615d-4fcc-b7a1-8acb49cf490e
---
When building milestone code (new modules, backfill scripts, validation extensions), spawn an Agent with `model: "opus"` to write the implementation. Planning, review, and orchestration stays in the main session (Sonnet).

**Why:** User explicitly requested "lets use opus 4.7 for building this code" at the start of M3 build work.

**How to apply:** After /plan-eng-review completes and decisions are locked, spawn `subagent_type: "implementer"` or general-purpose Agent with `model: "opus"` for each build phase. Pass the full decision set and file context in the prompt.
