---
name: canonical-deployment
description: "The ONE frontend, ONE backend, ONE set of paths. Read this before touching any deployment, PM2, rsync, or EC2 reference."
metadata: 
  node_type: memory
  type: reference
  originSessionId: e842ab4d-d491-41b3-a501-57e3b9a8c2ec
---

## Canonical deployment — never guess, use these facts

### EC2
- **Host**: `ubuntu@13.206.34.214`
- **SSH key**: `~/.ssh/jsl-wealth-key.pem`
- **Production URL**: `https://atlas.jslwealth.in`

### Frontend
- **Local repo path**: `/Users/nimishshah/dev/atlas-os/frontend/`
- **EC2 path**: `/home/ubuntu/atlas-os/frontend/`
- **PM2 process name**: `atlas-frontend` (id 3, cluster mode)
- **Port**: 3002

**Why:** There is only ONE frontend. Ignore any other directories on EC2 (`atlas-frontend`, `atlas-frontend-v2`, `atlas-os-sl`, `atlas-os-consolidation`) — these are dead stale copies.

### Backend (Python/FastAPI)
- **EC2 path**: `/home/ubuntu/atlas-compute/`
- **PM2 process**: `app` (id 0)
- **Port**: 8002

### GitHub Actions auto-deploy
- **Workflow**: `.github/workflows/deploy-frontend.yml`
- **Trigger**: push to `main` touching `frontend/**`
- **What it does**: rsync → `npm ci` → `npm run build` → `pm2 reload atlas-frontend` → health-check

### Deploy command (manual fallback)
```bash
bash /Users/nimishshah/dev/atlas-os/scripts/deploy_frontend_v6.sh
```
This rsyncs to `/home/ubuntu/atlas-os/frontend/` and reloads `atlas-frontend`.

### Stale EC2 directories (do not touch, do not deploy to)
- `/home/ubuntu/atlas-frontend` — old, unused
- `/home/ubuntu/atlas-frontend-v2` — old, unused
- `/home/ubuntu/atlas-os-sl` — old, unused
- `/home/ubuntu/atlas-os-consolidation` — old, unused

**Why this memory exists:** In 2026-06 we wasted hours because the deploy script and GitHub Actions workflow were both targeting `atlas-frontend-v2` instead of `atlas-os`. Every session that touches deployment MUST read this file first.
