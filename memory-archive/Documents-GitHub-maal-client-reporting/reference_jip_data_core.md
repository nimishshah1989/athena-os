---
name: JIP data core — benchmark / OHLCV source of truth
description: Historical NIFTY and stock/ETF OHLCV lives in fie_v3 on the same RDS instance, refreshed daily
type: reference
originSessionId: c07c9e2d-455e-4002-87e4-908221fb8187
---
For historical benchmark and instrument prices, query the JIP data core at
`fie_v3.public.index_prices` (indexes) and the equivalent equities/ETF tables
on the **same RDS instance** as `client_portal`. Reuse `DATABASE_URL_SYNC`
credentials and swap the database name to `fie_v3`.

Key table: `public.index_prices` with `index_name='NIFTY'` gives full daily
history back to 2020-09 (≈2,000 rows). Refreshed every trading day.

**Why:** yfinance is unreliable — during one ingestion window it returned only
a short history, causing most `cpp_nav_series.benchmark_value` rows to be
forward-filled from a single recent close. JIP is the authoritative, always-
current source maintained internally.

**How to apply:** Any new benchmark/price lookup (Nifty, Sensex, Nifty 500,
stock ETFs) should hit JIP first; keep yfinance as fallback only for the rare
case JIP is unreachable. See `backend/services/benchmark_service.py` for the
pattern.
