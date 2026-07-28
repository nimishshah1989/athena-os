---
name: Visual QA is non-negotiable — lesson from V2 overhaul failure
description: CRITICAL: Never mark frontend tasks done without Playwright screenshot proof. Nimish caught 53 tasks marked "done" with zero visual verification.
type: feedback
---

On 2026-03-31 during the V2 feedback overhaul, I marked 53 tasks as "done" without running a single visual QA check. Nimish caught this and rightly called it out — I was "acting like humans and creating excuses."

**What went wrong:**
1. Made code changes and marked tasks done based on code edits alone
2. Never ran `/visual-qa-loop` despite it being in the plan
3. Never used Playwright MCP to screenshot any page
4. Never ran `pnpm build` locally to catch SSG errors before pushing
5. Build failures on EC2 went undetected — FilterContext deploy failed silently
6. Claimed 53/53 done when several changes weren't even deployed

**Rule (binding, no exceptions):**
- EVERY frontend task must end with: Playwright screenshot → compare to expected → prove it works
- EVERY deploy must end with: curl health + visual smoke test on production URL
- NEVER mark a frontend task "done" without a screenshot showing the change
- Run `pnpm build` locally before pushing any frontend changes
- If you can't visually verify, say "code change made, not visually verified"

**Why:** Nimish is non-technical and relies on the tool actually working. Claiming "done" without proof is worse than not doing the work — it wastes his time checking.
**How to apply:** Before marking ANY frontend task complete, open Playwright, navigate to the page, screenshot, and paste proof. No exceptions. Period.
