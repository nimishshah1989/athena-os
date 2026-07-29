# Design language

> **INTERIM.** The founder is authoring the canonical version in Claude Design. When that lands,
> replace this file wholesale — keep the *Mechanics*, *Build order*, and *Honesty rule* sections
> below unless his version covers them, since those encode hard constraints (Indian numerals,
> real-browser verification, provenance) rather than aesthetic choices.

Governs every interface — a one-off artifact or a full platform — unless a project's own
`design-system/PRINCIPLES.md` explicitly overrides a rule and says why.

Three philosophies, each covering a failure mode the others don't.

---

## 1. Feynman — comprehension is the product

If it can't be explained plainly, it isn't understood. The test for any screen:
**could a smart person outside this domain use it without a glossary?**

- **One idea per screen.** A screen answers one question. A second question is a second screen,
  or a disclosure.
- **Explain the number next to the number.** A figure without its meaning is a puzzle. `XIRR 14.2%`
  is jargon; `14.2% — your annualised return after cash flows` is an answer.
- **Plain label over correct-but-opaque label.** "Money in vs money out" beats "Net cash position"
  when both are accurate.
- **Progressive disclosure.** Summary first, detail on demand. The expert reaches detail in one
  click; the novice is never blocked by it.
- **Name the uncertainty.** Confidence, `data_as_of`, staleness — surfaced in the UI, never buried
  in code. A number without provenance invites false trust.

## 2. Tufte — density without clutter

Financial professionals want detail. They don't want decoration. Dense is right; cluttered is wrong.

- Maximise data-ink. Every pixel either carries information or goes.
- No chartjunk: no gradients, 3-D effects, drop shadows, or gridlines that don't aid reading.
- Small multiples beat one overloaded chart.
- Direct-label series where possible; a legend is a lookup task imposed on the reader.
- Tables are a visualisation. Right-align numerals, tabular figures, fixed header on scroll.

## 3. Rams — restraint

"As little design as possible." Good design is unobtrusive. This is the ponytail ladder applied to
interface: **every element must justify existing.**

- Before adding a component, check ≥3 existing ones. Reuse beats creation.
- No decorative animation. Motion communicates state change or it doesn't ship.
- One accent colour doing one job. If everything is emphasised, nothing is.
- Empty space is structure, not waste.

---

## Mechanics (non-negotiable)

Detailed rules live in `~/.claude/rules/frontend-viz.md` and load automatically. Summary:

- **Numbers:** Indian lakh/crore (`₹1,23,45,678`), never million/billion. ₹ prefix.
  2 decimals displayed, 4 in calculation. Tabular numerals.
- **Percentages:** always signed. Green positive, red negative — and never colour alone
  (accessibility: pair with sign or arrow).
- **Dates:** `DD-MMM-YYYY` (04-Apr-2026), IST.
- **Charts:** axis labels, hover tooltip with exact values, source attribution. Always.
- **Tables:** sortable, searchable, filterable, CSV export. Click an aggregate → see constituents.
- **Loading:** skeleton screens, not spinners.
- **Accent:** teal `#1D9E75` on white, subtle borders. Desktop-first, mobile responsive.

## Build order

1. `design-consultation` → `design-system/PRINCIPLES.md` + tokens. **Once per project**, not per screen.
2. Build with `ui-ux-pro-max` + Tailwind, under the ≥3-component reuse gate.
3. Charts via the `dataviz` skill.
4. **Verify in a real browser.** Headless has no WebGL — a map or canvas that "passed" headless was
   never actually seen.
5. `design-review` last — it hunts AI-slop patterns, spacing drift, and hierarchy failures.

## The honesty rule

A UI that hides how a number was produced is a bug, however elegant. Every figure traces to its
source, its date, and its confidence. Trust is the feature; polish only matters after it.
