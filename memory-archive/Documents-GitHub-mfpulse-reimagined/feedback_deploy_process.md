---
name: Deploy Process — MFPulse
description: Correct Docker deploy commands for MFPulse — NEVER improvise, follow deploy.sh exactly
type: feedback
---

## CRITICAL: Follow deploy.sh exactly. Never improvise Docker commands.

### deploy.sh runs from LOCAL machine (not from the server)
```bash
./scripts/deploy.sh auto          # from local, SSHes to server
./scripts/deploy.sh frontend      # frontend only
./scripts/deploy.sh rebuild       # docker compose build (deps/Dockerfile changes)
```

### If running commands manually (SSH'd into server):

**Frontend-only** (web/ changes, no backend):
```bash
cd /home/ubuntu/mfpulse_reimagined/web && pnpm build
docker exec mf-pulse rm -rf /app/web/out
docker cp /home/ubuntu/mfpulse_reimagined/web/out/. mf-pulse:/app/web/out/
# NOTE: the /. at end copies CONTENTS, not the directory — critical!
# NO restart needed — FastAPI serves static files
```

**Backend-only** (backend/app/ changes):
```bash
docker cp /home/ubuntu/mfpulse_reimagined/backend/app/. mf-pulse:/app/app/
docker restart mf-pulse
```

**Both frontend + backend**:
```bash
# Frontend first (no restart), then backend (restart)
```

**Rebuild** (requirements.txt, Dockerfile, docker-compose.yml changes):
```bash
cd /home/ubuntu/mfpulse_reimagined && docker compose build && docker compose up -d
```

### Common mistakes to avoid:
1. `docker cp .../out mf-pulse:/app/web/out` — WRONG, nests as out/out. Use `out/.` source
2. Running `docker compose build` for frontend-only changes — wasteful, unnecessary
3. Forgetting that deploy.sh SSHes FROM local TO server — can't run it ON the server
4. Not verifying JS chunk hash changed after deploy (browser + CDN can cache old HTML)

### Always verify deployment:
```bash
curl -s https://mfpulse.jslwealth.in/sectors | grep -o "sectors-[a-z0-9]*\.js"
# Must match: ls web/out/_next/static/chunks/pages/sectors-*.js
```
