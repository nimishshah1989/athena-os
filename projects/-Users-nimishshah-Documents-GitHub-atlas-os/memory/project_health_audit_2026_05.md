---
name: Atlas codebase health baseline (2026-05 audit)
description: P0/P1 bugs found and fixed in the 2026-05 pre-build health audit; residual architectural issues still outstanding
type: project
originSessionId: b03c7f67-fe54-4643-8fc6-c6dce97c8b0f
---
Full health audit run 2026-05-11. Four parallel agents reviewed backend arch, frontend, migrations, and compute pipeline.

## P0 fixes applied (all on main)

1. **`atlas/compute/stocks.py` — drawdown_ratio_252 formula wrong** — was storing `-max_drawdown_252` (negated stock drawdown) instead of `stock_dd / bench_dd`. Silent corruption of every stock's risk state for 10 years of backfill.

2. **`atlas/compute/sectors.py` — np.select ordering bug** — `is_overweight` evaluated before `is_underweight`; at threshold edge, conservative state was overridden. Fixed to: Avoid > Underweight > Overweight.

3. **`atlas/compute/benchmarks.py` — vol zero guard missing** — `add_vol_ratio()` divided by benchmark vol with no zero guard → `inf` → every stock classified High risk on holiday runs and early history.

4. **`atlas/db.py` — `load_thresholds()` returned `dict[str, float]`** — systemic float-for-money violation bypassing the Decimal rule. Fixed to return `dict[str, Decimal]`. All 15 compute callers updated to `Mapping[str, Decimal]`. Arithmetic with floats fixed via `float(thresholds["key"])` cast.

5. **`atlas/health/freshness.py` + 8 other files — blanket S608 suppression** — global SQL injection linter suppression removed from pyproject.toml; per-line `# noqa: S608` with justification added to all 9 existing SQL f-string sites.

6. **`atlas/compute/regime.py` — VIX NaN guard wrong** — `no_inputs = pct_50.isna() & vix.isna() & close.isna()` (all-AND) meant isolated VIX gaps silently forced wrong regime. Fixed: per-condition `vix_valid` guard; null-out only when price + breadth both absent.

7. **`atlas/compute/sectors.py` — participation_rs formula wrong** — used `rs_1m_tier > 0` proxy instead of methodology §10.4's `rs_state ∈ {Leader, Strong, Emerging}`. Fixed to use the rs_state column (which IS loaded from the DB).

8. **`atlas/compute/lens_nav.py` — NAV gaps silently filled** — `fillna(0)` on missing NAV treated gaps as zero-return days. Fixed: log gap count + `ffill()` with warning before any computation.

## P1 fixes applied

- `frontend/src/lib/queries/regime.ts` — `SELECT *` on 30-column regime table replaced with explicit column list
- `frontend/src/app/stocks/page.tsx` + `etfs/page.tsx` — `parseFloat()` on Decimal replaced with `Number()`
- `frontend/src/components/funds/FundLens2.tsx` + `FundLens3.tsx` — non-null assertions on nullable fields replaced with optional chaining
- `atlas/preflight.py`, `atlas/validation/m1_data_quality.py`, `atlas/compute/regime.py` — `# allow-large: <reason>` comments added
- `migrations/versions/029_add_missing_indexes.py` — indexes added for `atlas_universe_funds.benchmark_code` and `atlas_universe_etfs.benchmark_code`

## P1 fixes applied (cont.)

- **Migration 030** — `updated_at` added to `atlas_run_log`; `created_at` + `updated_at` added to `atlas_pipeline_runs`. `runs.py finish_run()` now sets `updated_at = ended_at` explicitly on status-transition UPDATE.
- **ETF `volume_state`** — confirmed PRESENT in migration 005 (`VARCHAR(32)` nullable); review agent false positive. No action needed.

## P1 architectural fixes applied (commit e2a1d9f)

- **Auth middleware** — `atlas/api/auth.py`: Supabase HS256 JWT middleware. Verifies Bearer tokens; sets `request.state.user`. `ATLAS_AUTH_DISABLED=true` for local dev. `pyjwt>=2.8` added to deps.
- **Fake 202** — `strategies.py` now inserts `status='queued'` (not 'running'). Concurrency guard checks both `queued` + `running`. Migration 031 adds 'queued' to the constraint.
- **Cross-context imports** — `atlas/simulation/custom/__init__.py` now re-exports `InstrumentWeight` + `create_custom_portfolio`. `portfolios.py` imports via public surfaces only.

## Post-audit P0 fixes (2026-05-14)

9. **`atlas/compute/sectors.py` — participation_rs absolute threshold instead of cross-sector percentile rank** — `compute_sector_states` compared raw `participation_rs` against an absolute threshold. Because participation_rs is not normalized, all sectors fell below the cutoff from Jan 2026 onward → all sectors Underweight/Avoid → all funds Misaligned → all decisions Reduce/Exit. Fixed by adding `p_rs_rank = out.groupby("date")["participation_rs"].rank(pct=True)` and using the percentile rank in state classification. Commit `c663127`.

10. **`atlas/compute/lens_nav.py` — `classify_nav_state` divided rs_quintile thresholds by 100 twice** — Thresholds `rs_quintile_top` and `rs_quintile_bottom` are stored as fractions (0.80, 0.20) in `atlas_thresholds`, but the code applied an additional `/100` divide, making effective cutoffs 0.008 and 0.002. Result: 527/531 funds classified as Leader NAV. Fixed by removing the erroneous `/100` and updating `DEFAULT_THRESHOLDS` in tests to fraction form. Commit `35c1453`.

## All P0/P1 issues resolved

The 2026-05 health audit is fully closed. Baseline tag: `health-audit-baseline-2026-05` (commit 1e97c72). Subsequent fixes at commits babd50e, e2a1d9f, c663127, 35c1453.

**Why:** These require design decisions (auth provider config, subprocess approach, simulation API surface) before coding.
**How to apply:** Flag these in any sprint planning for M6+. Auth middleware is P0 before exposing any API externally.

## Audit completion status

**Committed:** 2026-05-11 as commit `1e97c72` on main.
**Baseline tag:** `health-audit-baseline-2026-05`
**All pre-commit hooks pass** (ruff, ruff-format, mypy, secrets, pragma-coverage, chain-integrity, file-size, module-boundaries, thresholds).
