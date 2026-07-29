---
name: M3 momentum bug fix state
description: RS momentum ratio bug fixed and fully backfilled on EC2; confirmed on main
type: project
originSessionId: 872afc26-e778-4c12-871e-2eee9744c546
---
Bug in `atlas/compute/primitives.py::add_rs_momentum` fixed on 2026-05-09.

**The bug:** `ema_10_ratio = ema_10_stock / ema_10_benchmark` (price-level ratio). ETFs at ~₹200 always got r10 ≈ 0.009 < 1 → always Flat/Deteriorating.

**The fix:** `ema_10_ratio = ema_10_stock / ema_20_stock` (within-entity EMA momentum). Commit `da3fd16` on `feat/m13-thresholds-admin`, now on `origin/main`.

**Backfill completed on EC2 (2026-05-09/10):**
- M2 stocks: 1,383,801 rows → atlas_stock_metrics_daily + atlas_stock_states_daily
- M2 ETFs: 243,657 rows → atlas_etf_metrics_daily + atlas_etf_states_daily
- M5 stocks: 909,822 rows → atlas_stock_decisions_daily
- M5 ETFs: 167,815 rows → atlas_etf_decisions_daily

**Validation result (momentum_state distribution):**
- ETFs: Improving 17.6%, Accelerating 7.4% (was 0% before fix)
- Stocks: Improving 15.4%, Accelerating 6.1% — distributions now match

**Why:** Cross-entity price ratio made ETF price (₹200) vs Nifty (₹22,000) always < 1.

**How to apply:** validate_m7_phase3.py times out on the cross-schema JOIN (atlas_stock_decisions_daily × de_equity_ohlcv) via Supabase pooler. Run targeted SQL checks instead.
