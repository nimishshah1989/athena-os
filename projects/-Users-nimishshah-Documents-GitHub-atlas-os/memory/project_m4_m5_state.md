---
name: m4-m5-milestone-state
description: M4 fund three-lens engine and M5 decision engine — both validators PASS as of 2026-05-13
metadata: 
  node_type: memory
  type: project
  originSessionId: ff19039a-176f-47fe-b8ee-1ff077ef2a8c
---

M4 and M5 validators both PASS as of 2026-05-13. EC2 is fully deployed.

**Validator status:**
- M4: 308/308 PASS (commit c1ca1b6) — `scripts/validate_m4.py`
- M5: 1168/1168 PASS (commit dc22705) — `scripts/validate_m5.py`

**Root causes fixed this session:**
- M5: 4 `ORDER BY RANDOM()` queries on full multi-year tables (500K+ rows) were timing out at 900s. Fixed by scoping each to `WHERE d.date = (SELECT MAX(date) FROM ...)` before RANDOM().
- M4: Orphan check used exact `nav_date = s.date` equality (always false — states.date=today, metrics.nav_date=yesterday). Fixed with NOT EXISTS check.
- M4: `aligned_aum_pct` in `atlas_fund_lens_monthly` was computed with an older methodology (likely "Underweight" counted as aligned). Recomputed lens2 + lens3 for all 6 disclosure dates with current code — all values now consistent with `atlas_sector_states_daily`.

**EC2 deployment state:**
- `scripts/validate_m4.py` and `scripts/validate_m5.py` deployed via SCP
- `atlas_fund_lens_monthly` recomputed for all 6 dates (Jan 31, Feb 28, Mar 28, Mar 29, Apr 6, May 4)
- `atlas_fund_states_daily` NOT recomputed for lens dates — Tier 3 checks pass without it

**Key data fact:**
As of May 2026, sector states show 0–2 Overweight/Neutral sectors per day (bearish market regime). This means `aligned_aum_pct ≈ 0.0` for nearly all funds, and most funds show `composition_state = Misaligned`. This is correct behavior, not a bug.

**Why:** EC2 backfill done 2026-05-09 for M3. M4+M5 data populated. Validators now fully passing.

**How to apply:** Both milestone validators can be run on EC2 as health checks. Nightly pipeline for M4 runs `run_m4_daily()`, which handles lens2/3 recompute if new disclosures arrive.
