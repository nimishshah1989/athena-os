---
name: atlas-os repo layout reference
description: Where Python code, migrations, scripts, tests live in the repo
type: reference
originSessionId: 85e68f27-9b9a-4a5b-ac58-6da306889a19
---
All paths relative to `/Users/nimishshah/Documents/GitHub/atlas-os/`.

**Python package (atlas/):**
- `atlas/__init__.py` — package marker
- `atlas/config.py` — `Config` class; reads `ATLAS_DB_URL` etc. from env
- `atlas/db.py` — SQLAlchemy engine factory + `load_thresholds(engine)` helper
- `atlas/preflight.py` — pre-flight check (`python -m atlas.preflight`)
- `atlas/universe/` — M1 universe builders:
  - `sectors.py` — sector taxonomy from `de_instrument.sector` + `de_sector_mapping`
  - `stocks.py` — 750-stock universe with tier classification
  - `etfs.py` — 100-ETF universe with theme classification
  - `indices.py` — 75 curated indices
  - `funds.py` — ~450-500 MF universe with tightened SEBI filter
  - `benchmarks.py` — 9 benchmarks + fund-category-benchmark map seeders
  - `thresholds.py` — 35-threshold catalog seeder (matches `docs/04_THRESHOLD_CATALOG.md`)
  - `lock.py` — orchestrator (entry point: `lock_universe()`)
- `atlas/compute/` — empty in M1; M2-M5 will add primitives/states/decisions modules
- `atlas/validation/` — empty in M1; will hold tier1-5 validation runners
- `atlas/orchestration/` — empty in M1; M2+ will add nightly pipeline runner
- `atlas/api/` — empty; FastAPI thin layer post-M5

**Migrations (Alembic, linear history):**
- `alembic.ini` — Alembic config
- `migrations/env.py` — uses `Config.assert_db_url()` for DSN
- `migrations/versions/001_create_atlas_schema.py`
- `migrations/versions/002_create_universe_tables.py` (4 universe tables)
- `migrations/versions/003_create_master_tables.py` (3 master tables)
- `migrations/versions/004_create_metrics_tables.py` (7 metric tables)
- `migrations/versions/005_create_states_tables.py` (4 state tables)
- `migrations/versions/006_create_decisions_tables.py` (3 decision tables)
- `migrations/versions/007_create_operational_tables.py` (run_log + validation + 5 quarantine + thresholds + threshold_history + benchmark_returns_cache)
- `migrations/versions/008_create_indexes.py`
- `migrations/versions/009_create_constraints.py` (cross-table FKs)
- `migrations/versions/010_grant_role_permissions.py` (3 atlas_* roles, Supabase-adapted)

**Scripts:**
- `scripts/m1_run.py` — M1 entry: sanity check → migrations → universe lock → readiness summary
- `scripts/m1_preflight.py` — Supabase pre-flight wrapper (calls `atlas.preflight.main`)
- `scripts/migrate_to_supabase.py` — JIP→Supabase migration tool (user-owned, predates atlas/ package)

**Tests:**
- `tests/unit/test_universe_filters.py` — pure-logic tests for tier/theme/category classification
- `tests/unit/test_thresholds.py` — catalog integrity tests (35 thresholds, ranges, methodology refs)
- `tests/integration/` — empty; M2+ will add DB-backed integration tests
- `tests/validation/` — empty; will hold Tier 2/3 hand-validation pairs

**Legacy (preserved, untouched):**
- `src/atlas_os/` — M0 inventory module (uses old `JIP_DB_*` env vars). Kept for reference, not imported by `atlas/`.
- `output/` — M0 artefacts (GAP_MAP.md, validation_M1_2026-05-03.md, phase_b_inventory.md)

**Configuration files:**
- `pyproject.toml` — pinned dependencies (Polars 0.20+, pandas-ta 0.3.14b0, empyrical 0.5.5, etc.)
- `.env.example` — `ATLAS_DB_URL` placeholder for Supabase
- `.pre-commit-config.yaml` — pre-commit hooks
- `README.md` — setup + M1 run instructions
- `CLAUDE.md` — agent orientation (project-level)
- `decisions.jsonl` — append-only hash-chained decision log

**How to apply:** When asked to implement something for atlas, follow the milestone doc; place new compute code under `atlas/compute/`, new validators under `atlas/validation/`. Don't write into `src/atlas_os/` (legacy). Don't bypass `atlas/db.py` and `atlas/config.py` for connections — single source of truth.
