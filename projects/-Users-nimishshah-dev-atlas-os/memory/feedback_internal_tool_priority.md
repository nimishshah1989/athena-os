---
name: feedback-internal-tool-priority
description: Atlas v6 is being built as an INTERNAL intelligence engine first. Skip SEBI/compliance/named-secondary/user-research/WTP/etc. The single priority is the matrix generator — finding the right feature combinations for every (cap_tier × tenure × actionable_state) cell.
metadata: 
  node_type: memory
  type: feedback
  originSessionId: b59586b9-3103-4e5d-91ea-24bffe155f3d
---

User's explicit instruction (2026-05-24, mid-Phase-4 milestone):

> "Let's not worry about issues 2, 3, and 4 [WTP, SEBI, named secondary]. We are building this platform for our internal consumption right now. As long as the platform is able to do that job, worrying about CB moving it to different people, all these WPT, this is not important right now. Let's purely focus on building Atlas as a platform for our internal consumption or tool and an intelligence engine that gives us, based on price and volume, the absolute right strategy to generate Alphas at a risk-managed level for small, mid, and large across stock CTA funds. This is our end goal. Ideally, what I would love to see for us is to see the entire formula or the matrix generator in play, because getting this combination, the right matrix and the right combinations for the places we are missing, I don't want to come to a place where we are not able to find the right matrix or the right set of combinations. I'm reasonably confident we can. I think that's our core focus. All the other stuff with regards to regulatory, compliance, blah blah, that's not the priority."

**Why:** Atlas v6 mission is now scoped to **internal intelligence engine for the user's own consumption**, not a SEBI-registered public retail product. Compliance/regulatory/UX-for-third-party concerns are noise; the methodology + matrix are the substance.

**The single priority:** the 24-framework discovery (Phase 0.5g — issue #25). 18 of 24 (cap_tier × tenure × actionable_state) cells need the same feature-discovery rigor that produced the existing ~7-8 validated cells. The user wants to SEE the matrix populated end-to-end with real validated rules, not placeholders.

**How to apply:**

1. **Close as deferred (NOT delete) — these are not on the critical path:**
   - #10 SEBI RA registration + legal opinion
   - #11 user-facing wireframes (still useful for internal UI but not priority)
   - #31 Named secondary maintainer + compliance binder
   - #34 CSO security review
   - #35 User research / WTP gate
   - Disclosure copy, SEBI-guard hardening (only the lift; not enhancement)

2. **Critical path is now (in order):**
   - Migration 081 ship (atlas_cell_walkforward_runs + atlas_friction_params) — was reserved; unblock now
   - atlas/discovery/ module — promote scripts/rs_phase3*.py per eng review §1.1 inventory
   - Phase 0.5a large-cap fix (#7) — recovers 10-12 large-cap names; lets Large-tier cells discover signal
   - Phase 0.5b survivorship rebuild (#8) — cleans the historical universe
   - Phase 0.5d friction model (#15) — per-tier friction coefficients
   - Phase 0.5g 24-framework discovery (#25) — THE MATRIX GENERATOR
   - Surface the populated matrix in a visible artifact (HTML + per-cell drill-downs)

3. **Skip / deferred** until matrix is in play:
   - All compliance/regulatory checkpoints
   - User research, demand validation, WTP
   - Public-launch readiness (alpha-0 / alpha-1 are sequencing markers; for internal use, the build is "ready" when matrix populates with real validated cells)
   - SEBI-aware brief language (the SP07 SEBI guard stays; the additional legal opinion + disclosure copy doesn't)

4. **Acceptable trade-offs:**
   - Brief language can be casual/internal — not SEBI-RA-compliant tone
   - No need for written legal opinion or named secondary
   - No need to gate on user interviews
   - Frontend can be minimal/admin-style (internal users; no production UX polish needed for v6 first cut)

Related: [[project-v6-build-runbook]], [[feedback-autonomous-execution]], [[project-signal-discovery-2026-05]] — the methodology-lock + signal-discovery thread that originated the 24-framework concept.
