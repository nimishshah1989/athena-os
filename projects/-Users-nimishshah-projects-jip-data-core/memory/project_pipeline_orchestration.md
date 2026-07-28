---
name: Pipeline Orchestration Sprint
description: Replaced broken cron with trigger API + Claude managed agents + data catalog dashboard. 9 bugs fixed, core data at Apr 9. Remaining: ETF/global/fred/MF derived still stale.
type: project
---

Pipeline orchestration sprint completed 2026-04-10.

**What was built:**
- Pipeline trigger API: 6 endpoints at /api/v1/pipeline/trigger/* (API key auth via X-Pipeline-Key)
- Pipeline registry: 23 pipelines, 13 schedule groups, 10 computation scripts mapped
- PipelineExecutor: wires DAG + retry + SLA + alerts + reconciliation
- 3 Claude managed agents (plan limit): EOD (18:33 IST), Computations (19:03), Fund Metrics (21:03)
- Interactive data catalog dashboard at data.jslwealth.in (D3 tree, freshness heatmap)
- API key: Nnjxox4YFWX6ftV2traBbZ21mMkb49o9gE2V37jAGaQ (stored in .env on EC2)

**Bugs fixed (9):**
1. NSE BHAV UDiFF→standard fallback (NSE reverted format)
2. BHAV dedup before batch INSERT (CardinalityViolationError)
3. AMFI redirect follow_redirects=True (moved to portal.amfiindia.com)
4. yfinance show_errors param removed
5. Advisory locks: session→transaction level (pg_try_advisory_xact_lock)
6. Session isolation: each pipeline gets own DB session
7. technicals_sql: asyncpg needs date objects not strings
8. RS scores: added --start-date for incremental (27s vs full rebuild)
9. Index master: 12 missing indices added (FK violation fix)

**Data status as of Apr 10:**
- GREEN: Equity OHLCV, Technicals, RS, Breadth, Index Prices, MF NAV — all at Apr 9
- GREEN: Macro (Apr 30 forward), Qualitative (Apr 10)
- RED: MF Derived (Apr 2) — de_mf_nav_daily view issue like equity had
- RED: ETF OHLCV (Apr 2) — yfinance returning 0 rows, needs date range fix
- RED: Global Prices (Mar 30) — same yfinance issue
- RED: Fred Macro — API error, needs debugging
- RED: MF Holdings (Apr 6) — monthly Morningstar, needs weekly agent
- RED: MF Category Flows (Feb 1) — AMFI monthly source hasn't published

**Next session priorities:**
1. Fix yfinance date range logic (ETF + global returning 0 rows)
2. Fix fred_macro API error
3. Create de_mf_nav_daily view (same pattern as de_equity_ohlcv partitioned parent)
4. Add ETF/global pipelines to EOD agent schedule
5. Consider plan upgrade for weekly/monthly/health check agents
6. Docker image rebuild to bake in all script fixes (currently using docker cp)

**Why:** Cron jobs broke because external APIs changed (NSE format, AMFI domain, yfinance params) and nobody noticed. The managed agent + trigger API architecture makes failures visible and self-healing.

**How to apply:** Start next session by checking data.jslwealth.in dashboard, then fix remaining red streams.
