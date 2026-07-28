---
name: apply-flow-deferred-polish
description: "Founder feedback — inline document preview/editing and richer CV/letter templates, explicitly deferred but required before wider circulation"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f2e38d55-0cb1-40e6-bc7c-2d7b32343a78
---

Two items the founder flagged on 2026-07-13 while testing the redesigned apply flow.
Both explicitly NOT blockers to go live to himself, but he wants them done **before
circulating to other people** (the friends beta). Do not build until asked — batch with
[[qa-bank-field-standardization]] when the next "polish pass" is scoped.

## 1. Inline document preview (artifact-style), not download→screenshot→upload

Current flow after generation: `Download CV` / `Download cover letter` buttons only —
user must download the PDF, open it separately, and there's no way to see formatting
without leaving the app. Revision is also indirect: type a change request into a text
box, wait, re-download.

**Founder's request:** show the generated CV and cover letter inline next to the
chat-like revision flow (his words: "like how Claude displays an artifact on the
side") — a live preview pane so the user can see exactly how it looks/formats, and
iterate through natural-language requests without the download/screenshot/re-upload
loop.

**Why:** the product already HAS a text-level inline editor
(`PATCH /generations/{id}/bundle`, `frontend/src/app/(app)/apply/page.tsx`
`editing`/`saveEdits` state — edits re-render PDFs in ~3s, no AI) and a free-text
revision endpoint (`POST /generations/{id}/revise`). What's missing is a rendered
preview surface — today the only way to SEE the PDF is to download it locally.

**How to apply:** likely needs a PDF preview pane (iframe/embed of the rendered PDF,
refetched after each edit/revise) sitting beside the existing edit form, so "make a
change → see the result" happens on one screen instead of a round trip through the
filesystem.

## 2. Cover letters are visually blank — need real templates

The founder's reaction to the generated cover letter: "so super blank... no literal
formatting to it." CVs already have 3 template choices (classic/modern/compact, see
`backend/app/services/typst_render.py` `CV_TEMPLATES`) but the **cover letter has no
template variation at all** — one plain layout, no matching family to the CV
templates, no visual choices for the user.

**Founder's ask:** before circulating beyond himself, add more templates for BOTH CVs
and cover letters, with actual visual formatting on the letter side (not just prose in
a box) — give people options.

**How to apply:** extend `typst_render.py`'s cover-letter rendering the same way
`CV_TEMPLATES` works for CVs — a `LETTER_TEMPLATES` dict with 2-3 real layout
variants, exposed on the same profile-level template picker the CV templates use.
