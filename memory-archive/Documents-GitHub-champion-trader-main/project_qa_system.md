---
name: QA Auto-Loop System
description: QA system is hooked in via Stop hook — runs Playwright + Claude Vision testing after every task
type: project
---

- QA agent lives at: `~/.claude/qa_agent/run.py`
- Stop hook in `.claude/settings.json` fires QA after every Claude Code task
- Config at `./qa_config.yaml` (copied from champion.yaml template)
- Pass conditions: max_critical=0, max_major=0, max_minor=5, max_iterations=8
- QA false positive fix: navigation-related Playwright errors (context destroyed, timeout) are filtered in `~/.claude/qa_agent/agents/interaction.py`
- Backend must be running on port 8000 and frontend on port 3000 for QA to work
- Port 8000 conflict: BRE (Beyond Risk Engine) also uses 8000 — kill it before starting CTS backend

## QA Gaps Identified (2026-03-17)
- QA auto-loop only tests locally (lint, types, unit tests)
- **No production health check** — doesn't SSH into server to verify containers running or responses valid
- Need: post-deploy smoke test that hits all 15 endpoints on production and validates response schemas
- `trade-row.tsx` has non-nullable `number` props but API returns `number | null` — potential null crash not caught by QA
