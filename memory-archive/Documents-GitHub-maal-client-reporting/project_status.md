---
name: CPP Project Status
description: Current state of Client Portfolio Portal — what's deployed, what's pending, key decisions made
type: project
---

## Deployed & Working (as of 2026-03-26)
- Full dashboard with 11 sections on clients.jslwealth.in
- Admin panel with aggregate analytics (composite index, Nifty-equivalent, allocation, monthly returns)
- Admin: top 5 by CAGR, top 5 by NAV, top 5 by invested capital
- Cash flow ingestion: cpp_cash_flows table, all 6 files uploaded (1,050 rows, 0 failures)
- XIRR from real cash flows (not corpus-change inference)
- Nifty benchmark cash-flow-adjusted (virtual units method)
- Aggregate Nifty line simulates actual client inflows/outflows
- 5-min TTL cache on aggregate endpoints (was 13-18s, now <0.05s cached)
- SQL CTE with window functions for AUM-weighted composite returns
- SSL + Nginx, Docker container on port 8007
- Admin: admin / admin123

## Security Fixes Deployed (2026-03-26)
- Risk-free rate corrected 7.00% → 6.50% across all services
- SameSite cookie hardened lax → strict (auth, admin impersonate)
- CAGR start value uses actual TWR start (was hardcoded 100.0)
- Error details no longer leaked in admin_aggregate.py responses
- Sharpe/Sortino/Beta/Correlation: zero-vol guards prevent sentinel values (-99999999)
- Monthly returns: 0% months no longer counted as losses

## Full Risk Recompute In Progress
- All ~350 clients being recomputed with corrected 6.50% rate and zero-vol guards
- 7 zero-vol clients (40, 113, 114, 261, 269, 334, 341) confirmed fixed

## Pending Tasks — Next Session
1. **Frontend fixes from audit**: AllocationBar silent failure, duplicate /auth/me call, double risk-scorecard fetch
2. **Dead code cleanup**: Remove MethodologyAccordion.jsx (unused), date-fns dependency
3. **Migrate to next/font**: Replace CSS @import of Inter with next/font/google
4. **File size compliance**: Split admin.py (588 lines) and aggregate_service.py (630 lines)
5. **Unbounded queries**: Add LIMIT to nav-series and drawdown-series endpoints
6. **Password validation**: Add min_length check on change-password endpoint
7. **Session commit patterns**: Review flush vs commit usage

## Key Architecture Notes
- RDS password: Nimish1234 (use server .env, not CLAUDE.md template)
- TWR series computed on-the-fly (not stored in DB) — compute_twr_series() in risk_metrics.py
- Cash flow map: cpp_cash_flows first, falls back to corpus-change detection
- Risk recompute takes ~2-3 min for 350 clients — run via docker exec, not through Next.js proxy
- Container race condition on restart — health check may fail on first try, succeeds after 10-15s
- Aggregate cache: _CACHE_TTL = 300s in aggregate_service.py
- Zero-vol clients (100% cash): all risk ratios return 0.0 (guard threshold 1e-10)
