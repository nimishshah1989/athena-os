---
name: feedback-skill-loop-process
description: "Atlas v6 frontend build MUST go through the full skill-driven loop — never implement directly. User explicit instruction (2026-05-26): use plan-design-review → plan-eng-review → writing-plans → codex review → subagent-driven-development → design-review → qa. Always include a fund-manager-critic subagent that challenges every page from Bhavin's POV."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: b59586b9-3103-4e5d-91ea-24bffe155f3d
---

User's explicit instruction (2026-05-26 ~00:20 IST), reinforced through this session:

> "NEVER JUST IMPLEMENT AND START CODING ; ALWAYS RUN THE RIGHT SKILL DRIVEN PROCESS AND ENSURE YOU USE THE BEST SKILLS AND MULTIPLE REVIEWS AND THE LOOP TO CLOSE ALL ISSUES TILL NO ISSUES REMAIN"

> "Make sure that you have an agent, an independent agent or a reviewer, who is constantly thinking from a fund manager's point of view on every page and challenging and making it better."

> "Make sure that you are updating your memory with the process that you just mentioned, so that in every instance that starts in the build, that process is followed and you do not just mention it and then only forget it in the next few minutes."

**Why:** The user has explicitly forbidden the "spawn build subagent with my own brief" shortcut. The skill loop catches design / architecture / edge-case issues BEFORE code lands. The fund-manager-critic agent applies the audience lens (Bhavin + fund managers, sophisticated not retail) at every step.

## The MANDATORY skill loop for any frontend/UX work

```
[1] /plan-design-review     ← rate each design dimension 0-10
      ↳ apply 7 passes (info arch, interaction states, user journey,
        AI slop, design system alignment, responsive+a11y, decisions)
      ↳ produce mockups via gstack designer if OpenAI org verified,
        else use /design-html OR detailed ASCII wireframes
      ↳ output: validated design plan
[2] /plan-eng-review        ← architecture + data flow + tests
      ↳ dispatched as subagent OR run interactively
      ↳ output: locked implementation plan
[3] /superpowers:writing-plans   ← convert reviews into discrete-task plan
      ↳ output: docs/superpowers/plans/<date>-<feature>.md
[4] Adversarial review cascade — at least 2 sources, prefer 3:
      a. /codex review (consult mode) — try first
      b. Gemini API (Google generative AI) — if codex usage-blocked
      c. Opus 4.7 fresh-context subagent — ALWAYS runs (no prior context,
         gets only the plan + design app + CONTEXT.md as input)
      ↳ outputs reconciled into a single fixes list
      ↳ NEVER ship without at least 2 adversarial passes —
        single-source review is the failure mode this loop prevents
[5] /superpowers:subagent-driven-development  ← execute the plan
      ↳ implementer subagent per task
      ↳ spec-compliance review per task
      ↳ code-quality review per task
      ↳ + fund-manager-critic subagent (see below)
      ↳ loop until all reviews approve
[6] /design-review          ← screen-level visual QA on running app
      ↳ takes screenshots, finds issues, fixes iteratively
      ↳ commits each fix atomically with before/after evidence
[7] /qa                     ← functional walkthrough + auto-fix
[8] /review + /codex review ← pre-landing diff check
[9] /ship → /land-and-deploy ← merge + production deploy
```

**Anti-shortcut clause**: Never skip steps 1-4 to "save time". They prevent the failure mode of shipping pages that work technically but feel generic, miss states, or fail under fund-manager scrutiny.

## The Fund-Manager-Critic subagent

Spec for dispatching alongside any build subagent in step [5]:

```
You are a fund manager critic — channelling Bhavin's lens. You are
sophisticated, time-poor, decision-driven. You read this dashboard
at 9 AM IST before market open. You're looking for actionable
conviction, not retail-y prettiness.

For each page the build subagent ships, evaluate:

1. Decision speed: in 5 seconds, do I know what to BUY/HOLD/AVOID?
2. Numbers visible: am I seeing the IC, fric-adj, conviction score
   alongside the shape — or hidden behind clicks?
3. Plain-English: can I read the thesis without a single technical
   term I don't already know? Are jargon tooltips present?
4. Action verbs: are CAPS+bold BUY/HOLD/TRIM/AVOID surfaced explicitly?
5. Multi-benchmark: vs Nifty 50, vs Nifty 500, vs Gold — all available?
6. Temporal toggle: can I flip 1m/3m/6m/12m on every chart?
7. Column chooser: can I add/remove the columns I actually want?
8. 1d + 1w returns: visible without me having to flip tenure?
9. Sector context: does this stock's thesis name the actual sector
   and its rank, not just 'sector strength rising'?
10. Audit trail: when I click 'How was this decision made?', do I
    see the full provenance chain — every number traceable?
11. Bloomberg-density vs Morningstar-dry: is it dense but breathable,
    sophisticated but not complex?
12. Concentration: does the sector page tell me if the rotation is
    narrow (top-3 driving) or broad?
13. Holdings transparency: on a fund/ETF page, can I drill into the
    top-20 holdings and see each holding's Atlas verdict?
14. Closed loop: does the methodology page show the live cadence
    (daily/weekly/monthly/quarterly) and the regime feedback loop?

For each issue: severity (critical / high / medium / cosmetic) +
specific fix. Report back as a structured list. Be opinionated,
no hedging. Channel Bhavin — would HE find this useful or just
'fine'?
```

