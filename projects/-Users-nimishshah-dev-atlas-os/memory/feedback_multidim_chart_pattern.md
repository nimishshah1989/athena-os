---
name: multidim-chart-pattern
description: Atlas charts must communicate multiple dimensions in one frame — price + S/R levels + RS-signal markers + volume bars + 20D-MA. Single-line charts are insufficient.
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 8e01e1a5-9292-458d-860a-0087a1c78a5c
---

Atlas-v6 detail charts must be **multidim** — every chart card stacks lanes against a shared time axis so one viewport answers multiple questions:

1. **Price lane** — index/security line with **explicit horizontal support & resistance** levels labelled (R / S), last value at right
2. **RS-signal markers** — green diamonds for RS new-highs (vs the selected baseline), red diamonds for RS new-lows. **Absence-of-markers reads as loudly as presence** — a chart with zero markers tells the FM there is no edge worth taking
3. **RS strip** — narrow zero-anchored lane with green/red fill above/below showing live spread vs baseline
4. **Volume lane** — up/down day bars (green/red tint) plus a **20-day average overlay** (blue line). Rising 20D-MA into rising price = confirmation; rising 20D-MA into falling price = distribution; falling 20D-MA = waning interest, the worst pattern

Locked in `~/.gstack/projects/atlas-os/designs/v6-redesign-20260526-mockups/03-markets-rs.html` (r3) as the reference implementation. SVG coord system: viewBox 720×300, price pane y=12-178, RS strip y=188-216, volume pane y=228-292.

**Why:** Fund manager showed an iShares Singapore ETF chart (TradingView) demonstrating this exact pattern — price + volume bars + 20D-avg overlay + RS-line breakout diamonds. Single-line "rebased to 100" charts hide momentum-volume divergence and have to be discarded across the platform.

**How to apply:** Use this pattern on every detail chart across v6 pages — Markets RS (done, locked), Sectors (04), Stocks (05), Funds (06), ETFs (07). Plain rebased-return lines are forbidden for detail views. The pattern can adapt for ETFs (use the ETF's own volume) and for Gold (use GoldBees as the volume proxy). Layer toggles (`S/R · RS signals · Volume · 20D MA`) should be exposed at the page-controls bar so the FM can strip the chart down if needed.

Related: [[skill-loop-process]], [[scorecard-deep-search-integration]].
