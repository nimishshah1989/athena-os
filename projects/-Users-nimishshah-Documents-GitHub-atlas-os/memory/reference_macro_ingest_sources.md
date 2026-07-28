# Macro Ingest Sources — Atlas B.1

Status as of 2026-05-27. Verified on EC2 and Supabase DB.

## Columns and Sources

| Column | Source | Series/URL | Auth | Historical Depth | Status |
|--------|--------|-----------|------|-----------------|--------|
| us_10y_yield | FRED | DGS10 | FRED_API_KEY (EC2 .env) | 1962-present, daily | LIVE |
| india_10y_yield | FRED | INDIRLTLT01STM | FRED_API_KEY | 2001-present, monthly → forward-filled daily | LIVE |
| risk_free_91d | FRED | IRSTCI01INM156N (call money proxy) | FRED_API_KEY | 1992-present, monthly → forward-filled daily | LIVE — proxy only, not a T-bill rate |
| cpi_yoy | MOSPI bundled CSV | atlas/ingest/macro/mospi_cpi_ingest.py | none | 2012-2025, monthly → forward-filled daily | LIVE |
| brent_inr | FRED brent_usd × usdinr | DCOILBRENTEU × DEXINUS | FRED_API_KEY | 2016-present, daily | LIVE — derived column, not stored as brent_usd |
| vix_9d | Yahoo Finance | query2.finance.yahoo.com/v8/finance/chart/^INDIAVIX | none (public) | 2016-present, daily | LIVE |
| fii_cash_equity_flow_cr | NSE India | fiidiiTradeReact API | none | TODAY ONLY — historical BLOCKED | BLOCKED |
| dii_flow | NSE India | fiidiiTradeReact API | none | TODAY ONLY — historical BLOCKED | BLOCKED |

## NSE FII/DII — Investigation Log (2026-05-27)

All historical NSE FII/DII endpoints are dead or bot-blocked:
- `https://archives.nseindia.com/content/nsccl/fao_fo_all_foii_dii.csv` — 404
- `https://nseindia.com/api/fiidiiTradeReact` — returns current day JSON (parsed, works)
- All archive.nseindia.com paths for historical CSV → 404
- nsetools Python library → uses same dead URLs
- NSE website FII data page → bot-blocked (JS challenge), no curl access

Only current-day data is available via fiidiiTradeReact. The `atlas.ingest.macro.nse_bhavcopy_ingest.fetch_fii_dii_today()` function inserts today's row; historical coverage is permanently 0.04% until a paid data vendor is onboarded.

## FRED risk_free_91d — Proxy Decision

INTGSB91D156N returns HTTP 400 (series was discontinued or never published via FRED).
IRSTCI01INM156N = RBI call money/interbank overnight rate, monthly.
- Used as proxy for 91-day risk-free rate
- The series is a reasonable short-term rate proxy for Indian risk computations
- Documented in fred_ingest.py docstring and SERIES_MAP
- Verified: 123 rows on EC2 for 2016–2026-03

## Forward-Fill Strategy

Two tiers:
1. `_forward_fill_monthly_col(col, engine, start)` — for india_10y_yield, risk_free_91d, cpi_yoy. Monthly source data → carry value into all daily NULL rows (up to 31 days).
2. `_forward_fill_any_col(col, engine, start)` — for us_10y_yield, brent_inr, vix_9d, cpi_yoy. Trading-day sources → carry value into weekend/holiday NULL rows.

SQL pattern: correlated subquery UPDATE:
```sql
UPDATE atlas.atlas_macro_daily dst
SET {col} = (
    SELECT src.{col}
    FROM atlas.atlas_macro_daily src
    WHERE src.{col} IS NOT NULL
      AND src.date <= dst.date
      AND src.date >= :start
    ORDER BY src.date DESC
    LIMIT 1
)
WHERE dst.{col} IS NULL
  AND dst.date >= :start
```

## Final Coverage (2026-05-27, EC2 DB, 2752 rows from 2016-01-01)

| Column | Coverage | Status |
|--------|---------|--------|
| us_10y_yield | 99.96% | PASS |
| india_10y_yield | 99.89% | PASS |
| risk_free_91d | 99.89% | PASS |
| fii_cash_equity_flow_cr | 0.04% | BLOCKED |
| dii_flow | 0.04% | BLOCKED |
| cpi_yoy | 100% | PASS |
| brent_inr | 99.96% | PASS |
| vix_9d | 100% | PASS |

G3 acceptance (≥95% for all 8 cols): DONE_WITH_CONCERNS — 6/8 pass; FII/DII BLOCKED.
