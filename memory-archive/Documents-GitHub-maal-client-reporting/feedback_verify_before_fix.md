---
name: Verify the reported symptom against live data before coding a fix
description: When user flags a "wrong" value, confirm what the source of truth says before assuming the code is broken
type: feedback
originSessionId: c07c9e2d-455e-4002-87e4-908221fb8187
---
When the user reports a bug ("X is wrong", "Y is broken"), verify the symptom
against the actual source of truth *before* writing any fix. In particular:
look at the screen/page the user is looking at and read what the system is
actually telling you.

**Why:** On 2026-04-24 the user flagged a "Mirae Smallcap" issue. I assumed
the cpp_holdings price ₹43.30 for symbol SMALLCAP was wrong, invented a
MASMC250 override, pushed two commits, and ran SQL updates on 515 rows —
only to discover SMALLCAP was already the correct NSE ticker. The actual
bug was on the reconciliation screen (ETF Holdings file not merged into
recon comparator) and would have been obvious if I had opened that screen
first instead of trusting my own reading of "₹43.30 looks low."

**How to apply:**
1. Before writing code, open the page/view the user is looking at and read
   what it says. If the user names a specific screen (dashboard,
   reconciliation, etc.), that is the first place to look.
2. Check the authoritative source — NSE's eq_etfseclist.csv for tickers,
   JIP data core for prices, the uploaded file itself for ingestion issues
   — before believing "this value is wrong."
3. A status like `EXTRA_IN_OURS` with `bo_quantity: null` means the
   backoffice row is *missing*, not that our ticker/price is wrong. Read
   reconciliation statuses literally.
4. If a fix seems "obvious" after five seconds of thought, that's a signal
   to slow down and verify, not speed up and ship.
