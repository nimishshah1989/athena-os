---
name: project_v6_prod_readiness_2026_05_30
description: "Atlas v6 production-readiness session 2 (2026-05-30): entire A-E inventory + F dead-code fixed & verified LIVE; deploy consolidated to git + auth restored. Handoff = H builds + 4 infra follow-ups."
metadata:
  node_type: memory
  type: project
  originSessionId: 7d778cf1-3638-4885-8c5a-a4ea0dd1cd15
---

2026-05-30 session 2 against `docs/v6/2026-05-30-production-readiness-inventory.md`. **The entire A–E inventory + F are DONE and verified on the live page** (atlas.jslwealth.in), 13 commits on main (`9f8aac37..b618494b`). Method: a 10-agent read-only investigation workflow front-loaded every root-cause + exact fix, then fix→deploy→verify-on-live-page→commit per item.

**Shipped + verified live:** B1/B2 (header price from mv_stock_landscape_trader.close_price + conviction_score, not the 404 tv endpoint), B3 (mounted tv router on :8002), B4 (screener .limit() bug → tv_metrics 400→747; was a TradingView range=[0,50] default cap, NOT microcap scarcity), B5 (resolved by C2), C1 (alpha-vs-Nifty500 all 5 horizons; 1w/1m/3m reuse rs_*_nifty500, 6m/12m from atlas_index_metrics_daily 'NIFTY 500'), C2 (/funds repointed to v2 IC-weighted composite via getFundListPage+FundsList, returns joined from atlas_fund_metrics_daily mstar_id=scheme_code), D1 (relabel "Cell base rate" + cleaned 288 stale-negative confidence_unconditional rows from the 2026-05-25 batch → 0 negatives), D2 (closed — not reproduced; AVOIDs correctly negative to -8.33), D3 (/stocks "Data as of" → as_of_date not refreshed_at), E1/E3 (EC2 atlas-os reconciled to main, :8002 restarted), F (deleted 11 dead query modules + 8 dead components; EXCLUDED fund-list.ts+FundsList.tsx now live via C2).

**Caught + fixed a regression my own deploy exposed:** /v1/tv/metrics serializes Decimals as JSON strings; FundamentalsStrip called .toFixed() on them → crashed the stock-detail render once the endpoint went 200. Fixed by coercing string→number. (Proof: only caught by verifying the LIVE page, not the DB.)

**Deploy consolidated (the "v2 shouldn't exist" goal):** live now serves from the git repo via pm2 `atlas-frontend` on :3002 — see [[reference_frontend_deploy_path]] for the new one-command deploy. **Auth restored** (was silently OFF for weeks — middleware was at project root while using a src/ dir, so Next never compiled it; moved to src/middleware.ts).

**HANDOFF — next focused session (NOT done this session):**
1. **H builds** (the inventory's H block — real features, run the design skill-loop): H1 portfolio builder (regime deploy-% × leading sectors × conviction picks, gated by investability gates); H2 since-recommendation realized-vs-predicted track record (now unblocked by A1); H3 RRG sector reclassification (separate true sectors from themes — Defence/Rural/MNC/etc. distort RRG geometry); H4 RRG count reconcile ("4 leading" cards vs "Leading 15" quadrant); H5 Weinstein stage *transitions* (2→3 topping) surfaced prominently, not just a stage label.
2. **Supabase pooler pool_size=15 exhaustion** — intermittent degraded/empty renders (masked by silent `.catch`). NEEDS the Supabase dashboard: raise pool_size or switch frontend to transaction-mode pooler (port 6543). Infra, can't fix in code alone.
3. **Backend :8020 consolidation** — atlas-api.service (:8020) overlaps the internal API on :8002; BUT the /signals pages call :8020 via ATLAS_TV_API_BASE_URL, so migrate those routes onto :8002 (or the main app) BEFORE retiring :8020. Not a safe quick win.
4. **rs_ratios sector-mapping gap** — atlas/tv/rs_ratios.py `_SECTOR_INDEX` keys on e.g. "Oil Gas & Consumable Fuels" but the DB sector is "Oil & Gas", so vs_sector silently falls back to NIFTY 50 (vs_sector == vs_nifty50, mislabeled). Align the sector strings.
5. **Dead code (surgical)** — getAllFunds + FundPageClient cluster (FundMetricTiles/FundScreener/FundBubbleChart) went dead when C2 repointed /funds; remove in a focused pass (funds.ts has live siblings so it's surgical).

Links: [[project_overnight_audit_fix_sequence]], [[reference_frontend_deploy_path]], [[feedback_fund_methodology_v2]], [[reference_ec2_access]].
