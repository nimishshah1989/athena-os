---
name: Backend-first build cadence; UI brief deferred
description: Frontend planning is deferred until M5 ships; current focus is bulletproof backend
type: feedback
originSessionId: 85e68f27-9b9a-4a5b-ac58-6da306889a19
---
**Rule:** Build the entire backend (M1 → M5) before designing the frontend. UI brief is a v0+ task, not a v0 task.

**Why:** User explicitly said: "Let's just focus on creating the whole backend in the most amazing way, absolutely accurate, with all the quality checks, etc." When asked about frontend at the start, response was "We'll need to figure out the entire front end brief" — i.e. it's a separate planning pass, not part of the current build sequence.

**How to apply:**
- Don't speculate about UI screens or invent UX flows during backend work.
- If a backend decision is genuinely UI-driven (e.g. M5 fund decision schema additions like `weeks_in_current_state`, `entry_trigger`, etc.), bake the column in but document the UI rationale in `prds/00_INFRA_DECISIONS.md` Section 8 — don't build the UI itself.
- After M5 ships and validates, run the design pipeline: `/design-consultation` → `/design-shotgun` → `/design-html` → `/plan-design-review` → implement → `/design-review`.
- Streamlit was the architecture-doc-original choice for v0, but the user's "0 latency, scalable" frontend ask suggests Next.js + Supabase JS will be the actual stack. Surface this when frontend planning starts.

**v0 backend scope (locked):** all four primitives at stock + ETF level, sector aggregation, market regime, three-lens MF framework, decision engine for stocks/ETFs/funds, validation framework. v0 does NOT ship a frontend. v0 does NOT ship a UI brief.
