---
name: phase2-completed
description: Phase 2 changes completed 2026-03-24 — scoring, issues, fix plan, platform cleanup
type: project
---

## Phase 2 Completed (2026-03-24)

### What Was Done
- **YTIP removed** from platform config, health paths, all frontend references
- **FIE2 added** to action center filters and settings page
- **Security scoring: 9 → 15 checks** — added: financial_decimal, sql_injection, xss_protection, session_security, error_leakage, pii_protection
- **Quality analyzer: graceful fallbacks** when CLI tools missing (ruff/mypy/black) — uses AST-based analysis instead of scoring 0
- **Dockerfile** now installs ruff, black, mypy, pip-audit, detect-secrets
- **Issue generation for ALL failing checks** — both security and quality scanners now create Issue records for every check scoring below max
- **Fix Plan UI** — "Fix Issues" button on platform detail page → modal showing issues grouped by category → "Approve & Fix" triggers Claude fixes → PR creation
- **New endpoints**: POST /api/actions/fix/plan, POST /api/actions/fix/execute-plan, DELETE /api/health/purge, GET /api/metrics/explanations
- **Metrics page** at /metrics — plain-English explanations for all 15 security, 11 quality, 9 architecture checks
- **Platform detail page redesigned** — visual score bars, expandable explanations per check, severity-grouped issues
- **Removed** Activity Feed from home page, removed 4 empty "Phase X" score gauges
- **Data purge** UI in Settings page for cleaning bad historical health data
- **.env on EC2** updated with new Anthropic API key

### API Keys (on EC2 .env)
- ANTHROPIC_API_KEY: set (sk-ant-api03-Njz6k...)
- GITHUB_TOKEN: set (ghp_gBF7at...)
- DATABASE_URL: fie-db RDS, fie_v3 database, jip_ops schema

### Commits
- 451a829 feat(phase-2): enhanced scoring, metrics page, platform cleanup, UX improvements
- ad78ab9 feat(phase-2): issue generation for all failing checks, fix plan UI, remove empty gauges

### Deployment Status (2026-03-24)
- 502 was caused by build still running — resolved, container is UP and healthy
- Scan triggered and completed — all 5 platforms scored:
  - horizon: security=69.16, quality=48.0
  - champion: security=45.79, quality=43.0
  - mfpulse: security=76.64, quality=51.0
  - marketpulse: security=78.50, quality=48.0
  - fie2: security=65.42, quality=48.0
- Architecture scores pending (needs weekly scheduler or manual trigger)
- Daily scans run automatically at 2AM IST via APScheduler
