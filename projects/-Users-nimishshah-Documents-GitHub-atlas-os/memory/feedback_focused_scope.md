---
name: Tight focused checks over exhaustive diagnostics
description: User prefers compact, high-signal checks; flags when work is too extensive
type: feedback
originSessionId: 85e68f27-9b9a-4a5b-ac58-6da306889a19
---
**Rule:** When proposing checks / validations / inventories, keep them tight and focused on what unblocks the next step. Don't expand into deep diagnostics unless asked.

**Why:** When the pre-flight check matrix grew to ~50 line-items across 15 tables, the user pushed back: "I think you're doing too extensive. We need 12 years of data for most instruments... 750 top stocks, 100-200 ETFs, all the indices we mentioned, and 500 odd equity regular growth funds. That is what we need as the core database, apart from instruments + sector mapping + ETF holdings + MF holdings data." Confirming a tight scope they want.

**How to apply:**
- Pre-flight / readiness checks: limit to "do we have the universe + 12y depth + masters + holdings + sector mapping?" Don't add per-table NULL audits, spot-check sample rows, deep schema analysis unless something fails.
- If a check is exhaustive, lead with the most-likely-to-fail items and stop the user before listing edge cases.
- When in doubt, ask "is this enough?" rather than dumping a 50-row table.

**v0 universe scope reaffirmed:** 750 stocks + 100-200 ETFs + 75 indices + 500 mutual funds + masters + holdings + sector mapping. ~12 years of OHLCV / NAV. That's the core data shape; everything else is supplemental.
