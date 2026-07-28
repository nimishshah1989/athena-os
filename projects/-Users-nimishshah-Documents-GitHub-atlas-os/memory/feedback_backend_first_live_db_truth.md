---
name: feedback-backend-first-live-db-truth
description: "For Atlas (backend-first project), the LIVE DB is the source of truth — never migration files on disk. Verify table existence via Supabase MCP / psql BEFORE planning anything that depends on it. User explicit correction 2026-05-26 after I built a 60-task frontend plan on top of tables that didn't exist in Supabase."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: b59586b9-3103-4e5d-91ea-24bffe155f3d
---

User's explicit correction (2026-05-26 ~01:30 IST), after I'd run the full plan-design-review → plan-eng-review → FM-critic → writing-plans → adversarial cascade → plan patch → Phase A dispatch loop:

> "i told you to ensure backend is fixed - why do you do this ?"

## What went wrong

I built a 60-task v6 frontend plan that referenced tables (`atlas_paper_portfolio`, `atlas_mf_switch_rules`, `atlas_ledger`, `atlas_drift_event_log`, `atlas_provenance_log`, `atlas_user_lots`, `atlas_brief_cache`) which DID NOT exist in the live Supabase atlas-os database. The migration FILES existed on disk; the migrations had never been applied to atlas-os. Alembic version table read `093` but migrations 082-088 had never landed there.

Both adversarial reviewers (Opus 4.7 + superpowers:code-reviewer) flagged ~5 of these tables as missing. I dismissed half their flags by running `grep "create_table.*<name>" migrations/versions/` — which proved the migration file existed, not that the table existed in Supabase. That was the bug. **A migration file existing is not the same as the migration being applied.**

I only caught this when the user asked "what do you want me to do?" and I ran the verification SQL via Supabase MCP. By that point I'd already burned ~3 hours of skill-loop work, committed a 60-task plan (49a1306), and dispatched 10 implementer subagents that landed real code on top of false backend assumptions.

**Why:** Atlas is a backend-first project per `~/.claude/CLAUDE.md` Four Laws #3. The live DB is what production code reads. Migration files on disk merely *intend* state changes — they haven't happened until alembic upgrades the live target. For a project where the backend is the contract, I must verify the contract against the live target before designing anything on top of it.

**How to apply:**
1. **For any Atlas plan that references a database table**: BEFORE committing to the plan, run `SELECT table_name FROM information_schema.tables WHERE table_schema = 'atlas' ORDER BY table_name` via the Supabase MCP (`mcp__plugin_supabase_supabase__execute_sql` with project_id `nanvgbhootvvthjujkvs`) and confirm each referenced table exists in the result.
2. **For any adversarial review that flags "table X doesn't exist"**: do NOT rebut by checking migration files. Rebut (or confirm) by checking the LIVE DB.
3. **When the alembic_version table value doesn't match the table inventory**: the version table was manually stamped or someone applied migrations to a different env. Both reviewers correct; treat the discrepancy as the source of truth, not the version number.
4. **Backend-first cadence for new Atlas work**: live-DB audit → schema drift fix → working backend → THEN design + plan + frontend skill loop. The full skill loop on a broken backend produces a plan that ships on top of vapor.

Related: [[feedback-skill-loop-process]] (the loop is correct — it must just run AFTER backend is verified), [[reference-supabase-mcp-gate]] (read-only SELECT queries via Supabase MCP are auto-allowed; use them aggressively for live-DB verification), [[project-atlas-decision-engine]], [[project-v6-build-runbook]].
