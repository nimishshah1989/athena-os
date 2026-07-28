---
name: feedback-specs-as-html
description: "User wants design specs delivered as rich self-contained HTML with embedded UI mockups, not plain markdown"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 2ff217a8-ee34-4358-b1a3-6ac996e1cccf
---

When producing a design spec, deliver a **rich self-contained HTML version** —
not just a `.md`. The HTML should include the full narrative AND embedded visual
mockups of how the frontend would look.

**Why:** The user said on 2026-05-20: "want to start moving from .md files to a
much richer .html." Plain markdown specs are too thin — the user wants specs that
*show* the product (mockup views of pages), styled, viewable in a browser.

**How to apply:** For a design spec, produce a single self-contained HTML file
(inline CSS, no external deps) alongside (or instead of) the `.md`. Render the
spec narrative richly and embed product mockups in the **Atlas wealth-management
visual language** — white/paper background, ink text, teal accent `#1D9E75`,
serif headings, data-dense tables, Indian number formatting. Frame mockups as
labelled "screens". Commit it to `docs/superpowers/specs/` and `open` it so the
user can view it. The `.md` can stay as the machine-readable canonical; the HTML
is what the user actually reviews. First example:
`docs/superpowers/specs/2026-05-20-atlas-strategy-marketplace-design.html` in the
atlas-os-consolidation worktree.

Related: [[project-atlas-decision-engine]], [[feedback-simplify-adopt-libraries]]
