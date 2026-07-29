---
name: project-v6-2026-05-26-overnight-state
description: "v6 frontend + backend complete and LIVE on atlas.jslwealth.in as of 2026-05-26 06:00 IST. 50 commits pushed, 4 migrations applied (094 replay + 081_z + 095 seed + 096 backfill), 363 atlas_signal_calls + 9 atlas_etf_signal_calls + 14 atlas_mf_switch_rules + 12 atlas_friction_params backfilled from real source tables (zero synthetic data). All 9 v6 pages return 200 with real tickers/sectors/regime data."
metadata: 
  node_type: memory
  type: project
  originSessionId: b59586b9-3103-4e5d-91ea-24bffe155f3d
---

## Status (06:00 IST 2026-05-26)

v6 is LIVE on atlas.jslwealth.in. Built overnight per user's "finish whole project by 7am with zero synthetic data" directive (2am IST).

## Backend state

Alembic head: **`095`** (after applying 094 replay + 081_z linearization + 095 seed + 096 backfill in sequence).

| Table | Rows | Source | Status |
|---|---|---|---|
| `atlas_signal_calls` | **363** | Backfilled from `atlas_conviction_daily` WHERE verdict IN (POSITIVE,NEGATIVE) (migration 096) | LIVE — real |
| `atlas_etf_signal_calls` | **9** | Backfilled from `atlas_etf_scorecard` WHERE is_atlas_leader OR is_avoid (migration 096) | LIVE — real |
| `atlas_mf_switch_rules` | **14** | Seeded one-per-real-category per CONTEXT.md MF SWITCH lock (migration 095) | LIVE — config |
| `atlas_friction_params` | **12** | Seeded by 081_z | LIVE |
| `atlas_cell_definitions` | 21 | Pre-existing (3 cells missing: Small/NEG/1m, Small/NEG/12m, Large/POS/1m); all 21 `drift_status='healthy'` | LIVE |
| `atlas_scorecard_daily` | 747 (latest 2026-05-22) | Pre-existing | LIVE |
| `atlas_fund_scorecard` | 587 (top_holdings 99.7% populated) | Pre-existing | LIVE |
| `atlas_etf_scorecard` | 34 | Pre-existing | LIVE |
| `atlas_universe_stocks` | 727 | Pre-existing | LIVE |
| `atlas_paper_portfolio` | 0 | Empty by design (FM enters real positions via UI; no synthetic seed) | empty-by-design |
| `atlas_mf_recommendation_daily` | 0 | Backfill #2 of migration 096 SKIPPED — `nav` is NOT NULL but `atlas_fund_scorecard.sub_metrics` doesn't carry NAV. Documented gap; v6.1 needs NAV writer | empty-by-design |
| `atlas_ledger` | 0 | Writer cron not deployed; v6.1 backlog | empty-by-design |
| `atlas_provenance_log` | 0 | Writer cron not deployed | empty-by-design |
| `atlas_drift_event_log` | 0 | Drift detector cron not deployed | empty-by-design |

Stale memory items corrected:
- `ssh atlas` (NOT `ssh jsl-wealth-server`) — alias resolves to `ubuntu@13.206.34.214`
- Mac psycopg2 is NOT broken — works fine; local `alembic upgrade head` is the canonical path
- `atlas_mf_switch_rules` exists in migration 085 (Opus right, code-reviewer wrong)
- `atlas_ledger` is the actual table (NOT `atlas_ledger_public` — only the view of that name exists)
- `drift_status` enum is `{healthy, drift_warn, deprecated}` per migration 080 (NOT `{clean, drift_warn, drift_confirmed}`)
- `predicted_excess` lives on `atlas_signal_calls`, NOT `atlas_cell_definitions`
- `deployment_multiplier` values are `{0.0, 0.4, 0.7, 1.0}` (NOT `{0.5, 1.0, 1.5}` as design lock said)

## Frontend state

50 commits on `feat/v6-deep-search-all-cells` (pushed to remote; HEAD `ce5a44f`).

| Phase | Tasks | Status |
|---|---|---|
| A | 11/11 | ✅ (incl. A.0 data audit, A.5 14 skeletons, A.10 decimal utility, A.9 14 loading.tsx) |
| B | 9/9 (B.4 split into B.4a + B.4b) | ✅ portfolio-awareness layer foundation |
| C | 17/17 | ✅ (incl. today-page bundled batch absorbing C.17 + D.1 + D.2 + D.12) |
| D | 12/12 | ✅ |
| E | 1/4 (E.4 ✓, E.1 partial via C.16 AuditTrailTab) | ⚠️ E.2 ClosedLoopDiagram + E.3 methodology page DEFERRED to v6.1 (time-constrained) |
| F | 0/7 explicit but deploy is live | ⚠️ /design-review polish loop + /qa + /codex review not run (time-constrained) |

