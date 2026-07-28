---
name: ISIN-first price resolution system
description: Architecture of the ISIN→NSE ticker resolution pipeline and known corporate actions to watch for
type: project
originSessionId: ef4f6fa6-37dd-4ac1-ba81-e306eddc919f
---
# ISIN-First Price Resolution

**Why:** Backoffice script names are unreliable (company names, old tickers, renamed instruments). ISINs are stable.

**How to apply:** When prices fail or symbols look wrong, check isin_resolver.py and _SYMBOL_OVERRIDES first.

## Architecture

- `isin_resolver.py` — In-process cache (ISIN → "TICKER.NS"). Seeds from `cpp_transactions` at startup, falls back to Yahoo Finance search API for unknowns.
- `live_prices.py` — Path A (ISIN-first) + Path B (symbol-based fallback for no-ISIN records).
- `txn_parser.py` — `_SYMBOL_OVERRIDES` dict: canonical overrides applied at parse time AND inside `isin_resolver` cache for stale YF data.

## Key design decisions

- `seed_cache_from_db` has `_SEEDED` guard — runs once per process, then no-ops (no repeated DB queries).
- `_SYMBOL_OVERRIDES` is applied inside `isin_resolver` at both the DB-seed step and the Yahoo Finance step — so stale YF tickers for merged companies get corrected at the cache level.
- `_UNRESOLVABLE_SYMBOLS` in `live_prices.py`: GDL (delisted 2023), TINPLATE (merged into Tata Steel).

## 2026-04-16 Corporate Actions (all happened same day)

| Old ticker | New ticker | Company |
|---|---|---|
| TATAMOTORS | TMPV | Tata Motors → Tata Motors Passenger Vehicles |
| ZOMATO / ZOMATOLIMITED | ETERNAL | Zomato → Eternal Limited |
| HIL | BIRLANU | HIL Limited → BirlaNu Limited |
| SWANENERGY | SWANCORP | Swan Energy → Swan Corp Limited |

**Why:** All effective 2026-04-16. Watch for similar batches — Indian companies sometimes do coordinated restructurings.

## Other known overrides

- AMARAJABAT → ARE&M (Amara Raja renamed)
- MINDAIND → UNOMINDA (Minda Industries → Uno Minda)
- SUVENPHAR → SUVEN (NSE ticker is SUVEN, not SUVENPHARMA)
- LTI → LTIM (LTI merged with Mindtree)
- ADANITRANS → ADANIENSOL
- PVR → PVRINOX

## When prices fail

1. Check `unpriced_symbols` in the update-prices log
2. Search Yahoo Finance for the ISIN: `httpx.get("https://query1.finance.yahoo.com/v1/finance/search?q={ISIN}")`
3. Check `prevName` and `nameChangeDate` fields — indicates a corporate rename
4. Add the override to `_SYMBOL_OVERRIDES` in `txn_parser.py`
5. isin_resolver will pick it up automatically (no cache invalidation needed — new process seeds fresh)
