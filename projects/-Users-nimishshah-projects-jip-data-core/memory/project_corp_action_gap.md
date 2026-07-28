---
name: Corporate Action Adjustment Gap
description: close_adj is mostly a copy of close (99.99%), not properly adjusted for splits/bonuses. Only 53/524K rows differ. de_adjustment_factors_daily has 0 rows.
type: project
---

close_adj in de_equity_ohlcv is NOT properly adjusted. Only 53 out of 524,934 rows in 2025 have close_adj != close. The de_adjustment_factors_daily table has 0 rows. Corporate actions table has 877 splits+bonuses with ratio_from/ratio_to but cumulative factors were never computed and applied retroactively.

**Why:** This needs a full recomputation: build cumulative adj_factor chain from splits/bonuses, then UPDATE close_adj = close * cum_factor for all historical rows.

**How to apply:** When computing technicals or RS, COALESCE(close_adj, close) is used everywhere, so the impact is limited to stocks that had splits/bonuses. But for those stocks, historical RS and technicals are computed on unadjusted prices which is incorrect.
