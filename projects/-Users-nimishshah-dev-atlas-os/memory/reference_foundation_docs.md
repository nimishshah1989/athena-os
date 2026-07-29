---
name: Atlas foundation + milestone + PRD doc locations
description: Where every spec lives in the atlas-os repo
type: reference
originSessionId: 85e68f27-9b9a-4a5b-ac58-6da306889a19
---
All paths relative to `/Users/nimishshah/Documents/GitHub/atlas-os/`.

**Foundation docs (read these first for any architectural question):**
- `docs/00_METHODOLOGY_LOCK.md` — what the system computes (formulas, states, decisions). Source of truth.
- `docs/01_BACKEND_ARCHITECTURE.md` — how the system is built (conventions, libraries, topology).
- `docs/02_DATABASE_SCHEMA.md` — every column of every table.
- `docs/03_VALIDATION_FRAMEWORK.md` — five-tier validation, what "done" means per milestone.
- `docs/04_THRESHOLD_CATALOG.md` — 35 tunable thresholds with allowed ranges.

**Milestone docs (build instructions per milestone):**
- `docs/milestones/ATLAS_M0_DATA_CORE_PREP.md` — gap-fill + de_etf_holdings + cleanup (COMPLETE)
- `docs/milestones/ATLAS_M1_SCHEMA_AND_REFERENCE.md` — schema + universe lock (in progress)
- `docs/milestones/ATLAS_M2_STOCK_ETF_METRICS.md` — four primitives + state classification (patched 2026-05-06 with ema_50/atr_21/Stage-1 bootstrap notes)
- `docs/milestones/ATLAS_M3_SECTOR_AND_MARKET.md` — sector aggregation + market regime
- `docs/milestones/ATLAS_M4_MUTUAL_FUND_LENSES.md` — three-lens fund framework
- `docs/milestones/ATLAS_M5_DECISION_ENGINE.md` — investability + entry/exit triggers (patched 2026-05-06 with F1-F7 methodology alignment)

**Project decisions and inventories:**
- `prds/00_INFRA_DECISIONS.md` — Supabase pivot, scope decisions, F1-F7 fixes, Stage-1 bootstrap, schema additions
- `prds/M1_DATA_CORE_INVENTORY.md` — original M0 inventory PRD
- `output/GAP_MAP.md` — M0 gap analysis (executed)
- `output/validation_M1_2026-05-03.md` — schema discovery + per-table inventory results
- `decisions.jsonl` — append-only hash-chained decision log

**Development plan:**
- `docs/06_DEVELOPMENT_PLAN.md` — strategic plan: per-milestone gstack skill cadence, frontend approach, backend-frontend linking strategy.

**How to apply:** When the user asks any specific question about Atlas behaviour, check methodology first; for "how do I build X" check the milestone doc; for "where does X column live" check the schema doc. The threshold catalog is the single source for tunable values.
