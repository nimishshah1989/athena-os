---
name: MAA Website Design Direction
description: Final design direction after researching 75+ websites — Apple-inspired light theme, multi-page app, NOT the original dark Bloomberg spec
type: project
---

## Design Direction (Researched & Aligned)

After researching 75+ websites for inspiration, the design direction **pivoted away from the original CLAUDE.md spec** (dark Bloomberg terminal, 27-section scroll-snap single-page) to:

### Visual Identity: Apple-Inspired Light Theme
- **White/light background** (#FFFFFF primary, #F5F5F7 secondary) — NOT the dark #07070c from original spec
- **Apple-class color palette:** Blue accent (#0071E3), Apple green (#34C759), Apple red (#FF3B30)
- **Subtle shadows** instead of heavy borders — `.card` uses `box-shadow: var(--shadow-sm)` with hover to `shadow-md`
- **Frosted glass** navbar (rgba white + blur)
- **Clean, editorial, premium** — think Apple product pages, not Bloomberg terminal
- **Border-radius: 16-20px** on cards (rounded, modern)
- **No scroll-snap** — smooth scrolling multi-page layout instead

### Architecture: Multi-Page App (NOT single-page scroll-snap)
- **Landing page** (`/`): 8 focused sections — Hero, Fee Problem, Asymmetry, Proof/Backtest, Growth of ₹100, Method, Trust, CTA
- **Subpages:** `/about` (team, philosophy, brokerage, compliance), `/performance`, `/philosophy`
- **Tool pages:** `/tools/fee-calculator`, `/tools/compounding`, `/tools/backtest`, `/tools/asymmetry`
- **Global layout:** Navbar (frosted glass) + Footer + StickyCTA bar

### Typography (kept from original spec)
- Headings: Epilogue, 700-900 weight, tight tracking (-0.3px to -2px)
- Data/numbers: JetBrains Mono with tabular figures
- Body: Epilogue 300-400
- Label micro: 13px, 3px letter-spacing, uppercase, accent color

### Animation System
- FadeIn component using Framer Motion — `whileInView` triggers
- TextReveal — word-by-word staggered reveal (40ms per word)
- AnimatedCounter — number counting animation
- Direction variants: up/down/left/right/none
- Easing: [0.25, 0.4, 0.25, 1] (custom cubic-bezier)

### Unified Single-Page Narrative (consolidated 2026-03-21)
All content now lives on one page as a scrolling narrative. No separate /performance or /philosophy pages needed.

**ACT 1: THE HOOK**
1. Hero — "Your money should compound, not your fees." + animated counters + CTAs
2. Fee Problem — Embedded calculator (₹1L-₹5Cr slider), PMS vs MF vs MAA table, "You save" highlight

**ACT 2: THE EDGE**
3. Asymmetry — 4 stat cards + interactive slider simulator (-20% to +20%)
4. Proof — Backtest explorer: pick any start date + amount, see real returns
5. Growth of ₹100 — Recharts LineChart with period toggles (1Y/3Y/5Y/ALL)

**ACT 3: THE METHOD**
6. Position Sizing — 3 cards (Too Few/Sweet Spot/Too Many) + Position Simulator (10 clickable circles)
7. Position Management — Winners (5 trades) vs Fast Exits (4 trades) + Recovery Math bars inline
8. Cash Philosophy — 3 big teal numbers (18%/73%/40%) + Bhaven quote
9. Cash Timeline — Dual-axis Recharts chart (NAV + cash %)

**ACT 4: BATTLE-TESTED**
10. Market Storms — 6 storm cards (NIFTY vs Fund drawdowns)
11. Sleep Test — 1,996-square day mosaic + 6 drawdown stat cards + Last 18 Months comparison

**ACT 5: THE PORTFOLIO**
12. Portfolio — Infusion journey + stacked bar + 4 stats + NAV Curve chart + Tax Efficiency inline

**ACT 6: THE TRUST**
13. People — Bhaven & Jeet cards with photos, bios, quotes
14. Final CTA — "Ready to start?" + WhatsApp links + SEBI disclaimers

### Core Philosophy: The Website IS the Pitch
- The website should be an **experience** — not a brochure
- Every section builds confidence to invest. By the time they reach CTA, the visitor is already convinced.
- **Tools are integrated into the narrative**, not separate utility pages. The fee calculator isn't a "tool" — it's the moment you realize how much PMS is costing you. The asymmetry simulator isn't a widget — it's the moment you feel the edge.
- Each section earns the next scroll. The flow is: provocation → proof → method → trust → action.

### Key Design Decisions
- **No particle field** in hero — replaced with subtle radial gradient
- **No page dots** navigation — standard navbar + footer instead
- **Interactive tools woven into the narrative** — they appear at the exact moment they're most persuasive
- **Data from JSON** files (pre-processed from Excel at build time)
- **Charts use Recharts** with Apple-style colors (dark line for MAA, grey for NIFTY, dashed for FD)
- **Lazy-loaded charts** (only render when in viewport via useInView hook)
- **Monthly data** for charts (not daily) for performance
- **Max content width: 1200px** (not 1560px from original spec)

### What was deliberately dropped from original 27-section spec
- Scroll-snap behavior
- Sleep Test day mosaic
- Position Sizing standalone section
- Sector Selection 2x2 case studies
- Sector Timing detailed stories
- Recovery Math section
- Cash Timeline interactive dual-axis chart (as standalone)
- The Cycle section
- Detailed Market Storms section (condensed into Method)
- Why Multi-Asset section
- Avoiding Losers section
- Time Is Money section
- Portfolio detail section
- Last 18 Months comparison
- Tax Efficiency section
- ₹1 Crore Projection section
- Market Health Indicators sections
- Many moved to subpages or tool pages instead

### CTA Strategy
- WhatsApp-first (no form capture for now)
- Sticky CTA bar appears after 800px scroll
- 3 WhatsApp links: factsheet, inquiry, invest (phone placeholder: XXXXXXXXXX)
- "Start with ₹1 Lakh. No management fees."
