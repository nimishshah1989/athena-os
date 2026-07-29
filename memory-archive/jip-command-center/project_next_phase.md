---
name: next-phase-requirements
description: Phase 2 requirements from user — scoring improvements, platform list, fix automation, UX explanations
type: project
---

## Command Center Phase 2 Requirements (2026-03-24)

### A. Code Quality Scores Are Low (~46-51% across all platforms)
- Investigate why quality scores are so low
- Many checks depend on CLI tools (ruff, mypy, black, eslint, tsc) that may not be installed in the Docker container
- Subprocess calls may silently fail → defaulting to low scores
- Need to install ruff, black, mypy in the container OR make checks gracefully handle missing tools

### B. Missing Scores
- Architecture scores require ANTHROPIC_API_KEY in .env (currently empty)
- User needs to provide the API key or we need to add it
- Some score subcategories may not be calculating properly

### C. Uptime Not at 100%
- Historical data is skewed because early checks had wrong URLs/ports → recorded as "down"
- MF Pulse backend was unreachable until binding fix
- Horizon + Champion were down until containers were created
- Uptime calculation uses 7-day window — will naturally improve as healthy checks accumulate
- Consider: should we purge old bad health check data? Or let it age out?

### D. Metrics Explanation Page
- User wants a dedicated page explaining every metric, every check, what it means
- Each score breakdown item should have a plain-English explanation
- Both on a dedicated "How Scoring Works" page AND inline on platform detail pages

### E. Security Scoring Enhancements
- Current security scanner has 9 checks (secrets, env hygiene, deps, CORS, auth, supabase key, HTTPS, rate limiting, input validation)
- User has financial services security skills/protocols — wants deeper security analysis
- Should integrate: OWASP checks, financial data handling (Decimal enforcement), PII protection, session management
- Scores should reflect financial-grade security requirements

### F. Platform List Update
- REMOVE: YoursTruly IP (ytip)
- KEEP: Market Pulse, MF Pulse, Champion Trader, India Horizon, FIE2 (Clients)
- ADD LATER: Beyond Risk Engine (BRE) — not yet deployed
- Need a way to easily add new platforms in the future

### G. Fix Automation (Claude Auto-Fix)
- When clicking a platform card → detail page must clearly show what needs fixing
- Each issue should have a "Fix" button
- Clicking "Fix" should trigger Claude to:
  1. Understand the issue
  2. Generate a fix
  3. Create a branch + PR (never push to main)
  4. NOT break the product
- Claude bridge service exists but needs ANTHROPIC_API_KEY + GITHUB_TOKEN
- Must be safe: PR-only, never direct main push

### H. UX Improvements
- Platform detail pages need more substance — breakdown explanations, issue lists, clear actions
- Dashboard should feel like "at a glance, I know if everything is OK"
- Issues should be categorized and prioritized (critical → high → medium → low)
