---
name: project-beyond
description: "Beyond Relationship OS — wealth-management product for user's client (HNI/UHNI firm); brief at ~/All AI/beyond/PRODUCT.md"
metadata: 
  node_type: memory
  type: project
  originSessionId: 2a9aaebf-78dc-458b-a752-873258a4c269
---

Beyond is a new wealth management firm (user's client, founders incl. "Javirees") for HNI/UHNI investors (₹50L+ minimum), selling PMS, AIFs, GIFT City products. We are designing a "Relationship Operating System" — client-memory + agent-harness product (not a CRM).

Key artifacts:
- Product brief (canonical, for scoping): `~/All AI/beyond/PRODUCT.md` — 7 pillars: Omniscient Capture, Client Brain (core IP), Agent Harness, Surfaces, Trust Plane, Judgment Layer, Outcome Instrumentation.
- Verified deep research (2026-07-10): `~/All AI/beyond/research/2026-07-10-global-wealth-relationship-intelligence.md`.
- System design (2026-07-11, canonical architecture): `~/All AI/beyond/SYSTEM-DESIGN.md` — Postgres bitemporal fact store, agentic retrieval (not classic RAG), Procrastinate queue, Claude Agent SDK selective, DB-state-machine approvals. Rejected: Zep/Mem0 SaaS, Neo4j, Temporal, MAF adoption.
- Client checklist: `~/All AI/beyond/NEEDS-FROM-BEYOND.md` (Zoho = system of record; Gmail one-time import).

Decisions made (Jul 2026):
- Beyond-first, SaaS-later: single-tenant build, multi-tenant-ready (org-scoped, RLS day one).
- Agents draft, advisors send — no autonomous client-facing output (SEBI + Kitces-validated).
- Raw capture append-only; memory is a rebuildable projection (compounding moat).
- 11-Jul: CLIENT PORTAL IS IN — "One-Place Wealth": clients get logins + consolidated view (MF/equity via CAS+consent, PMS/AIF via upload/email, FD manual). Phases 4A (portfolio engine) + 4B (portal) in BUILD-PLAN. Key research: research/2026-07-11-consolidated-wealth-client-portal.md (AA can't fetch FDs in 2026; MFD isn't FIU-eligible; CAS route is license-free). Reference product: Infinyte Club (their gap = no PMS/AIF/FD consolidation = our whitespace).
- Repo live at ~/All AI/beyond, pushed to github.com/nimishshah1989/beyond-relationship-os. Phase 0 (schema+RLS+queue) complete.
- Beyond ops portal (data to eventually ingest): beyond-wealth-desk.vercel.app — creds from user 11-Jul, in session transcripts, not stored here.

**Why:** ongoing multi-session product design; these decisions and file locations aren't recorded anywhere else yet.
**How to apply:** read PRODUCT.md before any Beyond work; don't re-litigate settled decisions; next step is phasing/scoping against the brief. See [[user-profile]].
