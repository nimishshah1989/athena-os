---
name: atlas-closing-plan
description: "The approved 6-phase sequence to finish Atlas v2 and retire the old system, before the v5 closed loop"
metadata: 
  node_type: memory
  type: project
  originSessionId: c75549d5-a3f8-464d-adcb-6dbdd875b5dc
---

Approved 2026-05-22. The closing program to conclude Atlas v2 and reach v5.

**Why this order:** data correct → frontend accurate → live → clean → loop.
Hard rule: never delete anything until we have proven what is used.

1. **Backend correctness** — fix the v2 state-engine classifier. Verified bug:
   single-date `classify` runs cold-start every stock (`classify_state_panel`
   carries continuity only within its input panel; a 1-row panel → prior_state
   defaults "stage_1", dwell 0, days_in_stage_2 0). Result: ~72% pile into
   stage_1, dwell 0, stage_2b/2c/3 unreachable. Fix continuity seeding from the
   prior persisted day (or classify over a lookback window). Re-run a continuous
   backfill. Also fix ETF `mean_within_state_rank` NULL + sector divergence.
   Gate: state distribution plausible (Stage-2 count tracks ~46% above-30W-MA).
2. **Table inventory** — classify every table INGESTED/COMPUTED/UNUSED/DUPLICATE/
   DEAD; attach refresh owner + cadence + freshness check to used ones; build
   recurring detectors (extend the Data Validator Agent). Classify now, delete later.
3. **Frontend correctness** — redo review bugs 4-8 + rest of findings; every page
   accurate vs the corrected backend. 80% → solid. Final 20% visual polish is
   deferred to post-v5 per the user.
4. **Go-live** — fix deploy-frontend.yml for the v2 EC2 layout, merge
   feat/atlas-v2-frontend → main, retire old frontend dir + old backend.
   Gate: atlas.jslwealth.in served by v2 only, push→deploy works.
5. **Cleanup** — delete unused/duplicate/dead tables (via migrations) + dead
   codebase; wire recurring checks nightly. Safe only after Phase 2 manifest +
   Phase 4 live.
6. **v5 closed loop** — final circular loop from the user's spec doc, on a clean base.

**Execution discipline:** run each phase as its own focused checkpoint, NOT one
mega-session. Use gstack + subagent-driven development per phase. The pre-commit/CI
foundation fix (scoped Python gates to .py files) is already done — see commits
06ba6e2 + 8e6b56b on feat/atlas-v2-frontend.

**Deferred infra (decided 2026-05-22, NOT done yet):**
- EC2 right-size: the Atlas box is `c6i.16xlarge` (64 vCPU/128 GB, ~$2,100/mo,
  99.8% idle), instance `i-0e3fdeca0fd082844` in AWS account `389517402998`
  (NOT the `765425735663` account my CLI keys reach). Target: resize to
  **`t3.2xlarge`** (8 vCPU/32 GB, ~$195/mo). Needs AWS console access to that
  account, or creds. Stop→change type→start; first verify 13.206.34.214 is an
  Elastic IP. Deferred — user will handle or revisit.
- osho project: retired (migrated to its own server). On the shared EC2 box:
  stop `osho-engine` PM2 + disable nginx sites `osho-api`/`oshoarchives`, but
  KEEP `/home/ubuntu/osho-speaks/data` (14 GB, not in git). Deferred — not now.
- Security: osho's git remote had a plaintext GitHub PAT — user to revoke.
