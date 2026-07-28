---
name: architecture-overview
description: JIP Command Center tech stack, file structure, and key services
type: project
---

## Stack
- **Backend:** FastAPI (Python 3.12) — 6 routers, 7 services
- **Frontend:** Next.js 15 + React 19 + TypeScript + Tailwind CSS + Recharts + TanStack Query
- **Database:** PostgreSQL (RDS) with `jip_ops` schema via SQLAlchemy async + asyncpg
- **Scheduler:** APScheduler AsyncIOScheduler (health 5m, git 15m, security daily 2AM, quality daily 2:05AM, architecture weekly Sun 2:10AM)
- **Deployment:** Single Dockerfile bundling Next.js + FastAPI (MF Pulse pattern)

## Routers
- `/api/health` — platform health status, refresh, history, purge
- `/api/scores` — security/quality/architecture scores per platform
- `/api/git` — git snapshots, commit history
- `/api/claude` — sessions, analytics, bugs
- `/api/actions` — issues list, fix with Claude, fix plan, ignore/snooze, action log
- `/api/history` — score trends, activity feed
- `/api/metrics` — metric explanations (plain-English descriptions of all checks)

## Services
- `health_checker.py` — pings backend+frontend of 4 platforms
- `security_scanner.py` — 9 checks (secrets, env hygiene, deps, CORS, auth, supabase, HTTPS, rate limit, input validation)
- `quality_analyzer.py` — 11 checks (lint, types, coverage, modularity, complexity, naming, dead code, error handling, formatting, API consistency, TODO markers)
- `architecture_scorer.py` — Claude API with 9-dimension structured prompt
- `git_inspector.py` — git status via subprocess on EC2
- `claude_bridge.py` — Anthropic API fix generation + PyGithub PR creation
- `scheduler.py` — APScheduler cron job registration

## Frontend Pages
- `/` — Command Center (platform cards, score gauges, activity feed)
- `/platform/[id]` — Deep dive (health timeline, score breakdown, git, issues)
- `/actions` — Action center (issue list with Fix/Ignore/Snooze, action log)
- `/claude` — Claude intelligence (sessions, analytics, bug learning chart)
- `/settings` — Notification prefs, schedules, API key status

## Monitored Platforms
- horizon (India Horizon) — port 8002
- champion (Champion Trader) — port 8003
- mfpulse (MF Pulse) — port 8005
- marketpulse (Market Pulse) — port 8004
- fie2 (FIE2 Client Portal) — port 8000
- YTIP removed in Phase 2

## Frontend Pages
- `/` — Command Center (platform cards, 3 score gauges)
- `/platform/[id]` — Deep dive (score bars, fix plan modal, severity-grouped issues)
- `/actions` — Action center (issues with Fix/Ignore/Snooze, action log)
- `/claude` — Claude intelligence (sessions, analytics)
- `/metrics` — How Scoring Works (all checks explained)
- `/settings` — Notifications, schedules, data purge, API key status
