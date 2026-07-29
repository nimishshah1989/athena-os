---
name: Supabase architecture pivot
description: Single Postgres on Supabase hosts both JIP de_* (Layer 1) and atlas.* (Layer 2/3)
type: project
originSessionId: 85e68f27-9b9a-4a5b-ac58-6da306889a19
---
**Decision (taken 2026-05-06):** JIP Data Core's ~20-25 core tables migrate to Supabase. Atlas creates its own `atlas` schema in the same Postgres database. Single-DB joins across `public.de_*` ↔ `atlas.*` survive — the architecture spec (Section 1) works as-is.

**Why:** Avoids cross-DB replication / FDW. Preserves the architecture's three-layer model (Layer 1 raw → Layer 2 reference → Layer 3 computed), preserves the role separation (`atlas_writer` / `atlas_reader` / `atlas_admin` per architecture 2.3).

**How to apply:**
- `ATLAS_DB_URL` always points at Supabase. Use the **transaction pooler** URI (port 6543) for compute jobs.
- Atlas treats `public.de_*` as read-only at all times. JIP team owns ingestion to those tables (now into Supabase, not the old AWS RDS).
- Supabase Pro tier is the v0 budget. PITR = 7 days; daily backups for 7 days. Reassess at v1 if compute contention emerges.
- Supabase Auth roles (`anon`, `authenticated`, `service_role`) coexist with atlas's compute roles but are separate concerns. v0 doesn't use RLS on `atlas.*` — server-side trust boundary is sufficient for compute pipelines.
- Supabase migration script: `scripts/migrate_to_supabase.py` (already in repo, run by the user).
- Pre-flight check after migration: `python scripts/m1_preflight.py` → GO/REVIEW/NO-GO + markdown report.

**Old infra references that are now stale:**
- AWS RDS host `jip-data-engine.ctay2iewomaj.ap-south-1.rds.amazonaws.com` — historical only.
- PgBouncer reference in architecture 2.4 — replaced by Supabase's transaction pooler.
- "Existing t3.large EC2" reference in architecture 12.1 — still valid as the compute host for nightly jobs; only the DB target changed.
