# Memory Index — MF Pulse Reimagined

## User
- [user_nimish_preferences.md](user_nimish_preferences.md) — Principal Engineer at JSL, high UI/UX bar, wants globally competitive design

## Feedback
- [feedback_frontend_quality.md](feedback_frontend_quality.md) — V1 frontend rejected as bland, detailed per-page critique
- [feedback_mfpulse_v1_review.md](feedback_mfpulse_v1_review.md) — 45+ item PDF review (2026-03-31): density, context, universal filters, perf, design consistency
- [feedback_deploy_push_first.md](feedback_deploy_push_first.md) — CRITICAL: must git push before deploy.sh, which only does git pull on EC2
- [feedback_universe_design.md](feedback_universe_design.md) — Universe page: no icons, no gray, no purple/maroon, data spectrum colors, line charts in Compare
- [feedback_data_richness.md](feedback_data_richness.md) — User wants every page/visual to be extremely rich, use all 200+ data points per fund
- [feedback_deploy_gate.md](feedback_deploy_gate.md) — CRITICAL: features not done until merged to main + deployed to EC2 + verified on prod URL
- [feedback_production_readiness.md](feedback_production_readiness.md) — Task-by-task updates, clean everything, zero stale code, production-ready
- [feedback_visual_qa_mandatory.md](feedback_visual_qa_mandatory.md) — CRITICAL: never mark frontend done without Playwright screenshot proof
- [feedback_server_capacity.md](feedback_server_capacity.md) — EC2 t3.large: run Morningstar APIs one at a time, NAV backfill concurrency=2 max
- [feedback_regular_funds_only.md](feedback_regular_funds_only.md) — ONLY Regular funds (purchase_mode=1) shown, no Direct plans anywhere

## Reference
- [reference_data_catalog.md](reference_data_catalog.md) — COMPREHENSIVE: Every data point available — all DB tables, all API responses, all computed metrics, what's surfaced vs not yet surfaced

## Project
- [project_data_audit.md](project_data_audit.md) — Complete DB schema, column names, data coverage, API shapes, critical mismatches
- [project_frontend_design_v2.md](project_frontend_design_v2.md) — Approved V2 design for Universe, Fund 360, Dashboard with Claude API
- [project_feedback_decisions_20260331.md](project_feedback_decisions_20260331.md) — Analytics keep+enrich, $5/mo Claude API, fund360.html binding, ops scoring
- [project_v2_session_state.md](project_v2_session_state.md) — V2 session state: what's done, 15 remaining issues from live review
- [project_adversarial_review_20260402.md](project_adversarial_review_20260402.md) — Adversarial review: 35 blockers, 112 warnings. Security fixed. Financial/race/test pending.
