---
name: deployment_production
description: Production deployment details for FIE/MarketPulse — server, database, container, ports
type: reference
---

## Production Infrastructure

### Server
- **IP**: 13.206.34.214 (jslwealth server, t3.large, Mumbai)
- **SSH**: `ssh -i ~/.ssh/jsl-wealth-key.pem ubuntu@13.206.34.214`
- **URL**: marketpulse.jslwealth.in (Nginx → port 8004)

### Container
- **Name**: `marketpulse`
- **Port**: 8004:8004
- **Env file**: `~/apps/marketpulse/.env` (NOT `~/fie2/.env` — different passwords)
- **Run command**: `docker run -d --name marketpulse --restart unless-stopped -p 8004:8004 --env-file ~/apps/marketpulse/.env fie2`
- **Build**: `cd ~/fie2 && docker build -t fie2 .`

### Database
- **RDS**: fie-db.c7osw6q6kwmw.ap-south-1.rds.amazonaws.com
- **User**: fie_admin
- **Password**: Nimish1234 (in ~/apps/marketpulse/.env)

### Deploy Workflow
1. `git push origin main`
2. SSH → `cd ~/fie2 && git pull origin main`
3. `docker build -t fie2 .`
4. `docker rm -f marketpulse; sleep 2; docker run -d --name marketpulse --restart unless-stopped -p 8004:8004 --env-file ~/apps/marketpulse/.env fie2`
5. Verify: `curl http://localhost:8004/health`

### Gotchas — READ THESE EVERY DEPLOY
- **CRITICAL**: ALWAYS use `--env-file ~/apps/marketpulse/.env` — NEVER `~/fie2/.env` (wrong DB password)
- **CRITICAL**: Port mapping is `8004:8004` — NEVER `8004:8000`. PORT env var is 8004.
- Dockerfile now includes `COPY scripts/ ./scripts/`
- Health endpoint is `/health` not `/api/health`
- After `docker build`, must `docker rm -f marketpulse` then `docker run` — just restarting keeps old image
