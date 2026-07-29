---
name: Deploy gate — merge to main and verify on production
description: CRITICAL — features are NOT done until merged to main, deployed to EC2, and verified with curl/Playwright on production URL
type: feedback
---

Features are NOT "done", "deployed", or "live" until ALL of these are proven:

1. Branch merged to `main`
2. `main` pushed to origin
3. `deploy.sh` run on EC2 (via SSH or CI)
4. `curl https://mfpulse.jslwealth.in/health` returns healthy
5. Production URL opened in Playwright — screenshot shown to user

**Why:** Multiple sessions built 89+ commits on a feature branch, told the user it was deployed, but never merged to main. EC2 was still running months-old code. User lost trust in "done" claims.

**How to apply:**
- At the END of every session that builds features, explicitly ask: "Should I merge to main and deploy?"
- Never say "deployed" without pasting proof (health check + screenshot)
- If you can't deploy (no SSH access, etc.), say so clearly: "This is committed and pushed to the branch but NOT live on EC2 yet"
- When user asks "what's live", always check EC2 directly — never assume branch work = deployed