The fund-manager-critic runs in PARALLEL with each implementer subagent.
Its critique loops back as additional fix requirements.

## Locked design principles for Atlas v6 (apply in every review)

1. **Three vertical layers** on every page:
   - Layer 1 — Verdict (1 sec): shape + headline number with InfoTooltip
   - Layer 2 — Thesis (5 sec): 3-5 bullet points, CAPS+bold action verb,
     bolded numbers, explicit sector/cohort/benchmark names, no paragraphs
   - Layer 3 — Substantiation (5 min): v2 viz reuse + deterministic
     translation sentences for every technical number

2. **Bubble chart standard** (Funds/ETFs/Sectors):
   - X = Risk, Y = Return, Size = log-AUM, Color = Atlas state
   - Reading: top-right + deep-green = sweet spot

3. **Sector page depth**: % above EMA20/50/200 + top-3 concentration
   indicator + sector dispersion σ

4. **Audit trail tab** (instrument/fund/ETF detail pages): 7-section
   provenance chain. Every number with deterministic translation.

5. **Methodology page interactive closed-loop**: animated SVG with
   clickable nodes + cadence badges + live "last run" timestamps.

6. **Four mandatory directives** on every relevant view:
   - Temporal toggle [1m 3m 6m 12m] — default 6m, persisted per page
   - Benchmark toggle [Nifty 50 / Nifty 500 / Gold] — default Nifty 500
   - Column chooser — extensive options, user picks, persists
   - 1d + 1w return columns always shown (stocks); 1w on ETFs/funds/sectors

7. **Voice rules** (from DESIGN.md):
   - Sentence case for UI; UPPERCASE only for eyebrows + grade chips
   - No emoji, anywhere
   - Short, declarative, factual. 6-14 word sentences. No FOMO.
   - Avoid: explore, discover, unleash, supercharge, elevate, journey

8. **Aesthetic**: paper/ink/teal, no dark mode, opposite of Bloomberg
   (too dense) and opposite of Morningstar (too dry). Sophisticated
   but not complex.

## Canonical references (read in this order, every session)

1. `/Users/nimishshah/Documents/GitHub/atlas-os/DESIGN.md` — tokens/voice
2. `/Users/nimishshah/.gstack/projects/atlas-os/design-plans/2026-05-24-atlas-v6-design-plan.html` — existing 642-line v6 plan
3. `/Users/nimishshah/Documents/GitHub/atlas-os/CONTEXT.md` — v6 glossary
4. The 19-archetype ELI5 thesis registry (when built at `frontend/src/lib/eli5/thesis.ts`)
5. v2 viz components inventory: `frontend/src/components/{sectors,stocks,etfs,funds}/*Chart.tsx`

## Acceptance criteria template for v6 page builds

Every page must hit:
- [ ] 3-layer pattern visible (verdict + thesis bullets + substantiation)
- [ ] InfoTooltip on every technical term (zero naked jargon)
- [ ] Numbers bolded inside thesis bullets
- [ ] Action verb (BUY/HOLD/TRIM/AVOID) in CAPS at top of thesis
- [ ] Temporal toggle on every chart (default 6m)
- [ ] Benchmark toggle on RS-flavored views (default Nifty 500)
- [ ] Column chooser on every table
- [ ] 1d + 1w columns visible by default (where applicable)
- [ ] v2 viz reused where applicable
- [ ] Audit trail tab on detail pages (instrument/fund/ETF)
- [ ] Plain-English deterministic translation alongside every technical number
- [ ] DESIGN.md tokens (paper/ink/teal); no new color tokens
- [ ] Indian ₹/lakh/crore formatting; +/- on percentages; green/red signed values
- [ ] Sentence case; UPPERCASE only eyebrows/grade chips; no emoji
- [ ] Fund-manager-critic subagent has signed off

## What this memory replaces / supersedes

This is the ONE LOAD-BEARING memory for v6 frontend work. Any future
session starting a new frontend feature MUST read this first and apply
the skill loop verbatim. If you find yourself dispatching a "build
subagent" without going through plan-design-review and plan-eng-review,
STOP — you're in the failure mode this memory exists to prevent.

Related: [[project-v6-build-runbook]], [[feedback-gstack-skills-first]],
[[project-v6-2026-05-25-morning-state]], [[feedback-internal-tool-priority]]
