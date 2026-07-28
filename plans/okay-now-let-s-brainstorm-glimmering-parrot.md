# Athena OS v2 — Build Operating System Redesign

## Context

A non-technical founder runs 5 production repos (atlas-os, beyond, careerplus, jaltantra, Lemon) on a self-built Claude Code "operating system." Complaints: inconsistent development, voice notes not translating into reliable work, six months producing no captured learnings, over-engineered code, junk accumulating in repos, and no visibility into quality.

Investigation found specific, verifiable causes — not vague drift. The three that reframe everything:

1. **Learning was never broken the way it appeared.** Claude Code's native auto-memory has been capturing all along — **224 files across 21 project directories** (atlas-os: 79). The `~/.claude/wiki/` being rebuilt was a redundant *third* system layered on a working one. The actual bug: **189 of 224 files are 60+ days stale. Nothing evicts.**
2. **Skill ambiguity, not skill absence.** 86 skills with 3-way duplication (3 debugging skills, 3 skill-writing, 2 TDD, 3+ planning pipelines). Per Anthropic: *"if a human engineer can't definitively say which tool should be used, an AI agent can't be expected to do better."* This is the inconsistency — a coin flip several times per session.
3. **Every failure was silent.** `session-harvest.sh` read a nonexistent JSON field, called an invalid flag, and pushed to a nonexistent directory — all errors swallowed by `2>/dev/null || true`. `skill-activator.sh` routes to 9 skills registered nowhere (verified: `Unknown skill`). `decisions.jsonl` has 40,335 lines where 2,471 of 2,472 records hash the character `}`. `.remember/` has 2,236 files containing zero memories.

Outcome sought: one unambiguous pipeline, memory that survives, mechanically-enforced simplicity and quality, and production-grade architecture legible to a non-technical founder.

---

## P0 — Do these three things first

1. **Move `atlas-os` out of iCloud.** Its own CLAUDE.md says the tree "MUST live outside any iCloud-synced folder" (prior `.git` corruption documented). It sits at `~/Documents/N-AI/dev/atlas-os`; `brctl status` confirms iCloud is tracking files inside it now. 1,037 commits, live prod, ~200 PMS clients. Move to `~/dev/atlas-os`, `git fsck` to verify.
2. **Upgrade Claude Code** (2.1.101 → current). Free: MEMORY.md size warnings + hard error on overflow, auto `modified:` timestamps, `/doctor` CLAUDE.md trimming. These are the heartbeat/canary/last-write mechanisms that would have made every silent failure loud.
3. **`git init ~/.claude`.** The entire build OS is unversioned — which is why this session's revert had to be done by hand. Do this before any other change.

---

## Part 1 — The pipeline and the exact skills

One skill per stage. This table becomes the routing section of the global CLAUDE.md.

| Stage | Skill | Trigger |
|---|---|---|
| Intake (voice → intent) | `superpowers:brainstorming` | Any new feature or vague ask |
| Spec | `gstack:spec` | Intent settled, scope needs freezing |
| Plan | `superpowers:writing-plans` | Spec exists |
| Plan review | `gstack:plan-eng-review` + `plan-ceo-review` | Before any code |
| Chunk | `chunkmaster` | Plan approved |
| **Execute (multi-task)** | **`superpowers:subagent-driven-development`** | **≥3 independent tasks, or context >50%. Default ON for any multi-chunk phase.** |
| **Execute (single plan)** | **`superpowers:executing-plans`** | **Sequential plan with review checkpoints** |
| **Parallel work** | **`superpowers:dispatching-parallel-agents`** | **2+ tasks with no shared state** |
| Build | `superpowers:test-driven-development` | Every chunk |
| Eval (AI features) | Eval set — Part 5 | Any model-generated output |
| Verify | `superpowers:verification-before-completion` | Before claiming done |
| Debug | `superpowers:systematic-debugging` | Any bug |
| Code review | `gstack:review` | Chunk complete |
| Security | `gstack:cso` | Phase gate |
| Design review | `gstack:design-review` | Any UI change |
| Ship | `gstack:ship` | Phase complete |
| Retro | `gstack:retro` | Weekly |

**Subagent-driven development is off by default in Opus 5 unless explicitly invoked.** The routing table makes it explicit — this was missing and is now a first-class stage with named triggers.

