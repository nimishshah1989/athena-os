---
name: reference_frontend_deploy_path
description: "THE live Atlas frontend deploy path — as of 2026-05-30 it is GIT-BASED: atlas.jslwealth.in serves from /home/ubuntu/atlas-os/frontend (the repo), pm2 app 'atlas-frontend' on :3002. The old hand-maintained /home/ubuntu/atlas-frontend-v2 tree is RETIRED."
metadata:
  node_type: memory
  type: reference
  originSessionId: 7d778cf1-3638-4885-8c5a-a4ea0dd1cd15
---

**atlas.jslwealth.in now serves from the git repo `/home/ubuntu/atlas-os/frontend`** (consolidated 2026-05-30). The old `/home/ubuntu/atlas-frontend-v2` hand-maintained copy is RETIRED (no longer in the serving path; a backup tarball `atlas-frontend-v2-src-backup-*.tgz` exists in /home/ubuntu/).

**The chain (current):**
- nginx `/etc/nginx/sites-enabled/atlas.jslwealth.in` → `proxy_pass 127.0.0.1:3002` (frontend) and `:8002` (internal API).
- pm2 app **`atlas-frontend`** (NOT `atlas-frontend-v2` — that was deleted): cwd `/home/ubuntu/atlas-os/frontend`, `next start -p 3002`, NODE_ENV=production. Config: `/home/ubuntu/atlas-os/frontend/ecosystem.config.js`. `pm2 save` done.
- Env: `/home/ubuntu/atlas-os/frontend/.env.local` (5 keys: ATLAS_DB_URL, ATLAS_INTERNAL_API_BASE_URL=:8002, ATLAS_INTERNAL_SECRET, ATLAS_TV_API_BASE_URL=:8020, **ATLAS_PASSWORD**). Next loads .env.local automatically.

**To deploy a frontend change now (ONE git-based path — the drift problem is gone):**
```bash
ssh atlas
cd /home/ubuntu/atlas-os && git pull --ff-only origin main
cd frontend && npm ci && npm run build   # ~3-5 min on t3.large
pm2 restart atlas-frontend
# verify on the live page (browse), not the DB.
```
No more scp-into-a-separate-tree. Commit to main → pull → build → restart.

**AUTH is now ON (2026-05-30).** It was silently OFF for weeks because `middleware.ts` lived at the project root while the app uses a `src/` dir (Next only compiles `src/middleware.ts` when a src dir exists). Fixed by moving it to `frontend/src/middleware.ts` (build now emits a Middleware chunk) + setting ATLAS_PASSWORD in .env.local. Flow: `/login` server action checks password == process.env.ATLAS_PASSWORD, sets httpOnly cookie `atlas_auth`; middleware gates all routes except /login. Password lives in `/home/ubuntu/atlas-os/.env` (ATLAS_PASSWORD).

**Other ports on this box (for context):** `:3002` = atlas frontend (one port, this is THE frontend). `:8002` = atlas internal API (FastAPI internal_recompute — the one the frontend calls; tv routes mounted here 2026-05-30). `:8020` = atlas-api.service (2nd FastAPI app; the frontend's *signals* pages call it via ATLAS_TV_API_BASE_URL, so NOT vestigial — can't retire without migrating signals routes). `:3003` = the unrelated "champion" project. `:3099` etc = ephemeral test ports only.

**Build tolerates test-fixture tsc errors** (next build excludes __tests__). Links: [[reference_ec2_access]], [[reference_atlas_frontend_host]].
