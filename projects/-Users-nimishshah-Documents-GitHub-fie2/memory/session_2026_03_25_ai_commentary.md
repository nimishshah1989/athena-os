---
name: session_2026_03_25_ai_commentary
description: Claude AI-powered breadth commentary + StaticFiles routing fix for Starlette 1.0.0
type: project
---

## 2026-03-25 Session: AI Commentary + Deploy Fix

### What was done
1. **Claude AI breadth commentary** — Added `generate_breadth_commentary()` to `services/claude_service.py` using Haiku model. Commentary endpoint (`/api/breadth/commentary`) now calls Claude to generate intelligent market analysis. Cached daily (one API call/day). Falls back to template commentary when API key missing or AI fails.

2. **Starlette 1.0.0 routing fix** — `StaticFiles(html=True)` mounted at "/" was intercepting ALL requests including `/api/*` and serving Next.js 404.html. Fixed by removing `html=True` and mounting static assets separately (`/_next` for chunks, explicit routes for pages, `/` without html=True for remaining assets).

### Key commits
- `7ca492b` feat(breadth): Claude AI-powered market commentary via Haiku
- `23aa07f` fix(deploy): prevent StaticFiles(html=True) from overriding API routes

### Deploy note
`ANTHROPIC_API_KEY` is NOT in the production `.env` file. AI commentary will use template fallback until the key is added to `/home/ubuntu/fie2/.env` on the server (13.206.34.214).

### Next steps
- Add `ANTHROPIC_API_KEY` to production .env for AI commentary to work
- Bhavcopy-based price backfill for full 500-stock coverage
- Sector breadth backfill completion
