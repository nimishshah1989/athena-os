---
name: ELI5 glance→drill design law
description: Founder's frontend gold standard (21-Jul-2026) — glanceable visual layer by default, advisor depth one click away; refines the older "data density" rule
type: feedback
originSessionId: 98624028-c044-4ac1-ae1c-edeb5f52284f
---
Every screen: a glance layer (big numbers, 5-state urgency colors, one icon language, ≤3 primary
actions, clickable everything) over a work layer (dense tables, collapsed by default, never
deleted). "If a 10-year-old can understand the dashboard without compromising depth, that's the
bar. No training needed."

**Why:** Founder (non-technical) benchmarks against new-age consumer apps — visual, iconic,
intuitive, everything linked/clickable, low cognitive load. He explicitly refined the earlier
"information-rich screens / financial professionals want detail" preference: density survives in
the drill layer and print packs, not on first paint.

**How to apply:** Any new Beyond surface or component: state = urgency tokens + icon (never color
alone, never emoji), glance header with clickable stat cards, progress drawn with the number
visible, no dead glance (state elements link to where you act), 1 question / ≤3 primary actions /
≤7 glance elements per screen. Codified as spec §4.9 L1–L9 in
research/2026-07-21-ux-overhaul-build-spec.md — cite that, don't re-derive.
