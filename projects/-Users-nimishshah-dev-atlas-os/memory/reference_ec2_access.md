---
name: EC2 (atlas) SSH access
description: How to SSH to the Atlas compute host (alias: atlas). Earlier memory called it 'jsl-wealth-server' — that label was wrong; user corrected 2026-05-26.
type: reference
originSessionId: 85e68f27-9b9a-4a5b-ac58-6da306889a19
---
**Host alias:** `atlas` — user's `~/.ssh/config` resolves it to the AWS EC2 box in ap-south-1. Use the alias, not the IP or a different label.

**Standard pattern:**

```bash
ssh atlas 'command'
```

Or interactive:

```bash
ssh atlas
```

**Earlier (wrong) labels to avoid:** `jsl-wealth-server`, `ubuntu@13.206.34.214` as a literal shell argument. The host alias `atlas` is the canonical reference. (Original memory called it `jsl-wealth-server` — that name does not resolve on Nimish's Mac.)

**Why agent uses EC2 instead of Mac (historical, partially stale):**
A 2026-05-06 memory said Mac `psycopg2-binary` hangs on Supabase connect. As of 2026-05-26 the `.venv/` here on Mac has `psycopg2 2.9.12 (dt dec pq3 ext lo64)` and the project `.env` carries an `ATLAS_DB_URL` for the direct connection (IPv6, port 5432). **Verify before assuming Mac is broken** — connectivity may have changed. If it works, prefer Mac for one-shot Alembic runs (faster iteration); fall back to `ssh atlas` only if Mac connect actually fails.

**Atlas connection (canonical):**
- `.env` value `ATLAS_DB_URL` is what `migrations/env.py` (line 43-ish) reads. Don't hardcode the URL elsewhere.
- Pooler region prefix for atlas-os Supabase: `aws-0-ap-south-1.pooler.supabase.com` per .env comment ("aws-1-" tested negative).
- Direct host: IPv6-only, requires Mac IPv6 reachability.

**Repo on EC2:**
- Path: `/home/ubuntu/atlas-os/` (per prior deployments — verify with `ssh atlas 'ls /home/ubuntu/atlas-os'` before assuming).
- Venv: `/home/ubuntu/atlas-os/.venv/`.

**How to apply:**
1. For DDL / Alembic / DB-touching atlas work: try Mac first (`source .venv/bin/activate && alembic upgrade head`). If psycopg2 connect fails, fall back to `ssh atlas`.
2. Use `ssh atlas` as the alias — never substitute alternate labels.
3. Mac is fine for code edits + git work + most testing.
