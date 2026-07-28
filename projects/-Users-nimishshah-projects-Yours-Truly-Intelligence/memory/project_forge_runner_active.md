---
name: Forge runner is live for YTIP
description: Forge-runner (autonomous chunk loop) is installed and smoke-tested. All new development on YTIP should go through it rather than ad-hoc Claude sessions.
type: project
originSessionId: 5204cbb2-a88b-4afd-bec5-61248ad9f1b2
---
forge-runner is the sanctioned development pipeline for YTIP as of 2026-04-14. A smoke test (chunk `SMOKE-1`, commit `25f3828`) ran end-to-end cleanly — pick → implement → forge-ship → mark-done → verify, all four checks green.

**Why:** The user wants autonomous, repeatable, verifiable chunk execution driven by specs rather than conversations. forge-runner spawns inner Claude Code sessions against `.forge/CONDUCTOR.md` + a per-chunk spec, runs tests via `forge-ship.sh`, and gates commits through a verifier that checks state.db status, commit subject prefix, stamp freshness, and clean tree.

**How to apply:**
- When the user asks to "build feature X", "add a chunk for Y", or "work on phase Z" — default to writing a spec at `docs/specs/chunks/<ID>.md`, seeding it into `orchestrator/state.db`, and letting the runner execute it. Do NOT implement directly in the main Claude session unless the user explicitly says to skip forge-runner.
- The operational guide lives at `docs/FORGE_RUNNER.md` — read it before modifying anything under `.forge/`, `orchestrator/`, or the chunk-seeding flow.
- Use the `chunkmaster` skill (`/chunkmaster <SLICE>`) to auto-generate chunks from a phase spec like `docs/specs/chunk-plan-phase-j.md`.
- Auth: the user's Max plan is the paying account via `CLAUDE_CODE_OAUTH_TOKEN` in `~/.zshrc`. Inner sessions route through this, not pay-per-token API.
- If a chunk fails, inspect `.forge/logs/<chunk-id>.log` and `.forge/logs/<chunk-id>.failure.json`. Reset with `forge run --retry <ID>`.

**Outstanding work:**
- All four forge-os latent bugs (YAML parser, schema drift, missing DONE marker, ignored runner knobs in project.yaml) were fixed upstream in forge-os `5aa57fc` on 2026-04-14. No local workarounds needed for new projects.
- Two YTIP pytest failures remain deselected in `.forge/run-tests.sh`: (a) `test_excluded_customers::test_excluded_phone_not_in_customer_data` uses Postgres-only `gen_random_uuid()` and breaks under sqlite fixtures, (b) `test_pipeline::test_all_intelligence_jobs_and_cron_schedules` imports `apscheduler` which isn't in `backend/requirements.txt`. Both are real bugs from the Phase-J WIP commit `4234be9` — worth writing chunks to fix.
