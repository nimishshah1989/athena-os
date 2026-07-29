---
name: Demo Quality Feedback
description: Owner feedback on presentation quality - charts need insights, mobile-first, intelligence tabs, no markdown in chat, KOT/timing analysis needed
type: feedback
---

## Key Feedback (2026-03-20, pre-demo)

### Revenue Numbers
- Must match PetPooja dashboard exactly. Use `net_amount` field — it's closest to PetPooja's "Total Sales"
- Mar 19: PetPooja shows revenue=₹2,05,780, net sales=₹1,95,950

### Charts & Graphs
- Empty/sparse charts are NOT presentable — hide or show T-1 data
- Every chart must have an accompanying insight (use Claude API if needed)
- Labels and data must be clean — no missing data, no placeholder text

### Intelligence Structure
- Organize into tabs: Revenue Intelligence, Cost Intelligence, Menu Intelligence, Operations Intelligence
- Each finding must show: what, why (logic/data source), rupee impact, and actionable next step
- The system should feel like a "Chief of Staff" — proactive, not just dashboards

### Chat Responses
- No raw markdown (**bold**, *italic*) — looks unprofessional
- Clean, professional text output

### Mobile
- Entire interface must be mobile-friendly — owner demos on phone

### Missing Analytics
- KOT/timing data: hourly distribution, peak hours, dwell time
- Order size vs time correlation (prove longer stays = more billing)
- Customer cohorts from order data (Reelo CRM does this via PetPooja)
- More intelligent pattern detection from existing data

### Claude API Usage
- Use it more generously — for chart insights, finding explanations, weekly analysis
- Don't be conservative with API calls — the value justifies the cost
