---
name: Methodology lock wins when milestone docs drift
description: When milestone docs disagree with 00_METHODOLOGY_LOCK.md, methodology is the source of truth
type: feedback
originSessionId: 85e68f27-9b9a-4a5b-ac58-6da306889a19
---
**Rule:** When `docs/00_METHODOLOGY_LOCK.md` and a milestone doc (`docs/milestones/ATLAS_M*.md`) disagree, the methodology lock wins. Patch the milestone doc, never patch the methodology lock without explicit sign-off.

**Why:** The methodology lock is `Status: v0 LOCKED — pending Bhaven Shah final sign-off`. It's the canonical specification of what the system computes. Milestone docs are downstream implementation guidance and can drift. The user explicitly chose this when seven F-numbered drifts (F1-F7) were surfaced in the M5 milestone doc — they instructed "go with methodology" / "the more extended methodology" / "methodology wins."

**How to apply:**
- Any code change that touches state classification, gate logic, decision rules, or threshold semantics: cross-check methodology section first, then milestone doc, fix the milestone doc if drift found.
- The seven specific M5 fixes are documented in `prds/00_INFRA_DECISIONS.md` Section 5 (F1-F7).
- The schema additions for `ema_50_stock` (M3 needs) and `atr_21` (M5 ATR-stop needs) are baked into M1 schema migrations to avoid M2 rerun later.
- The Stage-1 base "relaxed bootstrap" decision (first-50-trading-days only requires MA-flat) is a v0-time concession documented in `prds/00_INFRA_DECISIONS.md` Section 7.

**Methodology revision process:** written change proposal → Bhaven sign-off → version bump → downstream document review → full historical recompute. Don't shortcut this for tuning — tuning belongs in `atlas_thresholds`, not in the methodology.
