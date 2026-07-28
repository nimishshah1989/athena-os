---
name: Per-milestone gstack skill cadence
description: Plan → Implement → Review → Ship loop with named gstack skills per milestone
type: project
originSessionId: 85e68f27-9b9a-4a5b-ac58-6da306889a19
---
**The loop, applied per milestone (M1 → M5):**

```
Plan         →  Implement      →  Review                      →  Ship
────────────    ─────────────    ─────────────────────────    ──────────────
/plan-eng-    /superpowers:    /review                       /ship
  review        test-driven-   /security-review              /land-and-deploy
                development    /sebi (auto-fires fintech)    /canary (M5 only)
              /superpowers:    /codex (independent 2nd op)
                subagent-
                driven-dev
```

**Per-milestone notes:**
- **M1**: `/plan-eng-review docs/milestones/ATLAS_M1_SCHEMA_AND_REFERENCE.md` before starting; eng-review will catch tier rules / threshold seed drift in the universe builders.
- **M2**: highest library-discipline risk (pandas-ta vs hand-rolled formulas). Eng-review forces explicit library choices.
- **M3**: numerical-drift risk in sector aggregation (market-cap weighting). Eng-review focuses on weighting math + cross-table consistency.
- **M4**: holdings handling = data sensitivity boundary. `/sebi` matters here.
- **M5**: re-run `/plan-ceo-review` (decisions are the business product) → `/plan-eng-review` → `/sebi`.

**Per-PR (every diff before merge):**
- `/review` — diff-scoped review
- `/security-review` — built-in OWASP-style check
- `/sebi` — auto-fires for fintech projects per CLAUDE.md regime tag
- `/codex` — independent second opinion (different model)

Or `/autoplan` to run the whole sequence with one command.

`/ship` is the final merge gate — bundles `/review` + adversarial review + commit + PR creation.

**What I do NOT use:**
- `/superpowers:write-plan` — we already have 6 locked milestone docs. Running `/plan-eng-review` on each milestone *as we approach it* gets us fresher reviews than re-writing plans.
- `/office-hours` — methodology is locked. The "fuzzy idea → spec" stage is past.

**Frontend pipeline (post-M5):**
1. `/design-consultation` — explore design language with the gstack designer
2. `/design-shotgun` — burst-generate 5-10 mockup directions for key screens
3. `/design-html` — concrete HTML mockups bound to actual atlas decision-table column names (mockups link directly to backend by referring to real types)
4. `/plan-design-review` — review the chosen design against foundation docs before implementation
5. (build with the chosen design — Next.js + Supabase JS)
6. `/design-review` — run on the live UI to catch what only renders show

**How to apply:** When the user says "let's start M2", I should default to running `/plan-eng-review docs/milestones/ATLAS_M2_STOCK_ETF_METRICS.md` first, then write code with TDD, then `/review` + `/security-review` + `/sebi` + optionally `/codex` per PR, finally `/ship`. Don't skip the eng-review even if the milestone doc looks complete — fresh eyes catch drift between methodology and current state.
