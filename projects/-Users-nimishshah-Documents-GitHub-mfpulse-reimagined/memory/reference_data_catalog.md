---
name: MF Pulse Complete Data Catalog
description: Every data point available — MarketPulse APIs, Morningstar DB tables, computed lens scores, frontend API functions. Use when building/enriching any visual or page.
type: reference
---

# MF Pulse Data Catalog — Complete Reference

## DATABASE TABLES & COLUMNS

### fund_master (Core fund identification & metadata)
- **Identifiers**: mstar_id, fund_id, amc_id, amc_name, isin, amfi_code
- **Names**: legal_name, fund_name, previous_fund_name
- **Classification**: category_name (SEBI), broad_category
- **Dates**: inception_date, performance_start_date, closed_to_investors, termination_date
- **Type Flags**: purchase_mode, is_index_fund, is_fund_of_funds, is_etf, is_insurance_product, sip_available
- **Costs**: net_expense_ratio, gross_expense_ratio, turnover_ratio
- **Risk Labels**: indian_risk_level, benchmark_risk_level, fund_risk_level
- **Benchmark & Strategy**: primary_benchmark, investment_strategy (text), investment_philosophy (text)
- **Fund Manager**: managers, manager_education, manager_birth_year, manager_certification
- **Structure**: pricing_frequency, legal_structure, domicile_id, exchange_id
- **Access**: lock_in_period, distribution_status
- **Status**: performance_ready, is_active, is_eligible, eligibility_reason

### nav_daily (Daily NAV and returns)
- **Core**: mstar_id, nav_date, nav, nav_change
- **52W Range**: nav_52wk_high, nav_52wk_low
- **Point Returns**: return_1d, return_1w, return_1m, return_3m, return_6m, return_ytd, return_1y, return_2y, return_3y, return_4y, return_5y, return_7y, return_10y, return_15y, return_20y, return_since_inception
- **Cumulative**: cumulative_return_3y, cumulative_return_5y, cumulative_return_10y
- **Calendar Year**: calendar_year_return_1y through calendar_year_return_10y

### risk_stats_monthly (Risk metrics with category comparisons)
All metrics available at 1y/3y/5y/10y horizons, each with `cat_` prefix for category average:
- **Sharpe Ratio**: sharpe_1y/3y/5y/10y + cat_sharpe_*
- **Alpha**: alpha_1y/3y/5y/10y + cat_alpha_*
- **Beta**: beta_1y/3y/5y/10y + cat_beta_*
- **Volatility (StdDev)**: std_dev_1y/3y/5y/10y + cat_std_dev_*
- **Sortino**: sortino_1y/3y/5y/10y + cat_sortino_*
- **Max Drawdown**: max_drawdown_1y/3y/5y/10y
- **Treynor**: treynor_1y/3y/5y/10y + cat_treynor_*
- **Info Ratio**: info_ratio_1y/3y/5y/10y + cat_info_ratio_*
- **Tracking Error**: tracking_error_1y/3y/5y/10y + cat_tracking_error_*
- **Capture Up/Down**: capture_up_1y/3y/5y/10y, capture_down_* + cat_ versions
- **Correlation**: correlation_1y/3y/5y/10y + cat_*
- **R-Squared**: r_squared_1y/3y/5y/10y + cat_*
- **Kurtosis/Skewness**: kurtosis_*/skewness_* + cat_ versions
- **Mean Return**: mean_1y/3y/5y/10y
- **Trailing Returns**: ttr_return_1y/3y/5y/10y
- **Category Returns**: cat_return_1y/3y/5y/10y

### rank_monthly (Performance ranking within category)
- **Quartile Ranks** (1-4): quartile_1m, 3m, 6m, 1y, 2y, 3y, 4y, 5y, 7y, 10y
- **Absolute Ranks**: abs_rank_1m, 3m, 6m, ytd, 1y, 2y, 3y, 4y, 5y, 7y, 10y
- **Calendar Year Percentile** (0-100): cal_year_pctile_ytd, 1y through 10y

### fund_holdings_snapshot (Portfolio-level metrics)
- **Core**: mstar_id, portfolio_date, num_holdings, num_equity, num_bond
- **Style**: equity_style_box, bond_style_box
- **Portfolio Metrics**: aum (raw rupees), avg_market_cap, pe_ratio, pb_ratio, pc_ratio, ps_ratio, roe_ttm, roa_ttm, net_margin_ttm
- **Bond Metrics**: ytm, avg_eff_maturity, modified_duration, avg_credit_quality
- **Other**: prospective_div_yield, turnover_ratio, est_fund_net_flow

### fund_holding_detail (Individual security holdings)
- holding_name, isin, holding_type, weighting_pct, num_shares, market_value
- global_sector, country, currency, coupon, maturity_date, credit_quality, share_change

### fund_sector_exposure (11 Morningstar sectors)
- mstar_id, portfolio_date, sector_name, net_pct
- Sectors: Basic Materials, Communication Services, Consumer Cyclical, Consumer Defensive, Energy, Financial Services, Healthcare, Industrials, Real Estate, Technology, Utilities

