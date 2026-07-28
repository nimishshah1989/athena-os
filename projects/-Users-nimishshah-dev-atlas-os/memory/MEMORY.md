# Memory index

- [Canonical deployment](canonical-deployment.md) — ONE frontend (atlas-os/frontend), ONE PM2 (atlas-frontend), EC2 at 13.206.34.214. Read before ANY deploy/rsync/PM2 work.
- [v6 MV & backfill gotchas](v6-mv-and-backfill-gotchas.md) — LATERAL-vs-materialized MV refresh perf; partial-column backfills must UPDATE not INSERT…ON CONFLICT; EC2 deploy mechanics
