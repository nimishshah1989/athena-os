---
name: Dagster Orchestrator (cutover from cron)
description: Dagster owns all pipeline scheduling as of 2026-04-18 — replaces bash cron + jip_trigger.sh stack
type: project
originSessionId: 923ce9d0-2a05-40d7-b5e1-06e50b034731
---
Dagster 1.9.10 deployed to EC2 on 2026-04-18 as the watertight orchestration layer.

**Live at:** https://data.jslwealth.in/dagster/ (port 3030 internally, behind nginx)

**Architecture:**
- 38 assets (one per critical de_* table) defined in `dagster_app/registry.py`
- 12 ScheduleDefinitions auto-generated from cron_expr in registry (Asia/Kolkata TZ)
- Each asset materialization calls existing `POST /api/v1/pipeline/trigger/single/{name}`
- Two asset checks per table: `__freshness` (max date_col vs SLA) + `__rowcount_delta` (±5% prior period)
- Run/event/schedule storage in same RDS (separate tables, prefixed `runs_`, `event_logs_`, etc.)
- `dagster-webserver` + `dagster-daemon` services in docker-compose

**Single source of truth:** add a row to `TABLE_SPECS` in `dagster_app/registry.py` → asset, freshness policy, rowcount check, schedule all auto-generated.

**Why:** Old bash cron + jip_trigger.sh + Agent 3 was patch-on-patch and Agent 3 died from chmod bug 2026-04-14 (same fate as what it monitored). Dagster is asset-centric (table-centric) which matches the user's mental model and gives free UI for SLA + history.

**How to apply:**
- Pipeline scheduling questions → check `dagster_app/registry.py` first, then schedules.py
- "Why isn't table X updating?" → https://data.jslwealth.in/dagster/asset-groups → click table → see runs + check status
- Out-of-band watchdog: Claude scheduled-task `jip-dagster-watchdog` runs every 6h to alert if Dagster itself is down
- Old cron file `scripts/cron/jip_scheduler.cron` has all pipeline lines commented `# DAGSTER-OWNED 2026-04-18` — purge on 2026-04-25 if Dagster stable
- Agent 3 self-healer remains active in cron as defense-in-depth (1 week)

**Key env vars (all in EC2 .env):**
- `DAGSTER_PG_HOST/USER/PASSWORD/DB/PORT` — RDS for run storage
- `DATA_ENGINE_BASE_URL=http://data-engine:8010` — internal trigger API
- `PIPELINE_API_KEY` — required for trigger API

**Known gotchas:**
- Dagster 1.9.10 errors on `from __future__ import annotations` + `AssetExecutionContext` annotation. Drop the type hints.
- `storage:` block and split `run_storage`/`event_log_storage`/`schedule_storage` are mutually exclusive — use unified `storage:` only.
- Schedule names must be globally unique; if same `schedule_group` has multiple cron variants, schedules.py appends `_HHMM` slug.
- Port 3000 was taken on EC2 by next-server; Dagster on 3030.
