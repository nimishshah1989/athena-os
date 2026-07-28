---
name: Strategic Pivot - Post Presentation (March 2026)
description: Major product direction change after Nimish's presentation - revenue growth over cost, competitive intel, voice input, UX revamp, PetPooja-only data
type: project
---

## Context
Nimish had a detailed presentation (2026-03-20) and received feedback that reshapes the product direction significantly.

## Key Strategic Shifts

### 1. Revenue Growth > Cost Optimization
- Focus on understanding customers, ordering patterns, cultural context of Kolkata
- Engine should LEARN from data, not just find statistical patterns
- Real insights into menu design — what to add/change — aligned with cafe philosophy and values
- YoursTruly is in a cosmopolitan area of Kolkata — cultural context matters

### 2. Remove Tally Integration
- All stock, purchases, inventory data lives in PetPooja
- Tally removal simplifies logic significantly and frees up codebase space
- No need for dual data source reconciliation

### 3. Reelo CRM via PetPooja
- Reelo (CRM software) is integrated INTO PetPooja
- All customer data flows through PetPooja pipeline
- No separate Reelo integration needed

### 4. Competitive Intelligence Engine
- Read and analyze Google reviews for YoursTruly AND competitors
- Analyze cafes in the area — what's working in the city
- Understand Kolkata landscape + micro-geography around the cafe
- Needs a constantly-running agent for this

### 5. Community & Repeat Customers (NOT Discounts)
- Cafe does NOT want discount-driven positioning
- Focus on building strong community and repeat user base
- 15,000 sq.ft space requires sustained footfall to be viable long-term
- Loyalty/community metrics are priority over promotional mechanics

### 6. Voice Notes from Owners
- Owners should be able to record voice notes anytime
- AI backend must continuously learn from owner's insights
- Owner knowledge should be evident in analysis and commentary
- This is the "learning from human expertise" loop

### 7. UI/UX Revamp
- Current web version feels like a mobile app — needs proper desktop design
- Use Stitch MCP (Google's design MCP tool) for complete UI/UX overhaul
- Make it feel like a professional intelligence platform, not a mobile dashboard

### 8. Chat Experience is Broken
- Current lag: 3-5 minutes for insights to appear
- No loading indicators — user doesn't know if response is coming
- Needs to feel smooth and responsive
- This is a critical UX blocker

### 9. PetPooja Data Accuracy & Depth
- Numbers shown must EXACTLY match PetPooja
- Need complete mapping of all available PetPooja data
- Explore additional data: KOT (Kitchen Order Tickets), etc.
- If we use their data, there's no reason for discrepancies

### 10. Staff Consumption Flag
- PetPooja data has a flag for staff-consumed items
- These must be excluded from COGS calculations
- Treat staff consumption as a separate line item
