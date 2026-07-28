---
name: fix_regime_metrics_wip
description: WIP — fixing per-regime benchmark/excess metrics in simulator and lab extraction
type: project
---

## Status: IN PROGRESS (2026-03-24)

### What's Done
- Added `benchmark_cagr`, `benchmark_max_dd`, `excess_cagr`, `excess_calmar` fields to `RegimeMetrics` dataclass + `to_dict()` in `compass_simulator.py`

### What Remains (3 changes)

#### 1. compass_simulator.py — Compute per-regime benchmark metrics (~line 800)
After the existing `regime_nav` computation block (line 801-810), add benchmark computation using the same `regime_mask`:

```python
# Per-regime benchmark metrics
bench_slice_start = start_day  # benchmark array is full-length, nav starts at start_day
regime_bench_indices = regime_nav_indices  # same day indices
if len(regime_bench_indices) > 10:
    # benchmark array aligns with nav_values (both start at start_day)
    regime_bench = benchmark[start_day:][regime_bench_indices]
    if len(regime_bench) > 1 and regime_bench[0] > 0 and regime_bench[-1] > 0:
        b_years = len(regime_bench) / 252
        rm.benchmark_cagr = float((regime_bench[-1] / regime_bench[0]) ** (1 / b_years) - 1) * 100
        b_peak = np.maximum.accumulate(regime_bench)
        b_dd = (b_peak - regime_bench) / b_peak * 100
        rm.benchmark_max_dd = float(np.max(b_dd))
    rm.excess_cagr = rm.cagr - rm.benchmark_cagr
    excess_dd = rm.max_drawdown - rm.benchmark_max_dd
    denom = max(excess_dd, 1.0)
    rm.excess_calmar = rm.excess_cagr / denom if rm.excess_cagr != 0 else 0.0
```

NOTE: `benchmark` array is full n_days length. `nav_values` starts at `start_day`. `regime_days_arr` aligns with `nav_values`. So `regime_nav_indices` index into both `nav_arr` and `benchmark[start_day:]`.

#### 2. compass_lab.py — Fix extract_regime_configs (~line 267)
Change lines 291-295 to pull from per-regime `rm` instead of full-period `r`:
```python
"excess_cagr": rm.get("excess_cagr", 0),       # was r.get(...)
"excess_max_dd": rm.get("excess_max_dd", 0),     # was r.get(...)  — NOTE: excess_max_dd not in RegimeMetrics, use max_drawdown - benchmark_max_dd
"excess_calmar": rm.get("excess_calmar", 0),     # was r.get(...)
"benchmark_cagr": rm.get("benchmark_cagr", 0),   # was r.get(...)
"benchmark_max_dd": rm.get("benchmark_max_dd", 0), # was r.get(...)
```

Also change line 301 sort key from `composite_score` to per-regime `calmar` (or `excess_calmar` once it's per-regime):
```python
candidates.sort(key=lambda x: x["excess_calmar"], reverse=True)
```

#### 3. After deploying — re-trigger sweep
The daemon will auto-run, but manually trigger to get immediate results:
```
curl -s -X POST 'http://localhost:8004/api/compass/lab/sweep/trigger?sweep_type=full'
```

### Root Cause of Bugs
- `extract_regime_configs` mixed full-period metrics (`r.excess_cagr`) with per-regime metrics (`rm.cagr`)
- `RegimeMetrics` had no benchmark/excess fields — only portfolio-side metrics
- Sorting by full-period `composite_score` instead of per-regime performance

### Additional Context
- Data: 4557 days (18y), 19 sectors, cached in Docker volume
- Quick sweep showed benchmark idle + 2_of_3 gates + 6M RS + 4 positions = best full-period config
- But per-regime results will tell a different story — BULL should show sector alpha, BEAR should show defensive value
- The daemon's train/test validation rejects benchmark idle configs (too few test-set trades) — may need to lower min_trades threshold from 20 to 10 for test sets
