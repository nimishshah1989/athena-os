---
name: Search Engine Feedback - April 2026
description: Detailed user feedback on Osho discourse search engine covering ranking, Hindi search, highlighting, UI, and missing features
type: feedback
originSessionId: 54c47d62-fe1b-4181-83fe-65f5b6b04e1c
---
## Search Ranking Issues
- Searching "Nietzsche": OCTP and Elasticsearch both rank "Light on the Path ~ 29" as #1, but ZETA ranks "The Messiah Vol 1 ~ 15" (fewer hits) as #1. Need to investigate ranking algorithm.
**Why:** Ranking inconsistency between engines erodes trust.
**How to apply:** Validate ranking against OCTP/Elasticsearch as reference. More hits in an event should rank higher.

## Proximity Search Bugs
- "politicians mafia" distance=30 should find 2 results, finds only 1
- "धन धर्म विश्वास" distance=30 should find 3 Hindi events, finds only 1 (a translation with no visible/highlighted match)
**Why:** Core search functionality is broken for proximity queries.
**How to apply:** Write regression tests for known proximity queries with expected result counts.

## Exact Phrase / Highlighting Bugs
- Exact phrase "नहीं वह तो ठीक" returns duplicate hit (Dekh Kabira Roya ~ 17 twice) plus 2 false positives with no highlighting
- "कहानियों से मुझे कुछ प्रेम है" works for exact phrase but fails highlighting for "All words" and "within N words" modes
**Why:** Highlighting logic doesn't match search logic across modes.
**How to apply:** Highlighting must work identically across all search modes. Deduplicate results.

## Hindi / Transliteration Issues
- Roman alphabet Hindi search not working properly (needs call to explain fully)
- Reference: typinginhindi.com for how Hindi input should work — emulate that behavior
**Why:** Hindi users need reliable Devanagari input and Roman-to-Devanagari transliteration.
**How to apply:** Study typinginhindi.com behavior and replicate it.

## UI/Layout Feedback
- White background preferred, but contrast too low — fonts need to be darker and larger
- Sort toggle (Rank | Title) selection state is unclear — needs higher contrast indicator
- Title "Osho - Search" should be more specific/distinctive
- Main frame fonts too small — must be readable by elderly users
- Mobile responsiveness not yet tested but required
**Why:** User base includes elderly readers; readability is critical.
**How to apply:** Larger fonts, higher contrast, clear active state indicators. Test on mobile.

## Missing Features Requested
1. Show both number of found events AND total number of hits in events (aids testing too)
2. Filter by original language vs translated
3. Filter by time period (e.g., 1972-1973)
4. Jump from one hit to next across events (like CD-ROM behavior)
5. Clickable link to sannyas.wiki event page from full discourse view
6. Keyboard shortcut to jump to next hit within full event view

## Data Cleanup
- Remove "source: Shailendra's Hindi collection" text from Hindi books — added by mistake

## Meta
- User is embarrassed by these issues — wants rigorous testing before shipping
- Need to document exact test cases and expected results