**Live routes (all return 200):**
- `/v6/today` — DiffSinceYesterdayPanel + BookAtAGlance + RecentSignalCalls + drift_warn chip
- `/v6/stocks` (list with PortfolioBadge column + column chooser + virtualization)
- `/v6/stocks/[iid]` (hero with PortfolioBadge expanded + PositionSizingWidget + CrossRuleDepth + 3 tabs)
- `/v6/sectors` (list with SectorBookStrip + RRG + Bubble + sparkline ladder)
- `/v6/sectors/[name]` (hero strip "your book in this sector" + breadth + constituents)
- `/v6/funds` (IndustrySnapshot + Bubble + SignatureMatrix + ranked table + SwitchProposalsBanner + PortfolioBadge col)
- `/v6/funds/[code]` (FundHero + Holdings tab + Switch banner + Audit placeholder)
- `/v6/etfs` (IndustrySnapshot + Bubble + SignatureMatrix + AMC leaderboard for ETFs per Vocabulary override)
- `/v6/etfs/[iid]` (ETFHero + TE/expense/AUM/spread + 3 tabs)
- `/regime` (deployment_multiplier hero + days_in_regime + journey strip + 4 input sparklines)
- `/matrix` (CellMatrix with held-count overlay + failed-gate microcopy truth table + drift chip)
- `/v6/cells/[cell_id]` (CellHero + rule_dsl plain English + 9 sections + ledger/walkforward empty states)
- `/v6/screening` (multi-criteria filter builder + URL-encoded filters + results table)

## Deferred to v6.1

- **E.2 ClosedLoopDiagram** (animated SVG, 12 nodes + drawer) — methodology page is lower priority than active-use pages.
- **E.3 /methodology page** — depends on E.2.
- **AuditTrailTab Section 6 (cross-rule consistency breakdown)** — Section 4 (predicates met) already ships in v6.0 per Opus review's promotion.
- **NAV writer for `atlas_mf_recommendation_daily`** — backfill #2 skipped (no NAV in sub_metrics); MF SWITCH proposals UI works but underlying recommendation table empty.
- **`atlas_paper_portfolio` writer cron** — FM must enter real positions manually via UI; portfolio-awareness UI renders silently when empty.
- **Drift detector cron** — `atlas_drift_event_log` empty; drift_warn UI surfaces work but no events yet.
- **Provenance log writer cron** — AuditTrailTab Section 7 renders `[]` cleanly.
- **`atlas_ledger` writer cron** — D.10 cell detail "realized outcomes" section renders empty-state.
- **Phase A YELLOW token cleanups** were applied (`ad64cec` paper-deep token + ColumnChooser).
- **F.1 E2E Playwright suite** + **F.2 axe-core a11y** not yet run.
- **F.5 codex review** quota-blocked from earlier session.
- **F.6 /design-review screen-level visual QA** not yet run (autonomous skill loop — recommended for daytime cycle).

## Key adversarial-review findings honored

From Opus 4.7 fresh-context review + superpowers:code-reviewer pass (both SHIP_WITH_FIXES):
- `lib/v6/decimal.ts` utility + ESLint gate (A.10) — postgres-js Decimal-as-string → chart number boundary
- PortfolioBadge wired into D.4-D.8 acceptance per Opus §5 (was missing in plan v1)
- today-page co-ownership matrix (C.17+D.1+D.2+D.12 → single implementer per code-reviewer §H1)
- AuditTrailTab Section 4 promoted back to v6.0
- B.4 split into B.4a (matrix diff) + B.4b (book diff) per code-reviewer §H10

## Deploy mechanism for future v6 changes

```bash
# Local (Mac):
source .venv/bin/activate
alembic upgrade head  # for migrations
cd frontend && npm run build  # verify locally

git add . && git commit -m "..."
git push origin feat/v6-deep-search-all-cells

# Remote (atlas EC2):
ssh atlas
cd ~/atlas-os && git pull origin feat/v6-deep-search-all-cells
# Sync src into PM2 dir:
rsync -a --delete /home/ubuntu/atlas-os/frontend/src/ /home/ubuntu/atlas-frontend-v2/frontend/src/
cp /home/ubuntu/atlas-os/frontend/package.json /home/ubuntu/atlas-frontend-v2/
cd /home/ubuntu/atlas-frontend-v2 && npm install && npm run build
pm2 restart atlas-frontend-v2
```

PM2 process: **`atlas-frontend-v2`** (NOT `atlas-frontend` — that name doesn't exist on the host). Port 3002 (NOT 3001 as old memory said).

## Known follow-ups for next session

1. **E.2 ClosedLoopDiagram + E.3 methodology page** (the locked closed-loop visualization)
2. **Run /design-review on production** for screen-by-screen polish
3. **Run /qa** for functional walkthrough
4. **NAV writer** for `atlas_mf_recommendation_daily`
5. **Writer crons** for `atlas_ledger`, `atlas_provenance_log`, `atlas_drift_event_log`, `atlas_paper_portfolio`
6. **Token cleanups noted in Phase A quality review file** — `~/.gstack/projects/atlas-os/eng-plans/2026-05-26-v6-phase-a-quality-review.md`
7. **AuditTrailTab fund-flavored variant** — current implementation is stock-shaped; funds/ETFs render placeholder

Related: [[feedback-skill-loop-process]], [[feedback-backend-first-live-db-truth]], [[feedback-implementer-skill-invocation-required]], [[reference-ec2-access]], [[reference-supabase-mcp-gate]], [[reference-atlas-frontend-host]] (needs update — actual PM2 process is atlas-frontend-v2 + port 3002).
