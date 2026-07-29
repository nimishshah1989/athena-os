---
name: feedback-simplify-adopt-libraries
description: "For build work, adopt mature open-source libraries over bespoke code; no research-paper citations; drive to runnable outcomes fast"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 2ff217a8-ee34-4358-b1a3-6ac996e1cccf
---

When designing or building, adopt mature open-source libraries instead of
inventing bespoke multi-component engines. Do not cite research papers as part
of a design. Drive relentlessly toward a runnable outcome.

**Why:** After the v6 trading model (a bespoke 960-line simulator + custom
validation engine that proved no strategy) and 2-3 follow-on design iterations,
the user was frustrated: "hours and hours of coding," overcomplicated designs,
research-paper citations instead of outcomes. The user's words: "there are
hundreds of trading bots, thousands of GitHub repos with thousands of stars —
adopt the infrastructure." Atlas's unique asset is its data + backend, not
hand-written engine code.

**How to apply:** When the user asks to build something, first ask "what mature
library/framework already does 80% of this?" and propose integration over
invention. Keep custom code to thin glue (target: hundreds of lines, not
thousands). Skip academic justification — name tools, give line estimates,
get to "run this and see." Prefer a cheap spike that tests the premise in a day
over a multi-week full build. Watch for the over-scoping reflex: more
components, more agents, more layers is the smell to catch.

Related: [[project-v6-state]], [[project-sde-state]], [[feedback-focused-scope]]
