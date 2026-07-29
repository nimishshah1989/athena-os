---
name: CRITICAL — Simulation tool failures exposed in board presentation
description: Synthetic data in strategy detail, broken signal topups, wrong indicator data, UI too complex. Board presentation failed.
type: feedback
---

## What happened
User presented the simulation/strategy tool to the JSL board. Multiple failures exposed:

1. **Synthetic data in production** — StrategyDetail.jsx has Math.random() equity curve, hardcoded signal events, 18% overlap constant. ALL violated Law 2.
2. **Signal topups not working** — SIP and SIP+Signal return identical results. Multiplier not being applied.
3. **Wrong indicator data** — 21EMA below 30% showing only 1 day in 5 years (impossible). Data source or threshold mapping is broken.
4. **4 disconnected indicators** — VIX, A/D Ratio, New Lows, Sector RS Count listed but have no backend source.
5. **UI too complex** — 4 sub-boxes for modes, unclear controls. Needs simplification.

## What user wants
- Indicators from MarketPulse: Daily close > EMA21, Daily Close > EMA200, Daily RSI<40, Daily RSI<30, Monthly close>12m EMA, Monthly RSI<50, Monthly RSI<40, Breaking Prev Quarter High, Breaking Prev Year High
- Simple UI: Fund(s), SIP budget, Lumpsum budget, Max per event, Cooldown, Start/End date, Signal conditions with and/or
- Mass backtesting: Top 100 funds × 3/5/10Y × multiple signals × 4-5 thresholds
- ZERO synthetic data anywhere

## Impact
- Board presentation failed publicly
- Trust in the tool and in Claude's output is damaged
- This is the #1 priority — simulation tool must work correctly before anything else

**Why:** User is a non-technical founder presenting to a financial services board. Every number must be real and verifiable.
**How to apply:** NEVER skip data verification. Before deploying any page, verify every number shown traces back to a real API call with real DB data. Flag synthetic/placeholder data LOUDLY before it goes to production.
