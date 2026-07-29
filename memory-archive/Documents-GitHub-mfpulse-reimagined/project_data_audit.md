---
name: MF Pulse Data Audit & Schema Reality
description: Complete audit of all DB tables, column names, data coverage, API response shapes, and critical schema mismatches between frontend expectations and actual DB
type: project
---

## Database Schema Reality (as of 2026-03-29)

### CRITICAL BUG FIXED: Mapped[None] in all 11 ORM model files
All numeric columns in SQLAlchemy models used `Mapped[None]` instead of `Mapped[Optional[Decimal]]`. This caused SQLAlchemy to return None for every numeric field even when DB had data. Fixed 2026-03-29 in commit 7a76ea2.

### fund_master (13,376 rows, 48 columns)
Key columns: mstar_id, fund_name, category_name (51 SEBI cats), amc_name (58 AMCs), purchase_mode (int: 1=Regular 6791, 2=Direct 6250, NULL 335)
**NO `aum` column — AUM lives on fund_holdings_snapshot**

### nav_daily (2,235,255 rows, 13,126 funds)
Columns: mstar_id, nav_date, nav, return_1d through return_20y, cumulative returns, calendar year returns, 52wk high/low
Date range: 2016-01-01 to 2026-03-29
**CRITICAL: 84.5% of funds have ≤3 NAV rows. Only 1,445 have 30+ rows (min for charts). Backfill running.**

### fund_lens_scores (40,106 rows, 13,376 funds)
6 lens scores (0-100). Coverage: Return 87.6%, Risk 70.5%, Consistency 77.6%, Alpha 51.8%, Efficiency 94.9%, Resilience 20.6%

### fund_classification (40,106 rows) — SEPARATE TABLE
Contains: return_class, risk_class, etc. + headline_tag. All 40,106 rows have headline_tag.

### fund_holdings_snapshot (13,396 snapshots, 6,581 funds)
AUM: 6,563 funds with non-null AUM (stored in raw rupees, divide by 1e7 for Cr)
Also: num_holdings, equity_style_box, pe/pb/pc/ps ratios, roe/roa/net_margin, ytm, duration

### fund_holding_detail (475,705 rows, 6,572 funds)
Linked via snapshot_id FK (NOT mstar_id). Holdings sorted by weighting_pct DESC.

### fund_sector_exposure (49,874 rows, 4,534 funds, 11 Morningstar sectors)
Field: net_pct (NOT allocation_pct)

### risk_stats_monthly (23,818 rows, 12,223 funds, 126 columns)
Full risk metrics at 1Y/3Y/5Y/10Y: Sharpe, Alpha, Beta, StdDev, Sortino, MaxDD, Treynor, InfoRatio, Capture Up/Down, Correlation
**Includes cat_* category comparison fields** (cat_sharpe_3y, cat_alpha_3y, etc.)

### rank_monthly (12,808 funds)
quartile_1m through 10y, abs_rank_*, cal_year_pctile_*

### sector_rotation_history (44 rows = 11 sectors × 4 months)
RS scores + momentum + quadrant. Range: 2026-01-30 to 2026-03-15

### Other: fund_asset_allocation (6,579), fund_credit_quality (4,518), category_returns_daily (51)

## API Response Structures

### Universe: data[] flat array with fund+nav+lens+holdings snapshot merged
### Fund detail: data.fund{}, data.returns{}, data.risk_stats{}, data.portfolio{}, data.top_holdings[], data.sector_exposure[], data.asset_allocation{}, data.credit_quality{}
### Sectors: data[] with sector_name, quadrant, rs_score, momentum_1m
