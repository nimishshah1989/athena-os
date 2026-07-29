---
name: Stocks page complete backlog — path to 100%
description: Every outstanding item on the stocks page (/stocks and /stocks/[symbol]), phase-ordered, with done/pending status as of 2026-05-11
type: project
originSessionId: a161c451-1823-4131-88dd-8ae50c7c7755
---
## What's done (as of 2026-05-11 design-review sprint)

- Bubble chart (StockBubbleChart) — exists, wired, deployed
- Market breadth Band 1 MA tiles (30W/50D/200D) — clickable, filter active state styled
- Market breadth Band 2 index composition — upgraded to show RS + Momentum bars for N50/N100/N500/All with full 100% stacked bars, %↑ positive indicator, inline % labels on segments ≥12%
- StockIntelligencePanel — converted from tall 3-col grid to compact horizontal strip
- StockScreener default sort — cap_rank; null-data rows pushed to bottom (both-null check fixed)
- ret_12m optional column — added, visible by default alongside 1W/6M
- StateJourneyCompact default days — 90→180; API ceiling 365→720
- states-compact nginx routing — fixed (was going to FastAPI :8010, now routes to Next.js :3001)
- StockDeepDiveBody returns — redesigned as 5-tile card grid (1W/1M/3M/6M/12M)
- StockDeepDiveBody — StateJourneyCompact strip added at top of deep dive page
- **Phase B DONE**: Touch targets (min-h-44px), deploy column removed from SQL+type+UI
- **Phase C DONE**: ret_1d + rs_pctile_1w added (SQL + type + screener optional columns); rs_3m_nifty500/rs_3m_tier_gold/stage1_base_qualifies removed from all queries
- **Phase D DONE**: 6 metric charts on deep dive (RS Pctile, 3M Return, EMA Ratio, Drawdown, Extension, Volume); StateHeatmap visual improvements (larger cells, better spacing, borderRadius); rolling page (no tabs)
- Nginx proxy cache cleared (was causing unstyled deep dive page after rebuilds)
- **Phase A DONE**: Pipeline logic verified correct (2 investable = genuine Cautious market with stretched Leaders); added risk_gate + volume_gate to query/type/GATE_LEGEND (7 gate dots, tooltip explains each). 69 missing stocks are intentionally excluded (INSUFFICIENT_HISTORY + ILLIQUID).
- **Phase E DONE**: alpha_3m and alpha_6m optional columns — stock 3M/6M return minus Nifty500 benchmark (via benchmark CTE in getAllStocks SQL). Available as toggleable columns (α 3M, α 6M) in screener.
- **Sprint 7 DONE**: State history bug fixed (INTERVAL '1 day' * days in states-compact route + getStockStateHistory/getStockMetricHistory). 8 new metric columns in SQL + type (rs_pctile_1m, vol_ratio_63, max_drawdown_252, volume_expansion, effort_ratio_63, ema_20_ratio, ma_30w_slope_4w, atr_21). GATE_LEGEND 7→9 (sector_gate 'G' + market_gate 'M'), passCount shows /9. 7 new optional screener columns. Deep dive: Entry signals panel (transition_trigger, breakout_trigger), Exit risk flags panel (6 exit triggers + ATR-21), 2 new charts (EMA20 Ratio, Volume Ratio 63D). StockSnapshotTiles alpha_3m fix. position_size_pct 0% display fix. Deployed commit f411989.
- **Design-review sprint DONE** (2026-05-11): 
  - ATR-21 display fixed: shows ₹XX.X avg daily range (was multiplying by 100 → 3143%)
  - EMA20 chart scale fixed: ema20Data now stores ratio-1 (decimal) not (ratio-1)*100 (percent) — yFormat="pct" handles ×100 internally; was showing -228% for -2.28%
  - EMA20 isBullish fixed: >= 1.0 threshold (was >= 0, always true)
  - EMA20 screener label: "EMA20 %" showing deviation (was "EMA20 Ratio" showing raw ratio)
  - Band 2 composition bars: all states shown as 100% stacked bars; %↑ positive-count shown right; inline labels on wide segments
  - StateHeatmap cells: 10→6px wide, 22→20px tall, labelW 76→90px; 6M now fits ~1000px (no horizontal scroll on desktop)
  - StockSnapshotTiles: replaced Weinstein/EMA-20D-High booleans with 1W Return + 1M Return tiles
  - Pagination: already 50 at a time with "Load N more" button
  - State history in screener: StateJourneyCompact in expanded row works (tested: 126 rows for RELIANCE)
  - Commits: 8a672b3 (EMA20 scale), 9d84752 (compact heatmap + snapshot tiles)

---

## Remaining items / Phase F

### Phase F — Nightly pipeline automation (ops, not frontend)
- Currently pipeline runs manually via SSH to EC2
- Need cron job or systemd timer for: metrics → states → decisions
- Failure alerting (email/webhook on error)
- /plan-eng-review before implementing

### UX still open
- Deep dive page "a lot better" is partially addressed; remaining: add color legend below heatmap; consider segment-view alternative to day-heatmap
- HFCL position_size=0% is CORRECT (risk_gate fails) — user was confused; no code fix needed but consider adding tooltip explanation near Pos Size label
- Weinstein/EMA-20D-High gates no longer in snapshot tiles — still accessible via screener Gates column tooltip (ⓘ) and deep dive Weinstein commentary section

---

## Deployment pattern (reference for all phases)

- Local dev → commit → git push origin main
- EC2 deploy: scp changed src files to /home/ubuntu/atlas-frontend/ → ./node_modules/.bin/next build → pm2 restart atlas-frontend
- nginx routes /api/states-compact → :3001 (Next.js); /api/* → :8010 (FastAPI)
- SSH host alias: `atlas` (13.202.162.196, ubuntu, jsl-wealth-key.pem)
- No git on EC2 — scp is the deploy mechanism

**Why:** EC2 was set up before git deploy was standardised; scp+build is the current working path.
**How to apply:** Always scp src files, always rebuild (./node_modules/.bin/next build), always verify pm2 is on port 3001 before reloading nginx.
