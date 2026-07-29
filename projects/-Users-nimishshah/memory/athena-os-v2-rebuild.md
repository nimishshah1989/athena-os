---
name: athena-os-v2-rebuild
description: "What was actually wrong with the build OS, what was fixed 2026-07-28/29, and the rules that came out of it"
metadata: 
  node_type: memory
  type: project
  originSessionId: 5784752c-2f12-4c60-88db-9cd4606b624f
  modified: 2026-07-29T07:23:16.153Z
---

The founder's complaint — "six months of building, barely any learnings, development
is inconsistent" — had three concrete causes, all verified on disk, none of them vague
process drift.

**1. Memory was never lost, it was orphaned.** Claude Code keys project memory by folder
path (`~/.claude/projects/<encoded-path>/memory/`). atlas-os moved twice
(`Documents/GitHub` → `Documents/N-AI/dev` → `~/All AI`), and each move silently stranded
79 files of real captured learnings — his own directives ("no calendar estimates, they're
5-10x too high"), corrections, and architecture decisions. The system had been learning
the whole time. **Tool built: `~/.claude/bin/rekey-memory`** — run it after moving any repo.

**2. Inconsistency came from skill ambiguity, not skill absence.** 86 skills with 3-way
duplication (3 debugging skills, 2 TDD, 3+ planning pipelines). Cut to 25 active, one per
job, with a routing table in the global CLAUDE.md. Archived to `skills/_archive/`.
`gstack-upgrade` may restore them — re-check after running it.

**3. Every failure was silent.** `session-harvest.sh` read a nonexistent JSON field, used
an invalid CLI flag, and pushed to a nonexistent directory — all errors swallowed by
`2>/dev/null || true`. `skill-activator.sh` routed to 9 skills registered nowhere.
`decisions.jsonl` had 40,335 lines where 2,471 of 2,472 records hashed the character `}`.
`.remember/` held 2,236 files containing zero memories. Four competing memory systems,
all trusted, none verified. All removed.

**Over-engineering has a mechanistic cause.** Omission constraints ("don't over-build")
decay in long context; commission constraints ("always state X") persist
(arXiv:2604.20911). Ponytail is ~90% omission constraints injected once at turn 0 —
structurally the wrong shape, which is why it was active while the problem continued.
Fixed with `aislop` as a mechanical gate (PostToolUse + Stop hook, baseline+ratchet).
Verified catching real defects, not theatre.

**Quality baseline at rebuild (aislop /100):** careerplus 44, jaltantra 20 (20 confirmed
defects), beyond 12 (501 warnings), atlas-os unmeasured. Target ≥80. Ratchet: freeze
today's debt, block regressions — never fix-everything.

**Standing rules that came out of this:**
- One memory path verified by a command beats three trusted by assumption.
- Never write prose describing what code can regenerate (that's what rots) — structure
  goes to serena/tokensave, prose holds only *why*.
- Global CLAUDE.md stays ≤50 lines — instruction adherence decays with instruction count.
- Don't build what Claude Code already ships (native auto-memory replaced the wiki).
- iCloud destroys git repos: `git status` in atlas-os went from 2-minute timeouts to
  0.45s once moved out. All projects now consolidated in `~/All AI/`.

Related: [[project_atlas_os]] · [[feedback_operating_system_evolution]]
