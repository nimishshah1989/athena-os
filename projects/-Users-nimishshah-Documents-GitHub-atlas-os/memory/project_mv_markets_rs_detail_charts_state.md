# atlas.mv_markets_rs_detail_charts — state

**Date:** 2026-05-27
**Status:** CODE COMPLETE — PENDING SUPABASE APPLY

## What it is

`atlas.mv_markets_rs_detail_charts` powers the "Detail charts — price, volume & RS
in one frame" section of Page 03 (Markets RS). One row per (as_of_date, baseline_code).

9 baselines: NIFTY_50, NIFTY_100, NIFTY_MIDCAP_150, NIFTY_SMLCAP_250, NIFTY_500,
GOLD (GOLDBEES), SP500 (^GSPC USD→INR), MSCI_WORLD (URTH USD→INR), MSCI_EM (VWO USD→INR).

Each row carries 180 trading days of:
- price_series JSONB [{d, o, h, l, c}]
- rs_series JSONB [{d, v}] — 3m excess return vs Nifty 500
- volume_series JSONB [{d, v, up}] — volume + up-day flag
- ma20_series JSONB [{d, v}] — 20-day rolling avg close
- rs_new_high_dates JSONB [date strings] — sparse
- rs_new_low_dates  JSONB [date strings] — sparse
- support_level, resistance_level (MIN/MAX close over 180 days)
- latest_close, rs_latest, rs_delta_3m

## Files

- Migration: `migrations/versions/101_mv_markets_rs_detail_charts.py`
- Tests: `tests/migrations/test_101_mv_markets_rs_detail_charts.py` — 23 unit + 5 integration
- Design: `docs/v6/mvs/2026-05-27-mv-markets-rs-detail-charts-design.md`
- Audit: `docs/v6/audits/2026-05-27-mv-markets-rs-detail-charts-final.md`

## What still needs to be done (parent session)

Apply via Supabase MCP execute_sql (MCP not available in subagent context):
1. CREATE MATERIALIZED VIEW ... WITH NO DATA
2. CREATE UNIQUE INDEX uix_mv_markets_rs_detail_charts_date_baseline
3. REFRESH MATERIALIZED VIEW (blocks 90–180s)
4. SELECT cron.schedule('mv_markets_rs_detail_charts_nightly', '35 14 * * *', ...)

Requires `.supabase-delete-approved-1` + `.supabase-delete-approved-2` for DDL.

## Verify after apply

```sql
SELECT baseline_code, COUNT(*), MAX(as_of_date),
       (SELECT jsonb_array_length(price_series)
        FROM atlas.mv_markets_rs_detail_charts
        WHERE baseline_code = b.baseline_code
          AND as_of_date = MAX(b.as_of_date)) AS price_series_len
FROM atlas.mv_markets_rs_detail_charts b
GROUP BY baseline_code
ORDER BY baseline_code;
```
Expected: 9 rows, COUNT ≥ 1,640, price_series_len = 180 for each.

## pg_cron

Job name: `mv_markets_rs_detail_charts_nightly`
Schedule: `35 14 * * *` (20:35 IST, after mv_india_pulse at 20:30)
Body: `REFRESH MATERIALIZED VIEW CONCURRENTLY atlas.mv_markets_rs_detail_charts`
