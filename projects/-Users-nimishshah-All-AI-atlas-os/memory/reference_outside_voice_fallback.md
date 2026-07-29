---
name: outside-voice-fallback
description: Outside-voice cascade for plan reviews when codex quota walls. User wants gemini-cli as a non-Claude option.
metadata: 
  node_type: memory
  type: reference
  originSessionId: 2ff217a8-ee34-4358-b1a3-6ac996e1cccf
---

When `/plan-ceo-review`, `/plan-eng-review`, or `/codex:adversarial-review`
hit `Quota exceeded` on Codex CLI, the fallback chain is:

1. **Codex CLI** (`codex exec ... -s read-only`) — preferred when quota
   available.
2. **Gemini CLI** — user preference; NOT installed as of 2026-05-24.
   To install: `npm i -g @google/gemini-cli` (or similar; verify the
   actual package name when installing). Has `~/.gemini` config from
   Antigravity/VS Code but no CLI binary on PATH.
3. **Claude subagent** via `Agent({subagent_type: "general-purpose"})` —
   genuinely independent context inside same model family; suitable
   when only one outside voice is available.

User has explicitly said (2026-05-24) "you can use gemini too" — install
the CLI when convenient so we have a non-Claude option available for
adversarial review.
