---
name: next-steps
description: Remaining work after Phase 2 — 502 fix, trigger scans, notifications
type: project
---

## Pending (as of 2026-03-24)

1. **RESOLVED: 502 + scans** — container is UP, initial scans completed, all 5 platforms scored

2. **Purge bad uptime data** — use Settings page data purge to clean pre-2026-03-24 health checks

3. **Trigger architecture scan** — needs Anthropic key (now set). Run manually or wait for weekly scheduler (Sun 2:10AM IST)

4. **SMTP and Slack not configured** — notification features won't work until SMTP_HOST/SLACK_WEBHOOK_URL are set

5. **GITHUB_ORG** — currently set to nimishshah1989 on EC2. Verify this matches the GitHub account owning the repos.

6. **SSH key on EC2** — still requires token-based git pull. EC2 remote URL set to token-authenticated URL.
