---
name: project-signal-discovery-2026-05
description: Active signal discovery thread on atlas-os-consolidation; 9 experiments produced Sharpe 1.33 / Jensen alpha 27% / 6 validated per-(tier×stage) sub-states; methodology locked 2026-05-23 (evening rev)
metadata: 
  node_type: memory
  type: project
  originSessionId: 2ff217a8-ee34-4358-b1a3-6ac996e1cccf
---

Active research thread on Atlas signal discovery. After 5 sequential
pre-registered experiments, we have the first validated price+volume-only
edge across v1-v6: top-decile `rs_residual_6m` AND lower-half liquidity AND
lower-half realised vol delivers +7.1pp OOS uplift over the top-RS baseline
(walk-forward 3 windows, pooled hit 62.7% / median 6m excess +8.33%).

**Why:** v1-v5 shipped on aesthetic plausibility — pretty states, no
validated edge. The 2026-05 reframe replaced "describe the state, then
trade it" with "pre-register the bar, measure on real data, read honestly".
This is the first methodology that produced a defensible OOS result.

**How to apply:**
- Methodology lock is `docs/atlas-signal-discovery/methodology-lock-2026-05-23.md` — read before any new experiment in this thread; includes Exp 1-7 + adjusted-data update
- Working repo: `atlas-os-consolidation` (NOT `atlas-os`)
- All audits live in `atlas-os-consolidation/docs/audits/rs-*.md` (prefer the `-adjusted-2026-05.md` files for current numbers; the older files are superseded but kept for reference)
- All scripts in `atlas-os-consolidation/scripts/rs_*.py`
- Run on EC2 (`atlas` SSH alias); OHLCV cache at `/tmp/sde_ohlcv_cache.pkl` (now built on close_adj), Nifty 500 cache at `/tmp/nifty500_cache.pkl`, top-RS feature panel at `/tmp/rs_fp_feature_panel.csv`, instrument blacklist at `/tmp/iid_blacklist.json`
- DATA: ALWAYS use `de_equity_ohlcv.close_adj` (corp-action adjusted), NEVER raw `close`. Universe is 727 instruments (Atlas M1 750 minus 23 blacklisted iids with unadjusted merger/demerger/face-value anomalies — SAMMAANCAP, POONAWALLA, SHRIRAMFIN, M&MFIN, NTPC, IFCI, PFC, NHPC, SBIN, ZEEL, HUDCO, JSWSTEEL, IDFCFIRSTB, IREDA, MUTHOOTFIN, IIFL, TATASTEEL, IRFC, MANAPPURAM, VEDL, CREDITACC, YESBANK, IDEA — production restore requires fixing atlas_compute_adjustments.py to handle merger/demerger events)
- Locked elements: rs_residual_6m as RS variant; NIFTY 500 as benchmark; ≥273-day history + ₹5cr liquidity universe; 6m forward horizon; Method A (training-derived absolute thresholds) for filter deployment; filter = top-RS AND log_med_tv_60d ≤ median AND dd_from_52w_high ≥ median AND realised_vol_60d ≤ median
- Risk-adjusted result (OOS 2022-2025, on ADJUSTED data): **Sharpe 1.33, CAGR 39.95%, Jensen alpha +27.33%, beta 0.74, max DD -13.97%** (BETTER than benchmark's -16.45%). Strategy is genuine risk-adjusted alpha. Cap-tier distribution uniform (NOT small-cap concentrated). Sector HHI 0.228 (Infrastructure top in 9/36 months).
- OOS walk-forward (adjusted): pooled hit 65.7%, uplift +10.1pp over baseline, median excess +9.55%
- DEAD ends: raw close (use close_adj); synthetic equal-weight benchmark; cross-sectional rank for filter thresholds (use training-derived absolute values); orthogonal signal overlays (volume/lowvol/trend collinear with RS); ±50% per-position cap (was workaround for raw-data; no longer needed)
- Risk management belongs in TRADING phase, not signal-discovery — per user: "Risk Management is in trading, those stop-loss risk per trade, etc., will be implemented during the trading part". State definition is descriptive only
- Principles earned: read median not mean; test uplift not absolute; family robustness; no architecture until 3+ friction; every experiment reports risk-adjusted metrics; sample-of-one is sample-of-one; DATA FOUNDATION FIRST — verify close_adj before any analysis; separate state-definition from risk-management
- Stage 4 Avoid state VALIDATED (2026-05-23): bot-RS + recent_listing + heavy_distribution + high_liquidity → 64.3% continued-avoid rate, -9.26% median 6m excess. Different feature signature from Stage 2 (asymmetric — liquidity flips, listing age flips, up_down_vol matters only in Stage 4, vol matters only in Stage 2). Audit: docs/audits/rs-stage4-avoid-characterization-2026-05.md
- KEY PLATFORM INSIGHT (asymmetry): state library must support per-state feature definitions, NOT one quality axis with two endpoints. Up-trends and down-trends are different phenomena. Stage 2 = "small-cap quality momentum"; Stage 4 = "large-cap structural decline"
- Next experiments (queue): walk-forward validate Stage 4 (mirror of Exp 5); Sector state (using de_index_prices); Composite instrument view rendering for one stock (now have 2 states to compose); portfolio simulation using BOTH states (Stage 2 long + Stage 4 exclusion); then maybe Regime state (as context); fix atlas_compute_adjustments.py to handle merger/demerger events so 23 blacklisted stocks can be restored
- TIER ARCHITECTURE DECISION (2026-05-23, Tests B + A): per-(tier × stage) state definitions are canonical. Tier-relative features cannot replace tier-specific models (abs-only filter 68.5% TP beats rel-only 53.8% beats mixed 60.0%). Stage 2 baseline TP rate is 47% Large / 47% Mid / 57% Small — full-universe 52% was an average masking huge variation. Each tier uses different best features. Six sub-states: {Small,Mid,Large} × {Stage 2 Healthy, Stage 4 Confirmed Avoid}. Strongest: Small Stage 2 (66.2% TP, +10.7%) and Mid Stage 4 (68.1% TN, -12.0%). Audits: rs-tier-stage-characterization-2026-05.md, rs-tier-relative-features-2026-05.md
- New best in-sample full-universe filter (Test A): top-RS + log_med_tv ≤ med + dd_from_52w_high ≥ med + log_price ≤ med → 68.5% TP, +14.2% median 6m excess. log_price was the missing third feature
- Principle #14 (NEW): cap tier is genuine economic structure, not noise to normalize. Don't normalize without testing first
- Principle #15 (NEW): state definitions can require per-(tier × stage) feature sets. Each cell earns its own informative features.
- VALIDATION PASS COMPLETE (2026-05-23): 7/7 checks pass. Cache integrity, forward returns, decile assignment, look-ahead bias, tier assignment, feature sanity, production cross-check all confirmed. Look-ahead check found ZERO difference between full-panel and truncated-to-T recompute (582 instruments tested). Production cross-check: research ret_6m matches atlas.atlas_stock_metrics_daily.ret_6m to 0.001% rel-diff for 4/5 stocks; 1 stock diverges (research +80.9% vs production +74.1%) but explained by our (more correct) use of close_adj across a CA event. Audit: docs/audits/rs-validation-pass-2026-05.md. Foundation is sound; safe to proceed to Phase 2 (Stage 1 + Stage 3).
- PHASE 2 COMPLETE (2026-05-23): Stage 1 Emerging + Stage 3 Topping characterized × 3 tiers. ASYMMETRIC MATRIX FINDING: only 7-8 of 12 cells are deployable. Stage 1 (ACCUMULATE) DOES NOT WORK — baseline TP 44-46% across tiers, filter only lifts to 48-53%. Most "emerging from below" patterns are dead-cat bounces. Stage 3 (TRIM) partially works — Large 59.5% TN ✓, Mid 57.7% marginal, Small 51% weak. Stage 2 + Stage 4 remain the strongest states (59-66% TP, 60-68% TN). Audit: docs/audits/rs-phase2-stage1-stage3-2026-05.md
- Principle #16 (NEW): Not every conceptual state has empirical signal. The discovery methodology will tell us where edge IS and where it ISN'T. Stage 1 doesn't earn the same confidence as Stage 2/4 in this data. Honesty is the asset.
- Current deployable state library: 8 cells (Stage 2 × 3 tiers + Stage 4 × 3 tiers + Stage 3 Large + Stage 3 Mid as marginal). 4 cells not deployable (Stage 1 × 3 + Stage 3 Small). Stage 1 needs alternative definition or accept ACCUMULATE isn't a model-driven action.
- PHASE 3 WALK-FORWARD COMPLETE (2026-05-23): Strict OOS validation shrunk the deployable library from 8-12 in-sample cells to **3 strong + 1 marginal OOS-validated cells**. STRONG: Mid Stage 2 Healthy (65.7% TP, +10.5% excess), Mid Stage 4 Avoid (65.4% TN, -11.3% excess), Small Stage 4 Avoid (73.3% TN, -10.6% excess but small n). MARGINAL: Small Stage 2 Healthy (65.6% TP but only +2pp uplift). SOFTENED to coin flip OOS: Large Stage 2, Large Stage 4. FAILED: all Stage 3 (Small was anti-predictive!), all Stage 1. KEY INSIGHT: Mid-cap is the sweet spot — clean separation between healthy momentum and structural decline. Large-cap is too efficient (no edge OOS). Audit: docs/audits/rs-phase3-walk-forward-2026-05.md
- Principle #17 (NEW): OOS rules absolute. In-sample suggests, OOS decides. Even 60-66% in-sample TP cells can soften to coin-flip OOS (Large Stage 2: 60.7% → 54.9%).
- DEPLOYMENT-READY MODEL: BUY = Mid Stage 2 Healthy + (with caveats) Small Stage 2 Healthy. AVOID = Mid Stage 4 + Small Stage 4. Large-cap = neutral (no model signal). ACCUMULATE/TRIM = not deployable.
- PHASE 3B (GOLD-STANDARD walk-forward, features re-picked per window) — final baseline framework: ONLY 3 deployable cells. STRONG AVOID: Mid Stage 4 (62.0% TN, +7.8pp, -7.61% excess) and Large Stage 4 (61.5% TN, +8.0pp, -3.07% excess). MODERATE BUY: Mid Stage 2 (54.4% TP, +4.4pp uplift; regime-dependent). UNFILTERED BUY: Small-cap raw top-decile RS (63.6% TP, +8.30% excess — no filter needed). Phase 3a's Small Stage 4 (73.3%) was spurious; gold WF gives 48.9%. Phase 3a's Mid Stage 2 (+15.7pp) was inflated; gold WF gives +4.4pp.
- KEY ASYMMETRY FINDING: Failures have STABLE feature signatures across regimes (high vol, recent IPOs, distribution patterns); wins are DIVERSE and regime-specific. AVOID signals validate reliably; BUY signals validate only marginally or require unfiltered RS baseline.
- Principle #18 (NEW): Buy signals are diverse and regime-dependent; sell signals are stable and universal. AVOID can be deployed with high confidence; BUY requires either a robust unfiltered signal or comes with caveats.
- Audit (Phase 3b): docs/audits/rs-phase3b-full-walk-forward-2026-05.md
- FINAL SHIPPED FRAMEWORK: Small tier — top-RS raw rank for BUY, no AVOID signal. Mid tier — Stage 2 filter (regime-dependent BUY) + Stage 4 filter for AVOID. Large tier — no BUY signal (filter anti-predictive), Stage 4 filter for AVOID. ACCUMULATE and TRIM as state actions: NOT AVAILABLE in this model.
- PHASE 3C (Expanded 24-feature space, gold WF) — added 9 new features. ONLY 1 RESCUED a cell: `rs_acceleration_63d` (Δ RS percentile over 63d) → Stage 2 Small went from +0.1pp (noise) to +3.6pp uplift, 67.2% TP, +8.12% median excess. The other 8 new features (rs_3m, rs_12m, rs_alignment, rs_persistent, trend_slope, trend_r2, higher_highs, market_regime) didn't add stable signal to any cells. Adding features WORSENED cells with no underlying signal (Stage 2 Large: -2.7pp → -13.1pp; Stage 3 Large: +2.5pp → -8.2pp; Stage 4 Small: +2.9pp → -7.6pp) — overfitting evidence confirming those cells have no real signal. Audit: docs/audits/rs-phase3c-expanded-features-2026-05.md
- NEW METHODOLOGY INSIGHT: rs_acceleration_63d direction is "<=median" for Stage 2 Small — top-RS small-caps where RS has STABILIZED outperform those still accelerating. This is the "momentum crash" effect (peak-momentum reverts).
- COMPREHENSIVE FINAL FRAMEWORK (after 3 walk-forward phases + 24 features): 4 deployable cells: Stage 4 Mid AVOID (62.0% TN), Stage 4 Large AVOID (62.1% TN), Stage 2 Small Healthy + rs_acceleration_63d (67.2% TP), Stage 2 Mid Healthy (regime-dependent 53.4% TP). Plus unfiltered Small top-RS (63.6% TP baseline). Confirmed NOT deployable: all Stage 1 cells, all Stage 3 cells, Stage 2 Large, Stage 4 Small.
- DIMINISHING RETURNS observation: 15 features → 24 features rescued 1 cell. Going to 30+ would likely rescue 0-1 more. Marginal return on feature engineering low at current point. Further expansion would need sector-relative features (requires mapping work) or different methodology.
- PHASE 3D (sector-relative features, 29-feature space, overnight 2026-05-24): MIXED. Stage 3 Mid +4.7pp / Stage 4 Mid +2.8pp / Stage 1 Mid +4.2pp IMPROVED, but Stage 4 Large WORSENED from +8.6pp to -8.5pp (sector_dd_from_52w displaced the previously-stable signature). Methodological lesson: indiscriminately adding features to a large feature space (29) can OVERFIT and break validated cells. Sector features useful selectively (good for mean-reversion cells), not as broadcast addition. Audit: docs/audits/rs-phase3d-sector-relative-2026-05.md
- PHASE 3E (BREAKTHROUGH — overnight 2026-05-24): switching forward horizon from 6m to 12m AND switching entry condition from "top-decile RS" to "pullback" (top-half RS + dd_from_52w_high ∈ [-15%,-5%]) DRAMATICALLY EXPANDS the validated state library. Best new state: **Small Pullback 12m at 77.9% TP, +36.52% median excess**. Mid Pullback 12m at 75.2% TP, +29.88% excess. Even Large gets a mild BUY signal (51.7% TP, +1.34% excess). The "institutional buy-the-dip" thesis is validated across all tiers. Audit: docs/audits/rs-phase3e-largecap-meanrev-2026-05.md
- Principle #19 (NEW): forward horizon and entry condition are first-class methodology choices — must test multiple, not just one
- Principle #20 (NEW): mean-reversion (buy the dip in winners) outperforms momentum continuation in this universe. Universal across tiers, not large-cap-specific
- REVISED FINAL state library (6 deployable cells): BUY = Small Pullback 12m (77.9%), Mid Pullback 12m (75.2%), Small top-RS 6m + rs_acceleration_63d (67.2%), Large Pullback 12m (51.7% mild). AVOID = Mid Stage 4 (62.0%), Large Stage 4 (61.5%). The "BUY signals diverse, AVOID stable" asymmetry from Phase 3b no longer holds — pullback BUY signals are more consistent and stronger than Stage 4 AVOID signals once tested with proper horizon + entry condition.
- PHASE 3F (overnight 2026-05-24): R3 + R4 de-risking experiments. R3 pullback parameter sweep confirms robustness across 7 DD ranges × 3 tiers. R4 BREAKTHROUGH: "Severely Broken" AVOID variant (bot-half RS + DD < -25%) at 12m horizon delivers Mid 84.6% TN / -20.92% excess — STRONGEST SIGNAL IN ENTIRE MATRIX. Large variant 61.5% TN / -6.82%. Small AVOID at 12m FAILS (small caps mean-revert from extremes). Audit: docs/audits/rs-phase3f-sweep-and-avoid12m-2026-05.md
- Principle #21 (NEW): Asymmetric mean-reversion across tiers — small caps mean-revert from bottom extremes (don't short at bottom); mid/large severely broken stocks continue to fail (confidently exclude/short)
- Principle #22 (NEW): Parameter sweeps confirm signal vs noise — uplift holding across adjacent parameter ranges = real signal
- FINAL state library (8 deployable cells after Phase 3f): #1 Mid Severely Broken AVOID 12m (84.6% TN, -20.92% excess) ★ STRONGEST, #2 Small Pullback BUY 12m (77.9% TP, +36.52%), #3 Small Pullback alt BUY (76.9% TP, +44% excess), #4 Mid Pullback BUY 12m (75.2% TP, +29.88%), #5 Small top-RS+rs_accel BUY 6m (67.2%), #6 Large Severely Broken AVOID 12m (61.5% TN, -6.82%), #7 Mid Stage 4 AVOID 6m (62.0% TN), #8 Large Stage 4 AVOID 6m (61.5% TN). Framework ready for Phase 4.

This thread is distinct from [[project-atlas-decision-engine]] (which was
about the bot direction) and supersedes [[project-sde-state]] (which was
set aside 2026-05-20). The discovery loop here is the kernel of the
"continuously evolving strategy platform" the user wants to build.

Key open frontier (2026-05-23 evening — current phased plan):
1. **Validation pass (GATE)** — spot-check feature computations, forward returns, tier assignment, decile membership, look-ahead audit; cross-check 3 stocks against production Atlas values. Half day. Everything downstream depends on it.
2. **Complete state matrix** — Stage 1 Emerging + Stage 3 Topping each × 3 tiers (6 more sub-states). 2 days.
3. **Walk-forward all 12 sub-states** — OOS validation gate. 1 day.
4. **Composite instrument view spec** — per-instrument data structure (tier, state, confidence, RS values across timeframes, features, forward expectations). 1 day.
5. **Portfolio simulation framework** — declarative portfolios + walk-forward sim engine. 3 days.
6. **Frontend rebuild (parallel)** — per-instrument view, ranking views, portfolio builder. User wants RS values (1m/3m/6m/12m) preserved as visible tables. 2-3 weeks staged.

Earlier-stated open items now lower priority:
- Regime overlay — proved less impactful than expected (Exp 7 showed DD breaker hurt)
- Sector state — still valuable but lower than completing the tier × stage matrix
- Fix atlas_compute_adjustments.py for merger/demerger events to restore 23 blacklisted iids — separate data-pipeline work, tracked but deferred
