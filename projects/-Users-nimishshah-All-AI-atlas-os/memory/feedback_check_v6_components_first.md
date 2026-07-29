---
name: check-v6-components-first
description: "BEFORE building any v6 UI, ls frontend/src/components/v6/ and check what already exists. 114 components live there. Duplicating them caused a session-long mockup-divergence failure on 2026-05-27."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: c880c6b8-5d45-4717-8ecc-d02304a45cd0
---

When building any page under `frontend/src/app/v6/*`, ALWAYS list `frontend/src/components/v6/` first and check whether the page's needed components already exist.

**Why:** On 2026-05-27 I (Claude) built 7 v6 pages (`/v6/regime`, `/v6/stocks`, `/v6/funds`, `/v6/calls`, `/v6/markets-rs`, `/v6/stocks/[symbol]`, `/v6/funds/[scheme]`) WITHOUT checking the components folder. There were 114 components already built across commits C.14–E.4 (`RegimeHero`, `StockHero`, `FundHero`, `ETFHero`, `CellHero`, `CellMatrix`, `ConvictionTape`, `BubbleRiskReturnChart`, `MultiBenchmarkRSWaterfall`, `PerWindowChart`, `StyleBox`, `RegimeIndicator`, `TodayClient`, `ETFsList`, `FundsList`, `StocksTableV6`, `SectorLadder`, `SignatureMatrix`, `ELI5Tooltip`, etc.) implementing the locked design language. My pages bypassed them entirely, producing bare data-binding pages that diverged badly from the mockups. The user (rightly) lost trust in my work that session.

**How to apply:**
1. Before writing ANY code under `frontend/src/app/v6/`, run `ls frontend/src/components/v6/ | head -60` and `cat frontend/src/components/v6/STATE.md` (the URL persistence contract).
2. The pattern is: page.tsx is a THIN RSC shell (≤250 LOC, hook-enforced) that fetches data + delegates to a `*Client` component. Example: `frontend/src/app/v6/today/page.tsx` → `import { TodayClient } from '@/components/v6/TodayClient'`.
3. If you think you need to build a new component, FIRST search `frontend/src/components/v6/` for similar functionality. The user's design language is locked — duplicating components is wrong, never "different style choice."
4. The canonical reference for what components should exist is [[reference-v6-build-plan-source-of-truth]] (the 60-task spine from 2026-05-26).
5. Mockup HTMLs at `~/.gstack/projects/atlas-os/designs/v6-redesign-20260526-mockups/` are the visual spec. They show what each page should LOOK like, but the COMPONENTS to render that look already exist.
