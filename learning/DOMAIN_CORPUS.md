# Domain Corpus — JIP Platform
# Rules that unit tests will NOT catch. Claude reads before any JIP-facing feature.
---
Currency: ₹ symbol (not Rs, not INR). Lakh: ₹2,50,000 not ₹250,000.
NAV: 4 decimal places. Portfolio: 2 decimal places. Score: [0,1] range.
CAS PDF data: never in logs, never in error messages, never in API responses.
Investor behavioral scores: sensitive — no debug logging of individual scores.
SEBI category: authoritative — never override with custom classification.
Min AUM: ₹100cr equity, ₹500cr debt. New fund (<3yr): not for Conservative clients.
CTS parameters: immutable — new versions only, never overwrite history.
Out-of-sample evaluation only — no look-ahead bias ever in backtests.
