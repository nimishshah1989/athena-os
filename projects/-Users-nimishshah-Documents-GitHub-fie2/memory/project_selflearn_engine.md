---
name: Self-Learning RS Trading Engine
description: Planned autonomous RS trading engine with 3 model portfolios, risk management, and self-learning — to be built within FIE2
type: project
---

## Self-Learning RS Trading Engine — Planned 2026-03-21

### User Vision
Build an autonomous trading intelligence engine that behaves like "the most experienced relative strength trader" — manages 3 model portfolios, self-learns from trade outcomes, understands macro + momentum in depth.

### 3 Model Portfolios
1. ETF-only
2. Stock + ETF blend
3. Stock-only

### Core Requirements
- Strongest risk management: stop losses, hedges, drawdown minimization
- Net return optimization: factoring brokerage, STT, LTCG/STCG taxes
- Self-learning: analyzes its own trade history, tunes parameters
- Macro awareness: regime detection, breadth analysis
- Multi-timeframe RS: not just one period

### 5-Phase Build Plan (approved by user)
1. **Foundations** — refactor scheduler out of server.py, incremental backfill
2. **3 Model Portfolios** — volatility-based sizing, tax-aware exits
3. **Enhanced Signals** — multi-timeframe RS, macro regime, breadth, conviction scoring
4. **Risk Management** — portfolio-level drawdown limits, hedge overlay (VIX/put)
5. **Learning Engine** — trade journal, signal hit-rate tracking, parameter auto-tuning

### Decision: Build within FIE2 (same ecosystem)
Codebase review confirmed: 12,992 lines Python, 16,942 frontend, 22 tables, 73 endpoints — manageable. Self-learning engine fits as new services under existing architecture.
