---
description: Interview the operator via 7 plain-English questions and emit a draft PRD at prds/<name>.md. Use when starting a new product.
---

Activate the `founder-coach` skill (in ~/.claude/skills/founder-coach/SKILL.md).

The argument to this command is the project name (kebab-case, lowercase, e.g. `cas-analyzer`). Use it as the filename: `prds/<argument>.md`.

If no argument is given, ask the operator for the project name first, then proceed.

Follow the founder-coach skill's instructions verbatim — 7 questions, one at a time, plain English, restate answers before continuing. Emit the PRD at the end.