**Archive to `~/.claude/skills/_archive/` (move, never delete):** duplicates (`gstack:investigate`, `mattpocock:diagnose`, `mattpocock:tdd`, `gstack:skillify`, `mattpocock:write-a-skill`); redundant plan personas (`gstack:autoplan`, `plan-design-review`, `plan-devex-review`, `plan-tune`); two of three intake skills (`founder-coach` / `office-hours` / `to-prd` — keep `office-hours` for business strategy only); all 9 phantom skills in `~/.claude/skills/public/`; the duplicate `ui-ux-pro-max` install.

**Prevent recurrence mechanically:** adopt `run_trigger_evals.py` from `awesome-llm-apps/agent_skills/evals/` — it asserts no two skill descriptions share >50% vocabulary, **with zero model calls**. Ambiguity gets caught as skills are added back.

**Remove hooks:** `skill-activator.sh` (never worked, redundant once routing lives in CLAUDE.md), `session-start-skill-loader.sh` (points at nonexistent `~/forge-skills/`), `post-edit-decision-log.sh` (writes the broken `decisions.jsonl`).

---

## Part 2 — Memory (corrected: use what exists, add eviction)

**Do not build a wiki.** Native auto-memory is GA, on by default, and already holds 224 files. `MEMORY.md` is already the index-with-pointers pattern, with native progressive disclosure (first 200 lines / 25KB loads; topic files load on demand). That is the retrieval solution, already shipped.

**Three chores, no new machinery:**

1. **Delete `~/.claude/wiki/`** — empty, third failed attempt, competes with the working system. Subtract.
2. **Prune the 189 stale files once, by hand** — start with atlas-os's 79. Then a quarterly `find -mtime +90` review. **Not a hook, not a daemon** — hooks are exactly what died silently before.
3. **Never write prose describing what code can regenerate.** Structure/call-graph questions go to `serena` and `tokensave` (both installed, barely used); prose memory holds only *why* — decisions, rejected alternatives, what was tried and failed. Prose about structure is the content that rots.

**Do not ask the model to judge staleness** — the STALE benchmark measures frontier models detecting invalid stored memories at 55.2% accuracy. Give it dates instead (the upgrade provides them automatically).

**Per-repo memory files** — the audit found the 4-file structure is *bypassed* at scale (atlas-os wrote STATE/HANDOFF/DECISIONS-LOG exactly once, on an unmerged branch, so `main` has none) and *bloated* at mid-scale (beyond: 135KB + 114KB + 148KB ≈ 100k tokens to load the memory that exists to save context). Breaking point: 100–334 commits.

| File | Rule |
|---|---|
| `HANDOFF.md` | Current session block only, ~50 line cap. Evict to `docs/handoffs/YYYY-MM-DD.md`. atlas-os's 42-line version is the model — the format works, the discipline failed. |
| `STATE.md` | Pointer index, not narrative. Every claim names how it was verified. |
| `STATUS.md` | **Generated by a command, never hand-written.** Required past ~150 commits. Every claim carries evidence + a `Method:` block. |
| `DECISIONS-LOG.md` | One line, stable ID, points to an ADR. jaltantra's format is the model: `D-004 \| XGBoost over LSTM: ~1,100-5,600 training rows too sparse` — names the rejected alternative and the number that killed it. |
| `docs/adr/` | Topical records. Chronological logs die at scale (atlas-os: 1 entry) or bloat (beyond: 148KB). **ADRs need a trigger:** any decision that rejects an alternative gets one. |

**Delete outright:** `decisions.jsonl` (broken chain, invalid JSONL, 552KB in beyond, documented merge-conflict source) and `.remember/` (2,236 files, zero memories).

**Cross-repo learnings** (the one real gap — native memory is per-project): truly reusable lessons go into `~/.claude/CLAUDE.md` or `~/.claude/rules/`, which load everywhere. No new system.

---

## Part 3 — Preventing over-engineering (a)

