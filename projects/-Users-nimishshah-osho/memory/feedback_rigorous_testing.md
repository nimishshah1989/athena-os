---
name: Rigorous testing before shipping
description: User was embarrassed by search bugs reaching testers — demands thorough testing, especially Hindi search and highlighting
type: feedback
originSessionId: 54c47d62-fe1b-4181-83fe-65f5b6b04e1c
---
Every change to the search engine must be thoroughly tested before shipping. The user's collaborators found multiple Hindi search bugs (highlighting, proximity, duplicates) that should have been caught.

**Why:** The user said "its embarrassing — so make sure its well tested and corrected for." External testers found issues that should never have shipped.

**How to apply:** Always run the full test suite (61+ tests covering English, Hindi, proximity, filters, highlighting). Add regression tests for every bug fix. Test Hindi highlighting specifically — JS's `\b` word boundary is ASCII-only and silently fails on Devanagari.
