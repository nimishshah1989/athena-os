---
name: Forge Autonomous Build System
description: Ralph CTO orchestrator for overnight builds — dashboard, deploy, formulas all set up. User wants zero-stop autonomous operation.
type: project
---

Autonomous overnight build system set up on 2026-04-05.

**Why:** User wants to sleep while Ralph builds C7-C16, runs QA, deploys to EC2, migrates data, and starts ingestion. No human intervention.

**How to apply:**
- Ralph prompt at `.ralph/prompt.md` is CTO persona — no stops between chunks
- Dashboard at `docs/forge-dashboard.html` auto-refreshes every 15s
- `scripts/update_dashboard.py` called after each chunk step
- `scripts/post_build_qa.py` runs 10 automated checks after all chunks
- `scripts/deploy.sh` handles EC2 deploy via SSH (`~/.ssh/jsl-wealth-key.pem`, `ubuntu@13.206.34.214`)
- Formula docs at `docs/formulas/` — 5 files sourced from fie2 MarketPulse
- Permissions: `bypassPermissions` mode in `.claude/settings.local.json`
- Ralph launch: `ralph --monitor --verbose --timeout 15 --allowed-tools "Read,Write,Edit,Bash,Grep,Glob,Agent,Skill"`
