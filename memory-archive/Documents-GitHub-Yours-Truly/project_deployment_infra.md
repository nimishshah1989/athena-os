---
name: YTIP Deployment Infrastructure
description: Docker, server, port mapping, deployment process for YoursTruly Intelligence Platform
type: reference
---

## Server
- **IP:** 13.206.34.214 (jslwealth t3.large, Mumbai)
- **SSH:** `ssh -i ~/.ssh/jsl-wealth-key.pem ubuntu@13.206.34.214`

## Docker Containers
- `ytip-backend` — port 8009→8001, Python/FastAPI
- `ytip-frontend` — port 3009→3000, Next.js
- Network: `ytip-net`
- Restaurant ID: 5 (YoursTruly Cafe)

## Quick Deploy (file-level, no rebuild)
```bash
# Copy file to server then into container
scp -i ~/.ssh/jsl-wealth-key.pem <local_file> ubuntu@13.206.34.214:/tmp/<filename>
ssh ... "docker cp /tmp/<filename> ytip-backend:/app/<path>"
# Restart if needed
ssh ... "docker restart ytip-backend"
```

## Full Rebuild
```bash
ssh ... "cd /home/ubuntu/ytip && docker compose build && docker compose up -d"
```

## Run Engines
```bash
ssh ... "docker exec ytip-backend python -m intelligence.engines --restaurant-id 5"
```

## Generate Brief
```bash
ssh ... "docker exec ytip-backend python -c 'from intelligence.engines.connector import generate_weekly_brief; from database import SessionLocal; from datetime import date; db=SessionLocal(); generate_weekly_brief(db, 5, date.today()); db.close()'"
```

## Verify APIs
```bash
curl http://13.206.34.214:8009/api/v2/intelligence/brief?restaurant_id=5
curl http://13.206.34.214:8009/api/v2/intelligence/findings?restaurant_id=5
curl http://13.206.34.214:8009/api/v2/intelligence/health?restaurant_id=5
```

## Frontend
- http://13.206.34.214:3009/ (Home)
- http://13.206.34.214:3009/dive (Findings)
- http://13.206.34.214:3009/market (Competitors)
- http://13.206.34.214:3009/chat (Ask)
