---
name: feedback_deploy_push_first
description: CRITICAL — must git push before running deploy.sh, which does git pull on EC2
type: feedback
---

The deploy script (`scripts/deploy.sh`) runs `git pull` on EC2. If the local commit hasn't been pushed to the remote first, the pull returns "Already up to date" and the old code gets rebuilt. This caused multiple sessions of zero changes landing on production despite appearing to deploy successfully.

**Mandatory deploy sequence:**
1. `git push origin <branch>` — FIRST
2. Verify with `git log` on EC2 that the commit landed
3. THEN run `./scripts/deploy.sh`

This was a multi-session failure that caused repeated user frustration. Never skip step 1.
