---
name: PMS back-office return-label semantics
description: How PMS report columns map to formulas used in risk_engine
type: project
originSessionId: c07c9e2d-455e-4002-87e4-908221fb8187
---
PMS back-office HTML reports (the reconciliation ground truth) show two
inception-level return columns side by side. Mapping in our code:

- **"Absolute Return %"** = `(current_value − net_contribution) / net_contribution × 100`
  → stored as `absolute_return_simple`. This is the committed-capital ratio.
- **"Adjusted Return [Weighted] %"** = `profit / time_weighted_average_corpus × 100`
  (Simple Dietz). The denominator is `Σ (corpus_t × Δdays_t) / total_days`.
  → stored as `absolute_return` (the primary field). Implemented via
  `compute_weighted_avg_corpus` in `backend/services/risk_metrics.py`.

**Why:** Verified against 5 reference clients (BJ53, DP489, EL53, EL53MF,
JR98) on 22-Apr-2026 reports. For EL53 (constant corpus), both formulas
match to 4 decimals. For multi-corpus clients (BJ53, JR98), our computed
values match PMS within ~1-2 %; residual gap is a one-trading-day mismatch
(PMS report 22-Apr vs our last NAV 21-Apr).

**How to apply:** When new metrics or periods are added, keep these two as
distinct fields. The methodology page must show both labels — clients see
PMS statements and expect the same vocabulary. XIRR is the third client-
specific return; `cpp_cash_flows` is derived from NAV corpus deltas during
ingestion.

**Known limitation:** The PMS "Nifty [Weighted]" figure depends on PMS's own
cash-flow event log, which has slightly different dates/amounts than the
corpus-delta events we derive from `cpp_nav_series`. For constant-corpus
clients our virtual-units weighted benchmark matches PMS to 3 decimals; for
multi-flow clients the two diverge. Not a formula bug.
