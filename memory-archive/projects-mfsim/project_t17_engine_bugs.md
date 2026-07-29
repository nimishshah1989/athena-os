---
name: T17 Engine Bug Fixes
description: Fixed lumpsum total_invested double-counting and SIP idle cash bugs in backtest engine
type: project
---

Two engine bugs fixed on 2026-04-04:

BUG 1 — Lumpsum total_invested: Old code computed deploy_amount from months_elapsed_in_year on each trigger, double-counting when multiple triggers fired in the same year. Fixed to deploy months since LAST trigger (not year start), capped at pool balance. Initial and final year budgets pro-rated.

BUG 2 — SIP idle cash: Year reset added full 120000 on Jan 1 of final year; undeployed budget inflated total_value. Fixed: non-liquid SIP strategies zero idle cash at period end (unused budget ≠ value). Final year budget pro-rated.

**How to apply:** backtest_engine.py lumpsum section uses `months_to_deploy` from last trigger date with `min(deploy_amount, available)` cap. FINAL VALUES section zeros idle cash for non-liquid non-lumpsum strategies.
