---
name: backend-100-before-frontend-mockups-strict
description: "Two non-negotiable rules the user has restated multiple times. Violating either is the canonical session failure mode. Read this BEFORE making any \"but partial is acceptable\" or \"I'll stub it\" judgment."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: c880c6b8-5d45-4717-8ecc-d02304a45cd0
---

Two rules. Both hard. Both restated multiple times this session.

## Rule A — Backend 100% before any frontend work

"100%" means: every column, every row, every materialized view that ANY mockup page reads from must be populated and live BEFORE a single frontend file is touched. Not "6 of 8." Not "the important cols are there." 100%.

**Why:** the user has stated this verbatim multiple sessions. They've watched me ship pages with placeholder data and then later realize the backend gap and have to rebuild. The rule exists because partial backend creates compounding frontend rework.

**How to apply:**

1. When the user says "backend first," interpret it as the full canonical-backend.md inventory + all MVs + all column coverage. Not "the columns we have."
2. Before dispatching ANY frontend implementer (F.* tasks), enumerate every backend gap (NULL cols, missing MVs, missing tables, missing data sources) and resolve each — or get explicit user sign-off to defer specific items in writing.
3. If a column requires a paid data vendor and the user hasn't approved buying it, the page that uses that column is BLOCKED. Don't ship the page with the column NULL. Don't ship the page with a stub. The page waits.
4. "Backend partial-done" is not a thing in the user's vocabulary. There is "backend done" (all required data populated) or "backend in progress."

## Rule B — Mockups are the spec; every section must be real on the live page

The 12 mockups at `~/.gstack/projects/atlas-os/designs/v6-redesign-20260526-mockups/` are the design contract. Every section in each mockup HTML must be present on the corresponding live page with the real component, real data, locked design tokens. No stubs. No TODO comments shipped to production. No "I'll build the placeholder version first and iterate."

**Why:** the user invested in creating these mockups specifically so I don't get to make fidelity tradeoffs. "Use the existing approximation" or "ship a stub" is an admission that I'm deciding fidelity is optional. The mockups exist to remove that decision from me.

**How to apply:**

1. If a mockup section references a component that doesn't exist (e.g. MultidimChart with price+RS+volume lanes), I BUILD the component first. I don't ship an SVG approximation.
2. If a mockup section requires data the backend doesn't provide, Rule A applies — the page waits for backend.
3. "Existing component X is close enough" is wrong if it isn't pixel-faithful per the locked fidelity bar ("spirit + every section + locked tokens + existing 114 components"). The bar is "the section looks and behaves like the mockup," not "a similar section exists somewhere."
4. /design-review against the mockup HTML is the gate. If I'm about to commit without running /design-review against the mockup, I'm violating Rule B.

## The pattern to avoid

In this session I violated both rules by:
- Declaring B.1 / B.2 / B.3 "partial-complete" and moving to frontend dispatch (Rule A violation)
- Building /markets-rs with stubbed detail charts because "the full multidim doesn't exist yet" (Rule B violation)

The user's reaction: "Why do you insist on building things up optimally, despite having such clear instructions?"

The corrective: **stop optimizing.** When the user says backend-first or use-the-mockup, those aren't suggestions to navigate. They're constraints.

Related memories:
- `[[backend-first-live-db-truth]]` — verify against live DB, not migration files
- `[[skill-loop-process]]` — design-review is part of the cadence, not optional
- `[[check-v6-components-first]]` — 114 components live; use them; don't duplicate
- `[[backend-first]]` — original backend-first cadence memory
