---
name: atlas-explainer-flywheel
description: "Atlas must never feel like a black box. Every auto-action surfaces its causal chain back to user-visible outcomes — the flywheel: auto-tune → better IC → better conviction → more trusted calls → more validated data → auto-tune"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: c880c6b8-5d45-4717-8ecc-d02304a45cd0
---

User direction 2026-05-28: Atlas should never feel like a black box. Every backend action — especially anything that runs automatically — must show its work and connect to user-visible outcomes.

**The flywheel framing user is asking for**:

```
   ┌─────────────────────────────────────────────────────┐
   │                                                     │
   ↓                                                     │
Auto-tune weights → better IC → better cell predictions  │
                                       ↓                 │
                            better conviction score      │
                                       ↓                 │
                        more trusted calls fire          │
                                       ↓                 │
                       more validated outcomes ──────────┘
```

**Why:** User insisted twice — once on the methodology page rebuild, once on
admin consolidation — that the engine should be **explanatory**, not opaque.
A fund manager (or anyone) using Atlas needs to understand *why* a number
moved, *what* the backend did, and *how* that improves future predictions.

**How to apply:**

- For **auto-approved actions** (weight proposals, threshold updates,
  cell deprecation), the UI must show:
  1. What changed (before → after numeric)
  2. What triggered it (the math, the threshold crossed)
  3. What it improves (which IC/conviction/cell metric)
  4. The log entry so a human can audit
- For **methodology pages**, walk every concept back to a concrete outcome.
  Don't just define "conviction score = 7.6"; explain that this means
  "the engine is 75% confident this stock will outperform the tier benchmark
  over the next 3 months, based on N similar historical setups."
- For **admin consolidation**, every tab must lead with an *explainer*
  paragraph BEFORE the controls/data. Setup tab: "These are the parameters
  Atlas is using right now. Changing them retunes the engine in this way..."
  Activity Log tab: "Here's what Atlas auto-changed this week and why..."
- For **per-page rendering**, prefer plain-English captions next to numbers.
  Instead of "+33.9pp", show "+33.9pp (Energy beat Nifty 500 over 3 months
  by this much)."

**Anti-patterns to reject:**
- "Conviction +7.6" with no hover or explainer next to it
- "Auto-approved" status without showing the math that triggered the approval
- Single-letter labels (H / M / L) without legend
- Numbers without units (% / pp / σ / bps)
- "Threshold updated" without before-after diff
- Methodology pages that only show formulas without "what this means for you"

Related: [[skill-loop-process]] (frontend builds always run through design-review)
