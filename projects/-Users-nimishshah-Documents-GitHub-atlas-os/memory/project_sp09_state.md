---
name: project_sp09_state
description: "SP09 CTS Timing Engine — FULLY SHIPPED to production (main + atlas.jslwealth.in)"
metadata: 
  node_type: memory
  type: project
  originSessionId: ce268aff-9b51-4419-a342-d344cea6cf46
---

# SP09 CTS Timing Engine — State as of 2026-05-13

## Status: COMPLETE — merged to main, live on atlas.jslwealth.in

Branch `worktree-feat+sp09-cts-timing-engine` merged to `main` (23 files changed, 1,743 insertions). Frontend deployed via PM2 on 13.202.162.196.

## What shipped (full feature set)

### Backend (Python)
- `atlas/compute/cts/`: Weinstein stage classifier (SMA_150 slope), PPC/NPC signal engine (TRP ratio ≥1.5x, close_pct, vol), Contraction (ATR slope + narrowing + proximity-to-high)
- `atlas/compute/sector_pivot.py`: sector-level PPC/NPC balance → `atlas_cts_sector_pivot_daily`
- `atlas/compute/compute_cts_signals.py`: nightly orchestrator (signals → pivot → auto-calibrate)
- `scripts/backfill_cts_signals.py`: 504-day historical backfill script
- `scripts/backfill_cts_fwd_returns.py`: forward return backfill (10d/20d) — bulk backfill done 2026-05-12 (288,030/298,021 rows = 96.6% coverage)
- `atlas/compute/cts/calibration.py`: IC + hit-rate pipeline + auto-calibration proposals
- `atlas/api/cts_brief.py`: POST `/api/v1/stocks/{symbol}/cts_brief` — LLM brief via Groq with SEBI guard
- `atlas/agents/specialists/base.py`: `call_groq` async helper

### DB migration
- `migrations/versions/043_create_cts_tables.py`: `atlas_cts_signals_daily` + `atlas_cts_sector_pivot_daily` + `atlas_cts_calibration_proposals` + `atlas_cts_param_history`

### Frontend
- **StockScreener.tsx**: Bi-directional timing grade `+A/+B/—/−B/−A` column. Grade logic: Stage 4 → −A, Stage 3+NPC → −A, Stage 3 → −B, Stage 2+actionReady → +A, Stage 2 → +B. Badge colors: teal (buy) / amber (sell-watch) / signal-neg (sell-act). Plus slim score bar + PPC/NPC chip as secondary context.
- **StockScreener.tsx Signal column**: Replaced concatenated text with 4 labelled rows: RS (pctile, colored) / Stage (badge) / Mom / Vol — no more "91st% · Stage2 · Improv · Accum" concatenation.
- **ConvictionCell.tsx**: Removed Industry/Baseline badges; now score bar + "[Tier] peers" label + plain-English tooltip.
- **CTSSectorPanel.tsx**: Sector timing table with `+A/+B/—/−B/−A` grade per sector derived from `pivot_balance` + `action_alert_count` + NPC dominance. Grade column tooltip: "+A/+B = buy timing | −B/−A = sell timing".
- **CTSIndexTimingPanel.tsx** (new): 4 index cards (Nifty 50/100/500/All Tradeable). Aggregates stock-level grades into buy%/sell%/neutral% stacked bar + `aggregateGrade()` by net directional score. net≥0.25 + plus_a>0 → +A, net≥0.10 → +B, etc.
- **StocksClientShell.tsx**: Page order: IntradayRSLeaders → BreadthPanel → BubbleChart → IntelligencePanel → CTSIndexTimingPanel → CTSSectorPanel → StockScreener.
- **Next.js API routes**: `/api/cts/sectors` + `/api/cts/index-timing` — both mirrored to `src/app/api/cts/` (legacy production path).
- **nginx**: `/api/cts/` block added before catch-all to proxy to Next.js:3001.

### IC validation results
- `cts_conviction_score` Stage 2 daily cross-sectional IC = 0.024, t = 3.06 (p < 0.01, statistically significant). Professional-grade for a daily signal.
- PPC event IC: sparse signal (~5-10 stocks/day), unmeasurable via cross-sectional IC but valid via Morales methodology (event-based edge).

### Bi-directional grade semantics
- `+` = buy timing, `−` = sell timing; `A` = act now, `B` = watch
- Used at 3 levels: per-stock screener, per-sector pulse, per-index market timing

## Production deploy notes
- EC2 backfill completed: 504-day signals + forward returns both done.
- Forward returns incremental update NOT yet wired into nightly cron (bulk was one-time; future dates need incremental append). Open item.
- ETF page: index ETFs handled via Nifty flags; sectoral ETF timing not wired to ETF page directly. Open item.
- Portfolio management integration: timing grade is prerequisite; actual PM feature is a future milestone.

## Why: Provides Weinstein stage + PPC/NPC/Contraction timing signals for stocks, sectors, and indexes. Enables buy/sell timing discipline for portfolio management.
## How to apply: CTS feature is complete. Future work: incremental fwd-returns cron, ETF page integration, portfolio management feature.
