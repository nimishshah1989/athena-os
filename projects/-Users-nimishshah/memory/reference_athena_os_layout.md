---
name: reference-athena-os-layout
description: "Where everything lives — repos in ~/All AI, config in ~/.claude reached via the _os symlink, bin/doctor proves the wiring"
metadata: 
  node_type: memory
  type: reference
  originSessionId: f34205e6-1748-433d-a426-df8c2fdfa990
  modified: 2026-07-29T10:08:14.420Z
---

Settled 2026-07-29.

- **Projects:** `~/All AI/` — atlas-os, beyond, careerplus, jaltantra, project-lemon,
  Yours-Truly-Intelligence, "maal client reporting". Plus `_reports/` (weekly), `_archive/`
  (bundles and old transcripts), `_os` → symlink to `~/.claude`.
- **Config:** stays at `~/.claude`. **Do not move it.** Memory is keyed by absolute folder path,
  so relocating the config dir orphans everything — the exact failure the rebuild was undoing.
  The `_os` symlink gives one entry point without the breakage.
- **Remote:** `github.com/nimishshah1989/athena-os`, **private**, default branch `main`.
  Made private on 2026-07-29 — it had been public with memory, FOUNDER.md and a live DB
  password in history.

**Verification:** `~/.claude/bin/doctor` — fires each hook with a bad payload (must block) and a
good one (must pass), checks the launchd weekly routine, memory-index integrity both directions,
design tokens, and per-repo CLAUDE/STATE/HANDOFF. Exits non-zero on any failure.
Other tools: `bin/scorecard`, `bin/weekly-report`, `bin/rekey-memory`.

**Gotcha:** project dirs under `~/.claude/projects/` start with `-`, so bare `du -sh <dir>`
parses them as flags and reports nothing. Always prefix `./`. This produced two badly wrong
size readings before it was caught.

Related: [[athena-os-v2-rebuild]], [[reference-claude-artifact-exports]].