### fund_asset_allocation
- equity_net, bond_net, cash_net, other_net
- india_large_cap_pct, india_mid_cap_pct, india_small_cap_pct

### fund_credit_quality (debt funds)
- aaa_pct, aa_pct, a_pct, bbb_pct, bb_pct, b_pct, below_b_pct, not_rated_pct

### category_returns_daily
- category_code, category_name, as_of_date
- cat_return_2y/3y/4y/5y/7y/10y + cat_cumulative_* versions

### fund_lens_scores (computed)
- 6 scores (0-100): return_score, risk_score, consistency_score, alpha_score, efficiency_score, resilience_score
- data_completeness_pct, available_horizons, engine_version, input_hash

### fund_classification (computed)
- 6 tier labels: return_class, risk_class, consistency_class, alpha_class, efficiency_class, resilience_class
- headline_tag (text summary)

### sector_rotation_history
- sector_name, snapshot_date, avg_weight_pct, momentum_1m, momentum_3m
- rs_score, quadrant, fund_count, weighted_return, total_aum_exposed

### Strategy tables
- strategy_definition (config JSONB, type, name)
- strategy_backtest_run (final_value, cagr, xirr, max_drawdown, sharpe, monthly_returns JSONB, nav_series JSONB)
- strategy_live_portfolio (current_nav, current_aum, rebalance dates)
- strategy_portfolio_holding (mstar_id, weight_pct, units, entry_nav)

### index_master + index_daily
- index_name, close_price, returns across all periods

---

## MARKETPULSE APIs (proxied via /api/v1/market/*)

### GET /market/nifty
- index: current_price, open, high, low, prev_close, change_pct, volume
- returns: return_1m, return_3m, return_6m, return_1y, return_ytd (from /api/indices/latest)

### GET /market/regime
- market_regime, regime_since, generated_at
- leading_sectors: [{sector, rs_score}]
- top_etfs: [{ticker, sector, action}]

### GET /market/sentiment
- composite_score (0-100), zone
- layer_scores: {short_term_trend, broad_trend, advance_decline, momentum, extremes}
- short_term_trend.metrics: [{key, pct}] — above_10ema, above_21ema, above_50ema, hit_52w_high, macd_bull_cross, rsi_daily_gt60
- broad_trend.metrics: [{key, pct}] — above_200ema, above_12ema_monthly, rsi_above_50, golden_cross, death_cross, above_upper_bb, below_lower_bb

### GET /market/breadth
- Advance/decline lines, AD ratio, divergences
- EMA breadth indicators across multiple lookback periods

### GET /market/sectors
- Array of sector RS scores with momentum, quadrant, percentile

---

## FRONTEND API FUNCTIONS (web/src/lib/api.js)

### Bulk
- fetchUniverseData() — all funds with lens scores (cached 10 min)
- fetchAllFunds(params) — paginated fund list

### Fund Detail
- fetchFundDetail(mstarId) — full deep-dive including risk stats, ranks, portfolio metrics, holdings, sectors, credit quality, category averages
- fetchNAVHistory(mstarId, period) — NAV time series
- fetchFundVerdict(mstarId) — AI-generated verdict text

### Lens
- fetchLensScores(params), fetchFundLensScores(mstarId)
- fetchLensDistribution(params) — tier counts per lens

### Holdings
- fetchHoldings(mstarId, top), fetchSectorExposure(mstarId)
- fetchOverlap(mstarIds) — portfolio overlap analysis

### Sectors
- fetchMorningstarSectors() — current rotation
- fetchSectorHistory(months), fetchSectorDrillDown(sector, minPct, limit)
- fetchFundExposureMatrix(limit) — top N funds × 11 sectors matrix

### Dashboard
- fetchCategoryAlignment() — category quadrant alignment
- fetchFundArchetypes() — 9 archetype distribution

### Simulation
- fetchSimulation(params) — full SIP/lumpsum/hybrid backtest

---

## KEY DATA COUNTS (as of 29 Mar 2026)
- 11,703 total funds → ~567 after global filters (Regular + Equity + AUM>1000Cr)
- 49,874 sector exposure rows (4,534 funds × 11 sectors)
- 455,664 holding detail rows
- 4,518 credit quality rows
- Alpha coverage: 59% of filtered set (index/passive funds lack alpha)
- AUM: in fund_holdings_snapshot.aum (raw rupees, divide by 1e7 for Crores)

## DATA NOT YET SURFACED
- Calendar year returns (1-10 years) — available but not displayed
- Kurtosis/Skewness — computed but not visualized
- Capture ratios — in risk_stats but only partially used
- Fund manager data — managers, education, certifications
- Investment strategy/philosophy text
- Holdings overlap analysis — endpoint exists, no UI
- Portfolio valuation metrics (P/E, P/B, ROE) — in holdings snapshot
- Bond metrics (YTM, duration, credit quality) — for debt fund pages
- Index benchmarking data — index_daily has full returns
- Estimated fund net flows — in holdings snapshot