**Why the current approach under-performs, mechanically.** Research finding: [omission constraints decay while commission constraints persist](https://arxiv.org/pdf/2604.20911) in long-context agents. Instructions to *not do* something ("no unrequested abstractions", "don't over-build") degrade sharply as context grows; instructions to *always do* something stay robust. Ponytail is ~90% omission constraints injected once at turn 0 — precisely the class that decays. Compounding: instruction adherence decays with instruction count, and models can restate constraints they are actively violating (so "it acknowledged the rule" proves nothing).

**Fix = mechanical gate first, prompt second.**

1. **[aislop](https://github.com/scanaislop/aislop)** (516★, active) as a pre-commit hook in quality-gate mode. TypeScript + Python, 50+ deterministic rules, sub-second, no LLM in the path. Function/file size limits, nesting depth, dead code. **Has baseline + ratchet** — capture today's baseline so existing debt is frozen and only regressions block. Also ships a Claude Code post-edit hook.
2. **[complexipy](https://github.com/rohaquinlop/complexipy)** (740★, Rust) for Python cognitive complexity: `--snapshot-create` freezes debt, `--diff main` fails only on regression.
3. **[betterer](https://github.com/phenomnomnominal/betterer)** for TypeScript, only if aislop's TS depth proves thin.
4. **Convert the persona to commission form.** A PostToolUse hook on Edit/Write firing ~3 lines *late in context, in positive form*: "State which ladder rung you used. State what you deleted." This turns the decaying constraint into the persistent kind. Keep ponytail — demote it from only defence to first defence.

---

## Part 4 — The chunk goal function and the auto-operating loop (c, and the "does it actually work" question)

A chunk is not started until it has a **goal function**: 3–5 machine-checkable success criteria. If they can't be written, ask one question and stop — don't build and discover the goal later.

```
frame (goal function + budget) → build → check → verdict
                                    ↑                │
                                    └──── FIX ───────┤
                                                     ├─ PASS      → next chunk
                                                     └─ ESCALATE  → founder
```

Three rules, adapted from `agent_skills/advisor-orchestrator-worker/SKILL.md`:

1. **The check must exercise the deliverable itself.** Banned: grepping a README, testing something adjacent, printing `True` while exiting zero. TDD reinforces this — a test written from acceptance criteria *before* the code tests the requirement, not the implementation that happens to exist.
2. **Verdict: PASS / FIX / ESCALATE.** On FIX, redispatch naming the failure. **Never hand-patch a substantive failure** — that's how an agent routes around its own failed goal and reports success. Not theoretical: beyond's DECISIONS-LOG records *"the last two 'fixed and deployed' claims both turned out to still be broken."*
3. **Budget declared at frame time**; overrun escalates rather than continuing silently. Status line per chunk: `C7: FIX → PASS | 1 retry`.

### Real-user functionality testing (c)

Unit tests are not the gate. Every phase requires a **scripted real-user journey through the actual UI in a real browser** (Playwright MCP), with edge cases enumerated in writing, not assumed. Required because this has already burned him: jaltantra's own HANDOFF records *"headless has no WebGL, so the maplibre RAG choropleth was NOT visually verified."*

Per phase: happy path + 3–5 named edge cases (empty state, permission-denied, stale data, network failure, boundary values) + one adversarial pass (`gstack:qa`). Failures become regression tests.

---

## Part 5 — Evals (AI output quality)

Every product here is AI-heavy with zero eval discipline. Tests verify code paths; **evals verify model output**. A tutor explaining physics wrongly, a miscalibrated fit-score, or a hallucinated client fact passes every unit test.

**Rule: any feature whose output comes from a model ships with an eval set.**

- `evals/<feature>/` per repo — cases, expected properties, scoring script.
- Prefer programmatic assertions (`contains`, `regex`, structural, numeric tolerance) over LLM-judge. Judge only where taste is genuinely what's measured.
- **Baseline + ratchet** in CI — score may never regress.
- Use Anthropic's `evals.json` schema (`{id, prompt, expected_output, expectations[]}`) — existing tooling runs it unmodified, and its `expectations[]` are negative/process assertions ("no file write before the user chooses"), a better shape than output-matching.
- Retroactive: Beyond's fact extraction, CareerPlus's fit-scoring + drafter/reviewer, Atlas's decision engine — backfilled as each is next touched.

---

## Part 6 — Code quality scoring (d)

Target: **≥8/10 on every dimension, trending to 10.** Honest caveat: a score is meaningless unless each dimension has a mechanical rubric — otherwise it drifts into a vibe. Each dimension below is machine-computed.

| Dimension | Measured by | 8/10 means |
|---|---|---|
| Complexity | aislop + complexipy | No function over threshold; ratchet holding |
| Type safety | pyright / tsc | Zero new errors; baseline never rises |
| Test coverage | pytest-cov / vitest | ≥80% on changed code |
| Eval score | `evals/` in CI | No regression vs baseline |
| Security | `gstack:cso` + `supabase get_advisors` | Zero RLS-missing tables, zero high findings |
| Architecture | `tokensave` god_class / coupling / circular | No circular deps; no god class; coupling flat |
| API health | contract tests + error rates | All endpoints typed, no 5xx in normal paths |
| Docs | `tokensave doc_coverage` | Public module APIs documented |

**Token efficiency:** static analysis runs on every commit and costs **zero tokens**. LLM review runs weekly and only on what static analysis cannot judge. Never re-review unchanged code.

---

## Part 7 — One design language (b, g)

A single global file — `~/.claude/design/DESIGN-LANGUAGE.md` — referenced by every project's CLAUDE.md. It applies to everything from a one-off artifact to a full platform, **unless a project explicitly overrides it**.

Three philosophies, chosen because they cover distinct failure modes:

1. **Feynman (ELI5) — comprehension.** If it can't be explained plainly, it isn't understood. Rules: one idea per screen; explain the number next to the number; plain label over jargon; progressive disclosure (summary first, detail on demand). Test: *could a smart person outside this domain use this without a glossary?*
2. **Tufte — information density.** Maximize data-ink; remove chrome that carries no information. Reconciles with #1: dense is fine, *cluttered* is not. Financial professionals want detail; they don't want decoration.
3. **Dieter Rams — restraint.** "As little design as possible." Good design is unobtrusive. This is the ponytail ladder applied to interface: every element must justify existing.

Plus the mechanics already in `~/.claude/rules/frontend-viz.md` (teal `#1D9E75`, lakh/crore, ± signs, right-aligned numerals, DD-MMM-YYYY).

**Frontend build order, fixed:** design system once (`gstack:design-consultation` → `design-system/PRINCIPLES.md` + tokens) → build with `tailwind-design-system` + `ui-ux-pro-max` under a **reuse gate (≥3 existing components checked before writing a new one** — a rule atlas-os's chunk template already had and never generalized) → charts via `dataviz` → verify in a real browser → `gstack:design-review` last, to catch AI-slop patterns.

---

## Part 8 — Production-grade architecture (h)

These are client-facing systems with regulatory exposure, not prototypes. Encoded as an architecture standard in the global CLAUDE.md and checked at every phase gate:

- **Modular, not monolithic.** Clear module boundaries with explicit public APIs. Enforced mechanically: `tokensave` circular-dependency, coupling, and god-class detection at the review gate.
- **Auth on every route, server-side.** Never trust a client-supplied user id. RLS on every table, verified via `supabase get_advisors` before schema work is called done. A disabled auth gate is a ship blocker, not a TODO.
- **Debuggability as a requirement.** Structured logging with request IDs, no PII. Errors surface to a monitored channel — atlas-os's failure surface is currently a database table nobody watches.
- **Documentation that survives.** Module-level "what this owns" docs; ADRs for decisions; a source-of-truth precedence table with a tie-break rule. Evidence this is needed: four atlas-os documents state the schema version four different ways (122 / 123 / ~124 / 124).
- **From the founder's own best document** (`atlas-os/docs/engineering-process.md`, self-written, never generalized): `main` always equals production; CI on every PR ("highest leverage"); one-command deploy; staging DB before risky migrations; **never let a branch live 8 days**; and AI reviewers on a PR are a legitimate substitute for a second human reviewer on a solo team.

---

## Part 9 — Repo hygiene (i, j)

**Standard `.gitignore`** applied to every repo. Currently accumulating in atlas-os alone: `.ruflo/`, `.remember/` (2,236 files), `.pytest_cache/`, `.mypy_cache/`, `.playwright-mcp/`, `*.egg-info/`, `decisions.jsonl` (305KB). A pre-commit check rejects known junk paths.

**Quarterly sweep** (manual, in the weekly report's scope): untracked junk, files >1MB, logs, orphaned test scripts, branches older than 8 days.

**Default project structure**, same shape at every size — only depth varies:

```
<repo>/
  CLAUDE.md            frontmatter + precedence table + local rules
  STATE.md HANDOFF.md DECISIONS-LOG.md
  SPEC.md
  docs/  adr/  handoffs/  chunks/
  backend/   app/{api,services,models,core}  tests/  evals/
  frontend/  src/{app,components,lib}  tests/
  design-system/PRINCIPLES.md
  migrations/
  research/
  .gitignore .env.example
```

Small projects collapse `backend/`+`frontend/` into `src/` but keep every other file. Consistency is the point — the structure should be predictable without exploring.

---

## Part 10 — Weekly report (visibility)

Scheduled, one page, plain English:

- **Shipped** — from git history
- **Learned** — memory files written, corrections captured
- **System improving?** — skills changed, SkillOpt scores, **edits the gate rejected** (proof the gate is live)
- **Quality scorecard** — the 8 dimensions from Part 6, with trend
- **Debt** — open `ponytail:` markers, stale memory, branches >8 days, junk files
- **At risk** — blocked, contradicted, or unverified

**The rule that makes it honest: it reports what did NOT happen.** Six months produced no visible learnings because every failure was silent. Any check that never ran, any skill that never fired, any eval that never executed — named in bold.

---

## Part 11 — SkillOpt (validated self-improvement)

`microsoft/SkillOpt` (15.2K★, MIT, arXiv:2605.23904). Use `skillopt_sleep/` — the shipped Claude Code path.

- **Input:** 15–30 tasks, `skillopt_sleep.tasks.v1`. Auto-split, `holdout_fraction=0.34`.
- **Reward:** programmatic rule checks (`section_present`, `regex`, `min_chars`, `tool_called`) — **no LLM judge required**.
- **Backend:** `--backend handoff` — no API key, subscription-friendly.
- **Keep the gate ON.** Ungated, the repo's own results show a benchmark collapsing 0.554 → 0.026 via reward hacking. Gated: 0.0 loss.
- **Limit:** it grades *shape*, not taste. Apply to spec/handoff/report formats. **Never** to code review or architecture judgment.

---

## Part 12 — What else matters (k)

Gaps not yet covered, ordered by risk to a solo non-technical founder running client-facing systems:

1. **Backup and tested restore.** atlas-os serves ~200 PMS clients. An untested backup is not a backup. Verify a restore actually works.
2. **Error monitoring.** Failures currently surface only in a database table (`atlas.atlas_data_health`) that nobody watches. Needs a channel that reaches a human.
3. **Dependency security patching.** Dependabot/Renovate on every repo. Nothing currently tracks CVEs in dependencies.
4. **Secrets rotation + a leak drill.** Rules exist; no evidence of practice.
5. **Rollback plan per deploy.** Knowing how to undo is worth more than deploying carefully.
6. **Cost observability per user/session.** LLM calls in product paths; margin dies quietly when unmetered.
7. **Migration safety.** atlas-os already has stamp drift (`alembic_version=112` vs schema ~124) and a migration 064 IMMUTABLE-index bug that breaks a clean `alembic upgrade head`. That's a live blocker on any fresh environment.
8. **Bus-factor documentation.** If he ever brings someone in, can they start? Right now the answer is no for every repo.

---

## Phasing

| Phase | Work | Gate |
|---|---|---|
| **P0** | iCloud move · Claude Code upgrade · `git init ~/.claude` | `git fsck` clean; version confirmed |
| **P1** | Delete `decisions.jsonl` + `.remember/` + `~/.claude/wiki/` + 3 dead hooks | Repos clean; nothing broken |
| **P2** | Skill cut to ~18 · description-collision check · MCP dedupe | Every routing-table skill loads (the exact thing that failed for `feature-forge`) |
| **P3** | Prune 189 stale memory files · memory-file caps | `/context` shows the drop |
| **P4** | Global + project CLAUDE.md rewrite · DESIGN-LANGUAGE.md · architecture standard | Fresh session routes correctly per repo |
| **P5** | aislop + complexipy baselines · commission-form hook · standard `.gitignore` | A deliberately over-complex commit gets blocked |
| **P6** | Quality scorecard · eval harness · real-user journey tests | Scorecard produces real numbers |
| **P7** | Weekly report routine | First report delivered, names what didn't happen |
| **P8** | SkillOpt harness | Gate demonstrably rejects at least one edit |

**Pilot P3–P6 on `careerplus` first** (81 commits, healthy memory, not live-prod). **atlas-os is last** — live production, 200 clients downstream.

---

## Execution commitment

The founder is non-technical. Every change is executed **with him, step by step**: exact command shown before running, output shown after, one phase at a time, each approved before the next. Nothing deleted where a move will do. `git init ~/.claude` in P0 exists so every later change is revertible with one command.

## Verification

- **P0:** `git fsck` clean at new path; `brctl status` shows no repo files; `claude --version` current.
- **P2:** Invoke every routing-table skill — all load. Collision check passes.
- **P3:** `/context` shows measured token reduction; stale count drops from 189.
- **P5:** Commit a deliberately over-engineered function — the hook must block it. If it doesn't, the gate is theatre.
- **P6:** Scorecard emits numbers for all 8 dimensions; a real-user journey runs end-to-end in a visible browser.
- **P7:** First weekly report explicitly names something that did not happen.
- **P8:** SkillOpt rejects ≥1 candidate edit, proving the gate is on.
