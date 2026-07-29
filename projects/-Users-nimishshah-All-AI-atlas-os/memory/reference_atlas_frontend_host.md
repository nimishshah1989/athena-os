---
name: atlas-frontend-deployment-host
description: Where atlas.jslwealth.in is served from (post 2026-05-13 consolidation onto compute EC2); PM2-managed; deploy flow after 2026-05-16 dual-tree fix
metadata: 
  node_type: memory
  type: reference
  originSessionId: 421b5ba0-eb97-40da-97eb-fa7e9d72c1a8
---

**atlas.jslwealth.in** is served from **`13.206.34.214`** (same EC2 as the compute backend — the standalone `13.202.162.196` instance was terminated).

- SSH: `ssh -i ~/.ssh/jsl-wealth-key.pem ubuntu@13.206.34.214`
- App root: `/home/ubuntu/atlas-frontend/`
- **Process manager: PM2** (not systemd for this app — systemd manages the compute services like `atlas-api`, `atlas-internal-recompute`, `atlas-intraday`)
  - App name: `atlas-frontend` (id 2 in `pm2 list`)
  - Restart: `pm2 restart atlas-frontend`
  - Logs: `pm2 logs atlas-frontend --lines 30 --nostream`
  - Status: `pm2 status atlas-frontend`
- Port: `3001`

**Source layout (post 2026-05-16 dual-tree fix):**
- `/home/ubuntu/atlas-frontend/src` → **symlink to `frontend/src`**
- Next.js reads from `src/`, which now resolves via symlink to the canonical git-tracked path
- `src.bak/` may exist as a safety backup from the migration — safe to delete after sustained green deploys
- Before the fix: top-level `src/` was a separate untracked copy, `git pull` updated `frontend/src/` but never propagated → silent stranded commits

**Deploy flow** (single source of truth now):
```bash
ssh -i ~/.ssh/jsl-wealth-key.pem ubuntu@13.206.34.214 \
  'cd /home/ubuntu/atlas-frontend && git pull && npm run build && pm2 restart atlas-frontend'
```
No manual file copies. No rsync. `git pull` updates `frontend/src/` which is what the running app reads through the symlink.

**Health check after deploy:**
```bash
ssh ubuntu@13.206.34.214 "curl -s -o /dev/null -w '%{http_code}\n' http://localhost:3001/"
```

**Other PM2 apps on same host** (unrelated to atlas-frontend):
- `app` (id 0) — separate project
- `osho-engine` (id 1) — separate project

**Compute backend** (different deploy path, see [[reference_ec2_access]]):
- `/home/ubuntu/atlas-os/` is its own repo clone
- systemd units: `atlas-api`, `atlas-internal-recompute`, `atlas-intraday`, `atlas-intraday-notify`
- Restart compute services via `sudo systemctl restart atlas-<service>`

Related: [[reference_ec2_access]], [[project_us_stocks_backfill_state]]
