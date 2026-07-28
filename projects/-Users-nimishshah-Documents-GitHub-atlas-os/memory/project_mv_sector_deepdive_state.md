# MV 6 of 9: `atlas.mv_sector_deepdive` — State

**Date**: 2026-05-27
**Migration**: 105 (revises 104)
**Status**: Code complete. Pending parent apply via Supabase MCP.

## What It Serves

Page 04a — Sector Deep-Dive (`/v6/sectors/<name>`). One row per sector (~30 total).
Latest-snapshot only — NOT historical.

## JSONB Sections

- `returns` — 1W/1M/3M/6M/12M absolute returns (pct, 2dp)
- `rs_windows` — 1W/1M/3M/6M/12M RS vs Nifty 500 (pp, 2dp)
- `constituents_top30` — top 30 stocks by composite_score
- `open_signals` — open POSITIVE/NEGATIVE signal calls
- `strength_dist` — {very_strong/strong/neutral/weak/very_weak} NTILE(5) on ret_3m
- `top_picks_top10` — top 10 stocks where composite_score > 0

## Key Design Decision

LATEST-only (not historical like MVs 3–5). This avoids 48,050-row window passes.
All aggregation operates on ~750 rows at one date. REFRESH target <5s.

## Test Status

50 unit tests pass. 13 integration tests written, skipped (EC2 only).

## Cron

`mv_sector_deepdive_nightly` at 20:55 IST (`25 15 * * *`).

## Key Column Name Gotchas

- atlas_universe_stocks: `sector` (not `sector_name`), `tier` (not `cap_tier`)
- atlas_sector_states_daily: `sector_state` (not `verdict`)
- atlas_sector_metrics_daily: `bottomup_rs_3m_nifty500` for sector-level RS
- Weinstein stage comes from atlas_stock_states_daily.`rs_state`
