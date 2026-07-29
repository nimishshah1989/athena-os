---
name: Cash includes LIQUIDBEES
description: Nimish confirmed cash position should include ledger cash + LIQUIDBEES instrument, not just the Liquidity% from PMS file
type: feedback
---

When displaying "cash" on the dashboard (cards, charts, anywhere), it must include:
- Ledger cash (Cash And Cash Equivalent column in NAV file)
- LIQUIDBEES / LIQUIDETF holdings (Investments in ETF column in NAV file)
- Bank balance

The PMS backoffice "Liquidity %" column only includes (Cash+Bank)/NAV and EXCLUDES ETF instruments like LIQUIDBEES. So we cannot use Liquidity% as-is for the "cash" display — need to add ETF value.

True cash % = (Cash + ETF + Bank) / NAV
