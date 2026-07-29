---
name: SP01 Signal Validation Lab — first run result
description: IC measurement on decision_state composite (v1 hand-set encoding). First-run numbers + verdict against SP01 success criteria. Failed all four — drives SP04 redesign.
type: project
originSessionId: b03c7f67-fe54-4643-8fc6-c6dce97c8b0f
---
**Ran:** 2026-05-12 on EC2 (full data: 2025-03-01 → 2026-05-08, last 6M rolling window)
**Signal:** decision_state (v1 hand-set weights — see `atlas/intelligence/validation/encoding.py`)
**Rolling window:** 6M (126 trading days)
**As-of:** 2026-01-09 (slid back by max_period=63 for lookahead room)
**N stocks in factor:** 170,035 rows after sentinel drop
**Storage:** `atlas.atlas_signal_ic` table, rows for periods 5/21/63 d on 2026-01-09

## Results (first run, v1 composite)

| Period | Mean IC | t-stat | Q-spread (ann) | Turnover/mo | N obs | Verdict |
|---|---|---|---|---|---|---|
| 5d  | -0.0026 | -0.44 | -13.0% | 547% | 126 | FAIL ✗ |
| 21d |  0.0090 |  1.27 |   5.1% | 547% | 126 | FAIL ✗ ← gate |
| 63d |  0.0142 |  1.63 |   4.3% | 547% | 124 | FAIL ✗ |

## Interpretation

**The v1 hand-set composite has near-zero predictive power on Indian equities over the most recent 6 months.** All four SP01 success criteria fail on the 21d gate:
- Mean IC of 0.009 ≪ 0.05 threshold
- t-stat of 1.27 ≪ 2.0 (not statistically distinguishable from noise)
- Q-spread of 5.1% < 8% (marginal even if directionally correct)
- Monthly turnover of 547% — entire top quintile turns over every ~5 days

Why this is not unexpected:
1. The composite encodes 6 categorical state dimensions with hand-set linear weights. The state transitions (Leader→Strong→Consolidating→Emerging→Average→Weak→Laggard) are not necessarily linear in forward return.
2. The 547% turnover suggests state flips dominate the composite — daily state churn causes daily quintile churn. SP04 multi-timeframe confluence (require 3m AND 6m AND 12m alignment) should slash this dramatically.
3. The universe is unfiltered (includes illiquid stocks, ETFs, suspended issues). A liquid-only subset would likely improve IC.

## What SP01 unblocks anyway

The framework now exists and is correct (verified by 3 sanity tests):
- IC engine: PASS (synthetic-signal IC=1.0, randomized-signal IC≈0)
- `atlas.atlas_signal_ic` table: 3 production rows persisted
- Markdown tearsheet generator: working
- CLI orchestrator: working
- Pre-flight gate: validator agent confirms no P0 baseline findings

SP02 (materialized views) and SP03 (OpenBB Copilot) do NOT depend on SP01 passing the IC bar — only on the measurement framework existing. They proceed.

**SP04 must NOT start before re-thinking the composite design.** SP04 was supposed to derive IC-weighted composites from this table; with all weights failing the gate, derivation gives garbage. Required SP04 pivot:
1. Filter universe to liquid stocks only (top 500 by ADV)
2. Add multi-timeframe confluence as a primary signal
3. Re-encode states using historical base rates per state, not hand-set scores
4. Re-run SP01 on the new composite; iterate

**How to apply:** When opening SP04, the first decision is the composite redesign (above 4 items). Don't try to fix the v1 encoding weights — replace the whole approach.

## Commits

- `e12740c` deps + module boundaries
- `354a985` migration 033 (atlas_signal_ic)
- `0ad24bc` state encoding
- `bf90914` factor loader
- `ae45b7a` forward returns loader
- `5f686a0` IC engine
- `5a7577a` persistence
- `85ca88c` markdown report
- `8d77ec1` CLI orchestrator
- `b5ec756` 3 sanity tests
- `f982b11` load-range trim (perf fix)
- `c9d4f7e` instrument_id text cast + window lookahead room
- `97e2c99` np.float64 → float coercion at persistence boundary

EC2: migration 033 applied. Tearsheet at `/home/ubuntu/atlas-os/output/validation/decision_state_2026-05-12.md`.
