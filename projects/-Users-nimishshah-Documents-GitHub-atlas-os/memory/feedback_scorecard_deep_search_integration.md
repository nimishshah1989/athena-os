---
name: feedback-scorecard-deep-search-integration
description: scorecard_writer must compute the FULL deep-search feature library (30+ features) and write to features JSONB. The 6-feature subset is methodology-locked first-class columns; everything else must round-trip through features JSONB so conviction_tape evaluator can fire predicates.
metadata: 
  node_type: memory
  type: feedback
  originSessionId: b59586b9-3103-4e5d-91ea-24bffe155f3d
---

User's instruction (2026-05-25, after conviction tape returned 100% NEUTRAL):

> "solve the bug and get the entire backfill done properly. This has to fix now"

**Why:** The deep-search matrix found 22 of 24 cells with validated rules at IC ≥ 0.04. Those rules reference ~30 features computed in `atlas/discovery/deep_search_features.py`. If `scorecard_writer.py` only writes 6 first-class features (rs_residual_6m, log_med_tv_60d, realized_vol_60d, formation_max_dd, listing_age_days, log_price) and leaves features JSONB empty, NO cell rule can fire because every non-first-class predicate evaluates against NULL. The conviction tape becomes 100% NEUTRAL — useless.

**How to apply:**

1. **`scorecard_writer.compute_daily_scorecard` must call `atlas.discovery.deep_search_features._compute_feature_panels`** (the function that produces all 30+ deep-search features for a panel of instruments × dates). Extract per-instrument values at the target_date and write to features JSONB.

2. **First-class columns stay locked.** The 6 methodology features (rs_residual_6m, log_med_tv_60d, realized_vol_60d, formation_max_dd, listing_age_days, log_price) remain dedicated columns in atlas_scorecard_daily. Don't duplicate them in features JSONB.

3. **Sector features need atlas_sector_master + atlas_universe_stocks join.** Per `project-signal-discovery-2026-05` + the sector RS pre-staged module at /tmp/deep_search_v2/sector_rs_features.py.

4. **The conviction_tape evaluator at `atlas/inference/conviction_tape.py` already reads from atlas_scorecard_daily and the features JSONB.** Once scorecard writes the right keys, no conviction_tape changes needed.

5. **Test the new feature math** — every new column in features JSONB needs a test that the value isn't NULL on a known good instrument-date and matches the deep_search_features computation on the same OHLCV.

6. **Pipeline ordering**: nightly cron must run scorecard_writer FIRST, then atlas/inference/daily.py (which wraps regime + conviction_tape).

Related: [[project-v6-2026-05-25-morning-state]], [[project-signal-discovery-2026-05]], [[feedback-internal-tool-priority]]
