---
name: project-recovery-engine
description: "Recovery Engine product scope, what the tally-analytics-warehouse codebase is, and what needs to be built"
metadata: 
  node_type: memory
  type: project
  originSessionId: 7289a408-0fca-4e62-81df-0a00a4607177
---

# Project: Recovery Engine (Receivables Collection Platform for Indian B2B)

The product spec is in `recovery-engine.html` in the project root (shared as HTML doc). The codebase foundation is `tally-analytics-warehouse` (shared as a zip from Downloads).

## What the Codebase Is (tally-analytics-warehouse)

A mature, production-grade Tally Prime analytics pipeline:

- **Extractor**: Python pulls data from Tally's XML/HTTP endpoint (read-only, CP1252 encoding handled, streaming lxml parse for 100MB+ XMLs, hard-won quirks encoded)
- **Warehouse**: PostgreSQL 16, 3 layers — `raw` (JSONB landing) → `stg` (typed, cleaned, sign-normalized) → `mart` (star schema for dashboards)
- **Backend**: FastAPI, one router per domain area
- **Frontend**: Next.js 16, Tailwind, Recharts, Indian lakh/crore format
- **Deployment**: Windows laptop auto-restores Tally backup from Google Drive nightly (PowerShell scripts), Mac runs orchestrator to pull from laptop Tally via HTTP

### Key mart tables (what's already computed)
- `mart.fact_bill_reconciliation` — FIFO unapplied-cash walk per party to identify "truly_open" vs "likely_closed" bills
- `mart.fact_collections_priority` — priority_score = balance × (1 + min(days_silent/60, 6)), behavior_flag = never_paid | gone_quiet | normal
- `mart.fact_party_balance` — authoritative net balance per party
- `mart.fact_bill_outstanding` — per-bill open amounts with age buckets
- `mart.dim_ledger` — has party_gstin field

## What the Recovery Engine Product Spec Says

**Core idea**: One atom (receivable as state machine: amount_at_risk, propensity_to_pay, relationship_value, consequence_available) + one daily loop (reconcile → rank → decide → execute → learn).

**7 agents**: Reconciliation (TDS+GSTR-2B aware), Prioritisation, Outreach (WhatsApp/IVR/Email/SMS + pay link), Promise (parse replies), Escalation (India-specific: GST-ITC, 43B(h), bureau, Samadhaan), Dispute, Orchestrator+Reflection.

**Business model**: ₹99/mo anchor + 1% of recovered overdue revenue via UPI Autopay/e-NACH.

## Scope Gap: What the Codebase Has vs What the Product Needs

### Already built (use as-is or extend)
- ✅ Tally extractor with all India-specific quirks handled
- ✅ Bill reconciliation (FIFO unapplied cash → true outstanding)
- ✅ Collections priority ranking + behavior flags
- ✅ GSTIN captured in dim_ledger
- ✅ Multi-tenant config pattern (config/companies/<key>/)
- ✅ Bills outstanding with aging, overdue amounts

### Phase 1 needs to be built
- ❌ TDS-aware bank reconciliation (match bank credits to invoices accounting for TDS shaved at source — bank shows ₹98,000 for ₹1,00,000 invoice)
- ❌ Outreach agent: WhatsApp Business API (Meta), IVR (Exotel), Email, DLT-SMS
- ❌ Pay link generation: Razorpay/Cashfree per-invoice virtual accounts
- ❌ Promise agent: inbound reply parsing (WhatsApp webhooks), pause/resume dunning
- ❌ Self-serve SaaS onboarding (currently manual DB setup per tenant)
- ❌ ₹99 + 1% billing infrastructure

### Phase 2 needs
- GSTN/GSP integration (IRN lookup, GSTR-2B check for ITC evidence)
- 43B(h) seasonal urgency engine (MSME Udyam status check)
- Registered bureau furnisher (CIBIL Commercial / CRIF)
- MSME Samadhaan + Section 138 auto-draft

### Phase 3 needs
- Cross-customer payment graph (debtor behavior across multiple sellers)
- Shared default registry
- AR→AP direct settlement

## Why: The business is stuck in "dashboard" territory — this codebase gives priority-ranked worklists but no action layer. The Recovery Engine adds the action layer: outreach, pay links, promise tracking, and escalation teeth.
