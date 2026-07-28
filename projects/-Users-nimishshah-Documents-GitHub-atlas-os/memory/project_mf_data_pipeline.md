---
name: project-mf-data-pipeline
description: "MF data pipeline state — fund coverage, fixes applied, nightly sync architecture"
metadata: 
  node_type: memory
  type: project
  originSessionId: 1157be27-129d-43fb-b424-04e306c49c59
---

## State as of 2026-05-12

**Fund coverage**: 531 / 587 active universe funds have states on 2026-05-11.

**Active universe**: 592 total → 587 active (5 defunct funds closed: F000000JVP, F0000020YR, F000000I40, F00000NMT6, F00000NMT7 — stopped 2019-2020, effective_to set directly on EC2).

**Why not 587/587 (56 remaining gap):**
- 54 genuinely new funds launched 2025-2026 (<252 trading days on mfapi.in) — will qualify automatically as they accumulate history
- 2 genuinely stale at source: F000000FV2 (stopped 2026-03-20), F00000NS2W (stopped 2025-01-22)
- 531 = current theoretical maximum

## Root causes fixed

1. **Problem A** (`atlas/compute/funds.py` — commit `6ba570e`): `assemble_fund_states` used exact-date nav_state matching, silently dropping funds with T-1/T-2 settlement lag. Fixed to 10-day lookback + bisect for latest available.

2. **Problem B** (148 funds stuck at 2026-04-02): JIP pipeline lost AMFI scheme_code mapping. Fixed by `scripts/amfi_nav_backfill.py` which fetches from mfapi.in using amfi_code from JIP de_mf_master. All 148 recovered.

3. **Problem C** (140 established funds with <252 rows): JIP added 12-year-old funds to the universe in April 2026 WITHOUT their historical NAV. Fixed by `scripts/amfi_history_backfill.py` — fetches full history from mfapi.in (ON CONFLICT DO NOTHING). 258,607 rows inserted for 140 funds. Coverage 336 → 531.

## Coverage progression
- Start: 191 funds
- After Problem A fix (10-day bisect): ~250 funds
- After Problem B fix (amfi_nav_backfill, M4 backfill): 336 funds
- After Problem C fix (amfi_history_backfill, M4 backfill 2025-01-01 to 2026-05-11): 531 funds

## Nightly pipeline

`run_atlas_nightly.sh` step order:
1. JIP sync (primary source)
1b. AMFI supplemental sync (`amfi_nav_backfill.py --write --stale-days 5`) — catches funds JIP no longer covers
2. M2 → 3. M3 → 4. M4 → 5. M5 → 6. health check

Runs at 21:30 IST weekdays (15:30 UTC).

## Key scripts
- `scripts/amfi_nav_backfill.py` — recurring supplemental NAV sync. Args: `--write`, `--stale-days N`, `--fund MSTAR_ID`
- `scripts/amfi_history_backfill.py` — one-time (re-runnable) full history backfill for funds JIP tracks without history. Args: `--write`, `--max-rows N`
- `scripts/m4_backfill.py` — backfill lens1/states for a date range. Args: `--phase lens1|states|all`, `--start`, `--end`

**Why:** JIP's pipeline permanently lost AMFI scheme_code mapping for ~148 funds AND added established funds without historical data. Supplemental sync is permanent infrastructure; history backfill is one-time but re-runnable.
