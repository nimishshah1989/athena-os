---
name: V2 live review feedback (2026-03-31 evening)
description: Nimish's detailed live review after V2 deploy — 15+ issues found despite claiming 53 tasks done. Critical for next session.
type: feedback
---

Nimish reviewed mfpulse.jslwealth.in live after V2 deploy on 2026-03-31. Found significant gaps:

## Issues Found (binding — must fix)

### 1. Fund count mismatch (Overview → Universe)
- With ALL filters selected, Overview shows ~3,600 funds out of 11,700
- User asks: "What are the other 8,000 funds?" — need clear explanation
- The IDCW + segregated exclusion silently removes thousands — must be transparent

### 2. Info icons (i) NOT applied anywhere
- Despite building the InfoIcon component, it's NOT placed on any table, chart, or metric
- No technical terms explained, no formulas shown, no definitions given
- This was THE most requested feature — completely missed in execution

### 3. Global filters bleeding into Universe page
- Despite no filters selected on Overview, Universe page still shows "Equity Only > 1000 Cr Direct" defaults
- The old local filters on Universe page override/conflict with the global FilterContext
- Filters must be unified — global from Overview, no separate defaults on other pages

### 4. Universe insight cards not clickable
- The 6 cards below the scatter are not clickable — they should link to the funds shown
- Font sizes and styles inconsistent between cards — some look "weird"

### 5. Expense Analysis card useless
- "Doesn't make sense" — needs to be specific, clear, direct
- Either show something actionable or replace the card

### 6. Heatmap/Treemap have no labels
- When switching to heatmap or treemap views, no labels visible
- No explanation of what dimensions are represented
- Bubble chart has 4 dimensions — need a note explaining them

### 7. Compare section broken/useless
- Return curves NOT populating (even for large funds like SBI Multi-Asset, Quant Multi-Asset)
- Sector comparison NOT populating
- Only using a tiny fraction of 200+ available data points
- Needs red/amber/green indicators, visual strength comparison
- "Comparison part needs to be very, very strong" — currently substandard

### 8. Analytics tab broken
- Top part not populating
- "Equity" and "Allocated" categories — what does Allocated mean? No explanation
- "Both these pages are very substandard right now"

### 9. Fund 360 filter bar half empty
- Strip has too many filters but half is empty space
- Design is different from Overview page — inconsistency
- Need to fill the whole bar or redesign

### 10. Fund 360 sort order STILL wrong
- Still showing Franklin funds or 360 ONE at top
- Should ALWAYS sort by AUM + returns combination
- "The entire sequencing should be made based on AUM and returns"

### 11. Performance chart curve NOT working
- Only shows "March 26, March 26" — no actual curve
- Data points may not be mapped correctly
- Period switching doesn't generate a curve

### 12. Fund detail cards too big / empty
- Deep dive fund cards are "humongous" with small fonts
- "Overall picture looks empty"
- Asset allocation and credit quality cards empty for most funds — data not mapped?
- Space not utilized despite mentioning this multiple times

### 13. Market status always shows "Market Closed"
- Even during market hours? Needs verification

### 14. Font choice is bad
- "Inside every zero there is some kind of a dot" — JetBrains Mono's zero style
- Not classy for a financial platform
- Font too close together in some areas
- Need a better font for numbers (tabular-nums but different family)

### 15. Design language STILL inconsistent
- Overview filter style vs Fund360 filter style completely different
- Card sizes vary across pages
- No standardized look

**Why:** These are all items from the ORIGINAL feedback PDF that were either not done or done incorrectly. Nimish is losing trust.
**How to apply:** Fix each one with Playwright screenshot proof. No marking done without visual verification. Start next session with this list.
