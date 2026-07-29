---
name: Regular funds only — no Direct plans
description: User decided to show ONLY Regular plan funds across entire MF Pulse platform, skip Direct fund data
type: feedback
---

Show ONLY Regular funds (purchase_mode=1) across the entire MF Pulse platform. No Direct plan funds anywhere — not on Dashboard, Universe, Fund 360, Sectors, or Strategy Builder.

**Why:** Direct and Regular are duplicate share classes of the same fund. Showing both doubles the fund count (13K → 6.7K) and confuses the view. Regular plans are what distributors/advisors work with. The NAV backfill was already done for Regular funds (14.6M rows) — no need to backfill Direct.

**How to apply:**
- Default `planType` filter = 'regular' (not 'all')
- Backend universe endpoint filters `purchase_mode = 1`
- Remove Direct/Both options from plan type filter UI
- All fund counts, category counts, smart buckets should reflect Regular-only
- The backfill script should keep `purchase_mode = 1` filter
