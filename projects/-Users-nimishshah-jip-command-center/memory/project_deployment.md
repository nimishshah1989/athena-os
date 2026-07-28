---
name: deployment-config
description: JIP Command Center deployment details — ports, URLs, EC2 config, database, Nginx
type: project
---

## Deployment (Live as of 2026-03-24)

- **URL:** https://ops.jslwealth.in
- **EC2:** 13.206.34.214 (same server as all JIP platforms)
- **Ports:** Frontend on 8011, Backend API on 8012 (internal Docker: 3000 and 8007)
- **Port 8006 was taken** by MF Pulse backend — had to use 8011/8012
- **Nginx:** /etc/nginx/sites-available/ops.jslwealth.in (SSL via certbot, expires 2026-06-22)
- **Docker container name:** jip-command-center
- **Repo path on EC2:** /home/ubuntu/jip-command-center
- **Database:** Same RDS as fie2 — `fie-db.c7osw6q6kwmw.ap-south-1.rds.amazonaws.com:5432/fie_v3`
- **Schema:** `jip_ops` (7 tables: health_checks, quality_scores, issues, git_snapshots, claude_sessions, bugs, action_log)
- **GitHub:** nimishshah1989/jip-command-center (PRIVATE repo)
- **EC2 git pull requires** temporarily making repo public (no SSH key on EC2 for GitHub)

## Nginx proxies
- `ops.jslwealth.in/` → `127.0.0.1:8011` (Next.js frontend)
- `ops.jslwealth.in/api/` → `127.0.0.1:8012/api/` (FastAPI backend)
