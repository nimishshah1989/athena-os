---
name: qa-bank-field-standardization
description: "Founder feedback — the extension Q&A bank's application-answer fields must become structured inputs, not free text"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f2e38d55-0cb1-40e6-bc7c-2d7b32343a78
---

The founder tested the Q&A bank (`backend/app/api/extension.py` `QA_KEYS`, list of 8
free-text fields feeding extension autofill) and flagged every field as free text when
several should be structured. Explicitly deferred: "put it in your memory, we will
correct everything in one go" — do not build until asked, batch all of these together.

Per-field requested shape:
- **notice_period** — dropdown, standardized in months (not free text).
- **current_location** — city autocomplete/typeahead (e.g. typing "Bombay" should
  resolve to the canonical city), not a bare text box.
- **relocation** ("willing to relocate?") — Yes/No, not free text.
- **work_authorization** — currently one combined free-text question ("authorized in
  India / need sponsorship elsewhere?"); split into two: "Authorized to work in
  India?" (Yes/No) and "Need sponsorship to work elsewhere?" (Yes/No) — can render as
  one combined control but must capture two distinct answers.
- **expected_ctc** — numeric with an explicit unit, India convention: ₹ lakhs per
  annum (not raw free text); also needs an "open to negotiation / prefer not to
  specify" option — some candidates don't want to commit a number.
- **experience_years** ("total years of professional experience") — standardize the
  unit to months (founder's explicit ask, consistent with notice period), not free
  text years.
- **linkedin_url**, **portfolio_url** — keep, but must NOT be mandatory/required.

**Why:** free text on these fields produces inconsistent, hard-to-autofill,
hard-to-compare data (a notice period of "1 month", "30 days", "immediate" etc. all
mean different things to downstream matching/autofill); structured inputs are also
what real ATS forms expect, so autofill quality depends on this being fixed.

**How to apply:** when asked to "fix the Q&A bank fields" or similar, batch ALL of the
above into one pass — redesign `QA_KEYS` in `backend/app/api/extension.py` (and the
corresponding frontend form, likely `frontend/src/app/(app)/profile/page.tsx`'s
"Application answers" section) as typed fields (enum/dropdown for notice period and
yes/no fields, a units-aware numeric input for CTC and experience, a city-autocomplete
for location, `required: false` on the two URL fields) instead of free-text strings.
Related: [[careerplus-known-bugs-2026-07-13]].
