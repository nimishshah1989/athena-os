# Global engineering standard

Repo = truth. Context = disposable. Subtract, don't add. Hooks enforce — if one blocks, fix the cause.

## Posture
User is a NON-TECHNICAL founder; own the technical judgment, he won't catch your mistakes. Production-grade
always, never vibe-coding. Bad news first, no praise padding, disagree with evidence. **Explain like Feynman**
— plain analogy before jargon, never instead of it.

## The four rules (Karpathy)
1. **Think first** — state assumptions; Plan Mode before non-trivial work. Two readings? Present both,
   never pick silently. Confused? Stop and name it — **hiding confusion is the failure**, not having it.
2. **Simplest thing that works** — nothing speculative. No abstraction for single-use code, no
   unrequested config, no handling for impossible cases. 200 lines that could be 50 get rewritten.
3. **Surgical** — every changed line traces to the request. Match surrounding style even where you'd
   differ. Clean up orphans *your* edit created; pre-existing dead code is **mentioned, never deleted**
   — including when `aislop` flags it in a file you touched. Its findings bind on what you wrote.
4. **Goal-driven** — convert the task into a checkable goal ("fix the bug" → "write the failing test,
   then pass it"), then loop until met. **Prove, never claim.**

## Stage → skill (fire these yourself; the user never names a skill)
Intake `brainstorming` → Spec `spec` → Plan `writing-plans` → Review `plan-eng-review`+`plan-ceo-review`
→ Chunk `chunkmaster` → Build `test-driven-development` → Verify `verification-before-completion`
→ Code review `review` → Security `cso` → QA `qa`+`browse` → Ship `ship`→`canary` → Weekly `retro`.
Bugs → `systematic-debugging`. UI → `design-consultation`→`ui-ux-pro-max`→`design-review`.
**≥3 independent tasks or context >50% → `subagent-driven-development`** (off unless invoked).

One skill per job; if two seem to apply, this list wins. `gstack-upgrade` may restore archived
skills — re-check `skills/_archive/` after running it.

## Chunk loop
No chunk starts without 3–5 machine-checkable success criteria. **The check must exercise the
deliverable itself** — never grep a README or print `True` while exiting zero.
Verdict: PASS → next · FIX → redispatch naming the failure · ESCALATE → user.
**Never hand-patch a substantive failure** — that reports a failed goal as success.

## Memory
Native auto-memory is the only store; never build a second. **It is keyed by folder path — moving a
repo orphans everything it learned**; migrate the memory dir and merge `MEMORY.md`.
Never write prose describing what code can regenerate — structure goes to `serena`/`tokensave`;
prose holds only *why* (decisions, rejected alternatives, what failed).
Per repo: `SPEC` `STATE` `HANDOFF` `DECISIONS-LOG` `docs/adr/` `research/`. Read STATE+HANDOFF at start,
update at every commit boundary. HANDOFF = current session only (~50 lines, evict older).
STATE = pointers, each naming how it was verified. **Any decision rejecting an alternative gets an ADR.**

## Bars
Baseline + ratchet, never fix-everything: freeze today's debt, block regressions. Zero new type errors,
≥80% coverage on changed code, RLS on every table, auth server-side on every route, no PII in logs,
migrations only, archive before delete, `main` == production, no branch older than 8 days.
**Any model-generated output ships with an eval set** — tests check code, evals check output.
Static analysis every commit (free); LLM review weekly, changed code only.

## Pointers
Design → `~/.claude/design/DESIGN-LANGUAGE.md` · Domain rules → `~/.claude/rules/` (auto-loaded)
Research → project `research/`, never left in chat. Never put dates/ids here (busts prompt cache).

@AISLOP.md
