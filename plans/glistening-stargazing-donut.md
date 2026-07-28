# CareerPlus — Full Build Plan (Athena-OS + Goal-Loops + Ponytail/Headroom)

## Context

Nimish wants to convert the workflow of `MadsLorentzen/ai-job-search` (a Claude Code prompt framework — no reusable code) into a commercial SaaS. A job seeker onboards once (CV upload + guided interview → structured profile), receives daily matched jobs with AI fit scores, generates tailored CV + cover-letter PDFs on demand (drafter → independent reviewer → revise), and tracks applications. The repo's real IP is its method: fit-evaluation-before-generation, drafter-reviewer separation, no-fabrication rule, PDF quality discipline.

**Approved direction (this session):** Global English market · full pipeline v1 · credit pricing (Stripe packs, 2 free credits) · no auto-submission ever (ToS/legal) · licensed job APIs only (Adzuna + JSearch), never scraping · Typst not LaTeX for PDFs · modular monolith: Next.js 15 + FastAPI + Supabase (Postgres/Auth/Storage/RLS) + procrastinate worker + Claude API · Swiss Modernism 2.0 design language (ui-ux-pro-max installed; design-system/MASTER.md as source of truth) · repo at `~/careerplus` (git initialized, empty).

**This round's additions (all confirmed by user):**
1. **Athena-OS — both senses.** Repo follows Athena conventions (memory bank / context discipline), AND the product borrows Athena's core thesis: **each user's job-search memory compounds** — every application, outcome, and edit makes future matches and documents smarter. Memory is user-owned and exportable (Athena philosophy).
2. **Ponytail** (`DietrichGebert/ponytail` plugin) — installed before any code; its decision ladder governs every file/function/class.
3. **Headroom** (`headroomlabs-ai/headroom`) — dev-time context compression AND in-product compression of generation-pipeline LLM calls (margin lever). Feature-flagged, never a hard dependency on the core path.
4. **Goal-loop architecture** — like Lemon: every engine component optimizes a measurable goal with a feedback signal; outcome capture in the data model from day one.
5. **Plan covers engineering + GTM.**

---

## 0. The goal-loop architecture (product model)

Shared state / score function: `applications` + per-user `user_memory`. Every agent reads world-state, acts, observes a signal, and writes back what it learned.

| Agent | Goal (optimizes) | Signal (observes) | What compounds |
|---|---|---|---|
| **Profile** | Profile completeness & fidelity | parse coverage, gap-closure rate, user edit-distance on parsed sections | richer per-user memory; better parses via prompt tuning |
| **Matcher** (P3) | Interviews per surfaced job (not clicks) | save / dismiss / apply on each match; downstream outcomes | per-user preference model + global job-source quality priors |
| **Generator** (P2) | Application → response rate | tracked outcomes: response / interview / rejection / silence | framing strategies per industry & seniority (versioned prompt templates + eval set) |
| **Reviewer** (P2) | Defects reaching the user | user edit-distance on drafts, regeneration requests | critique rubric weights |
| **Reflection** (P4) | Interviews per credit spent (the metric users feel) | funnel metrics per user and cohort | adjusts matcher thresholds, generator strategy selection, gap prompts |

Consequences for the schema (non-negotiable, ships with P2): `applications` table with a status state machine (`generated → submitted → response → interview → offer/rejected/silent`, user-reported) and an append-only `outcome_events` table. Outcome data not captured from day one is lost forever.

**Per-user compounding memory (Athena in the product):** `user_memory` table — structured facts per user (`kind`: preference | strength | outcome_pattern | style; `content` JSONB; `source`; `confidence`), written by the Profile agent (onboarding), the Generator (what was emphasized), and the Reflection loop (what worked). Injected into fit-eval and generation prompts. Exportable as markdown from day one (`GET /me/memory/export`) — "your memory, your data" is a marketing feature, not just architecture.

## 0b. Athena-OS repo conventions

One source of truth, Athena naming mapped onto the global standard (no duplication — Ponytail rule):
- `.context/memory_bank/productContext.md` → thin pointer + product soul (what CareerPlus is, the compounding thesis)
- `.context/memory_bank/constraints.md` → engineering guardrails for this repo (stack rules, RLS, no-fabrication, credit safety)
- `.context/memory_bank/activeContext.md` → canonical **STATE.md** content (STATE.md becomes a symlink or is retired in favor of it; pick one at T1, log in DECISIONS-LOG)
- `SPEC.md`, `DECISIONS-LOG.md`, `HANDOFF.md`, `research/` per global standard
- Session discipline: update activeContext + HANDOFF at every commit boundary (existing global rule, now Athena-framed)

## 0c. Dev tooling (before first line of code)

- **Ponytail:** `/plugin marketplace add DietrichGebert/ponytail` → `/plugin install ponytail@ponytail`. Decision ladder applies to every proposed file/function/class.
- **Headroom (dev):** install CLI/proxy locally; use to compress repo context, SQL, prior-session content fed into coding turns.
- **Headroom (product):** `backend/app/services/compression.py` — our own thin interface wrapping `headroom.compress()`, behind `HEADROOM_ENABLED` flag with pass-through fallback. A/B the generation quality before defaulting on (global rule: no bleeding-edge hard dependency on a core path). Log tokens-before/after per call — this is the margin dashboard.

---

## 1. Phase plan overview

| Phase | Delivers | Sellable? |
|---|---|---|
| **P0** Tooling + scaffold | Ponytail/Headroom active, repo per Athena conventions, design system persisted, docs seeded | — |
| **P1** Foundation | Auth+RLS, profile intake (CV upload → Claude parse → wizard), credits+Stripe, user_memory v0 | — |
| **P2** Generation engine | Fit-eval → drafter → reviewer → revise → Typst PDFs; applications + outcome_events capture; Headroom wrapper; credit debit | **Yes — the wedge is live here** |
| **P3** Jobs + matching | Adzuna/JSearch ingestion, dedup, nightly matching with fit scores, feed UI, match feedback signals | Yes (full pipeline) |
| **P4** Tracker + reflection + launch | Tracker dashboard, outcome reporting UX, Reflection loop v1, email digests, billing polish, security pass, launch | **Launch** |

GTM workstream runs parallel from P2 (§5).

---

## 2. Phase 1 detail (execute first)

### Decisions (logged to DECISIONS-LOG at T1)
- Queue: **procrastinate v3** (Postgres LISTEN/NOTIFY; no Redis; worker uses direct connection, not the transaction pooler)
- CV parsing: **Claude native PDF input** (base64 document block — handles scanned CVs via vision; no AGPL PyMuPDF) + **python-docx** for DOCX; model `claude-sonnet-5` via `messages.parse()` with Pydantic schema; no temperature/top_p; log token usage per parse
- Monorepo: plain folders + root Makefile
- Supabase: CLI local stack for dev; one cloud project for staging; MCP unauthenticated this session → CLI + env keys
- Migrations: **Alembic owns the entire `public` schema including RLS policies and triggers** (`op.execute`); `supabase/migrations/` intentionally empty with README; Supabase CLI owns config.toml (auth providers, buckets)
- JWT verification: PyJWT; HS256 + shared secret locally, `SUPABASE_JWT_ALG=ES256` + JWKS switch for cloud
- Backend never uses supabase-py for data — SQLAlchemy direct; Storage via httpx + service_role (server-only)

### Data model (Phase 1 tables; every table: UUID pk, tz-aware created/updated, deleted_at, FKs indexed, money NUMERIC, RLS ON + FORCED)
- `profiles` — 1:1 `auth.users` (same id), email, full_name, onboarding_status, locale
- `candidate_profiles` — user_id (unique-active), headline, summary, education/experience/skills/preferences JSONB (Pydantic-validated, `schema_version`), source, source_document_id, completeness JSONB
- `documents` — kind='uploaded_cv', bucket/path, mime (pdf|docx, magic-byte checked), size ≤10MB, parse_status pending→processing→parsed/failed, parse_error
- `credit_ledger` — append-only, integer `delta`≠0, reason enum, **unique idempotency_key** (`signup:{uid}`, `stripe:{event_id}`), amount_paid NUMERIC(10,2)+currency, balance=SUM(delta)
- `stripe_customers`, `stripe_webhook_events` — service-role only (RLS enabled, zero client policies)
- `user_memory` — v0: user_id, kind, content JSONB, source, confidence; written by parse pipeline (style/strengths) — schema ships now so P2 can write to it
- Trigger (SECURITY DEFINER, Alembic): on `auth.users` insert → create profile + grant 2 signup credits (idempotent ON CONFLICT)
- RLS shape: users SELECT/UPDATE own `profiles`; SELECT-only own `candidate_profiles`/`documents`/`credit_ledger`/`user_memory` (all writes via FastAPI service role); `(select auth.uid())` caching pattern; REVOKE belt-and-braces; Storage policies scope `cv-uploads` (+`generated-docs` bucket created now) to `{user_id}/` folders

### API surface (`/api/v1`, bearer JWT)
`GET /health`, `GET /health/ready` · `GET|PATCH /me` · `POST /documents/cv` (202 + enqueue parse) · `GET /documents`, `GET /documents/{id}` (wizard polling) · `GET|PUT /candidate-profile`, `PATCH /candidate-profile/sections/{section}`, `GET /candidate-profile/gaps` (pure function → drives interview form) · `GET /credits/balance`, `GET /credits/ledger` · `GET /billing/packs`, `POST /billing/checkout-session` · `POST /webhooks/stripe` (signature-verified, event-inbox idempotent: replay → 200 no-op; handler error → 500 so Stripe retries) · `GET /me/memory/export` (markdown)

### Ordered tasks
- **T0 (user):** Supabase CLI + Docker; Supabase cloud project (URL, anon, service_role, JWT secret); Google OAuth client; Stripe account + test keys + credit-pack Prices + stripe CLI; ANTHROPIC_API_KEY
- **T1** Repo scaffold: layout below, Athena context files (§0b), CLAUDE.md (frontmatter: `project: careerplus · domain: careertech · regime: [gdpr] · stack: [fastapi, nextjs, supabase] · has_frontend: true`), SPEC.md (freeze P1 scope + goal-loop model), DECISIONS-LOG seeded, Makefile, .env.example (no values), design-system/MASTER.md, first commit
- **T2** Supabase local stack: config.toml (email+Google auth, private buckets `cv-uploads`/`generated-docs` with mime/size limits, site_url), migrations/README ("Alembic owns public")
- **T3** Backend skeleton: uv + Python 3.12; FastAPI app factory, pydantic-settings fail-fast config, structlog (request-id middleware; **no PII in logs**), CORS, lifespan (engine + procrastinate connector), health endpoints; ruff+mypy clean
- **T4** Models + migrations: mixins (UUID pk server_default gen_random_uuid, tz timestamps, soft delete); migration 001 tables+indexes, 002 RLS+policies+triggers+storage policies (SQL via op.execute, downgrades implemented). Verify: upgrade→downgrade→upgrade clean; role-switching SQL tests prove isolation; new signup → profile + 2 credits
- **T5** Auth dependency: PyJWT verify (aud=authenticated), CurrentUser loads profile, 401/403 paths; wire /me
- **T6** Storage service + upload endpoint: magic-byte mime check, path `{user_id}/{doc_id}/{filename}`, 202 + enqueue
- **T7** Parse pipeline: procrastinate task (retry=3, backoff): fetch bytes → PDF as document block / DOCX via python-docx → `claude.py` `messages.parse(CandidateProfileData)` with "extract, never invent, leave unknown empty" system prompt → upsert candidate_profile + seed user_memory (style/strengths) → status transitions; failures set failed+parse_error. `procrastinate schema --apply` in `make db-up`
- **T8** Candidate profile endpoints + gaps function (pure, golden-tested); PATCH flips source→mixed
- **T9** Credits + Stripe: ledger service (idempotent grant/debit), checkout session (client_reference_id, metadata: user/pack/credits), webhook inbox per API spec; `stripe listen` manual verify — replay does not double-credit
- **T10** Backend hardening: coverage ≥80% (`--cov-fail-under=80`), respx assert-all-mocked (zero external calls in tests), ruff+mypy gates
- **T11** Frontend scaffold + design system: Next 15 + TS + Tailwind; tokens from MASTER.md — warm paper ground, near-black ink, single green accent family, 12-col grid, Schibsted Grotesk / Source Serif 4 / tabular-nums mono via next/font; hand-rolled primitives (Button, Field, Card, Stepper, Table) — no shadcn; `@supabase/ssr` auth clients; typed API wrapper; `/dev/tokens` style-guide page
- **T12** Auth screens + middleware (login/signup/OAuth callback; onboarding redirect)
- **T13** Onboarding wizard: Upload → Parsing (poll) → Review (section forms) → Interview (gap-driven form, not chat) → Done
- **T14** Profile page (read + per-section edit + completeness)
- **T15** Billing page (balance tabular, packs, checkout redirect, ledger)
- **T16** Playwright smoke: auth redirect, signup→onboarding, wizard happy-path (API mocked), billing render; `make e2e`
- **T17** Sign-off: checklist §4; migrations to cloud dev project; **Supabase security advisors clean** (dashboard — user action); STATE/activeContext + HANDOFF updated

### Repo layout (abbreviated)
```
careerplus/
├── CLAUDE.md  SPEC.md  DECISIONS-LOG.md  HANDOFF.md  Makefile  .env.example
├── .context/memory_bank/{productContext,constraints,activeContext}.md
├── design-system/MASTER.md          ├── research/   ├── docs/
├── supabase/{config.toml, migrations/README.md}
├── backend/
│   ├── alembic/versions/            ├── pyproject.toml
│   └── app/{main,config,logging,db,auth}.py
│       ├── models/{base,profile,candidate_profile,document,credits,stripe,user_memory}.py
│       ├── schemas/  api/  services/{storage,cv_parser,claude,credits,stripe_service,compression}.py
│       └── jobs/{app,parse_cv}.py
│   └── tests/ (conftest: rollback fixtures, ASGI client, JWT factory, factory_boy)
└── frontend/src/app/{(auth)/login,signup, auth/callback, (app)/onboarding,profile,billing,dashboard}
    └── src/{components/ui, lib/{supabase,api.ts}}  e2e/
```

---

## 3. Phases 2–4 (planned now, spec'd per-phase before build)

### P2 — Generation engine (the wedge)
- `jobs` (pasted-URL/description job records), `generations` (pipeline runs, token costs, prompt versions), `applications` + `outcome_events` (goal-loop substrate), `documents.kind` extended (generated_cv, generated_cover_letter)
- Pipeline (procrastinate chain): parse posting → **fit-eval shown before credit spend** (Haiku for scoring) → credit debit (idempotent, refund on pipeline failure) → drafter (Sonnet; profile + user_memory + posting) → independent reviewer (fresh context; company research via web tool) → revise → **Typst** compile with programmatic layout checks (2-page CV, 1-page letter, no orphans) → PDFs to `generated-docs` + "what changed and why"
- All pipeline LLM calls through `compression.py` (Headroom, flagged); prompt templates versioned in-repo with an eval set (golden postings × profiles) so template changes are testable
- No-fabrication verifier: claims in output cross-checked against profile JSON; violations fail the run
- Frontend: paste-a-job flow, fit report (Source Serif narrative), PDF preview, download, regeneration with feedback

### P3 — Jobs + matching
- Adzuna + JSearch connectors (rate-limited, retried, cost-logged); normalized `job_postings` with dedup (URL canonical + fuzzy title/company); nightly per-user matching (Haiku batch fit-scores vs profile + user_memory); `match_feedback` (save/dismiss/apply) feeding the Matcher loop
- Feed UI: daily matches ranked by fit, score breakdown, one-click into P2 generation
- Vendor terms verified and API applications submitted during P1 (lead time)

### P4 — Tracker + reflection + launch
- Tracker dashboard (status board, dates, follow-ups, outcome prompts — "did they respond?" nudges close the loop); email digests (matches + follow-up reminders)
- Reflection v1: scheduled job computing per-user + cohort funnel metrics; writes user_memory outcome_patterns; surfaces "what's working" to the user (retention feature)
- Launch hardening: security pass (advisors, secret scan, rate limits on auth/upload/webhooks), billing edge cases, GDPR basics (export = memory export + data delete), status/ops runbook

---

## 4. Verification (per phase gate; P1 concrete)
1. Clean clone → `supabase start` + `make db-up` + `make dev-backend` + `make dev-frontend` all green
2. `make test` ≥80% coverage, zero external network; ruff + mypy clean; migration round-trip test
3. RLS: role-switching tests pass; cloud advisors report no errors
4. Secrets: `git grep` for `sk-ant|sk_test|sk_live|service_role` values clean; .env gitignored
5. E2E manual: signup (email+Google) → 2 credits → real PDF CV parsed by claude-sonnet-5 → review → gaps → complete → test-mode purchase → balance +once (webhook replay = no double credit) → memory export returns markdown
6. Worker kill mid-parse → retry, no wedged `processing`
7. Playwright smoke green; docs/context files current; Ponytail active (plugin listed); Headroom dev proxy functional; token-usage logging visible for parse calls

---

## 5. GTM plan (startup workstream, parallel from P2)

- **Positioning:** "The job-search copilot that learns from every application." Against Teal/Careerflow/Kickresume (template mills): CareerPlus evaluates fit *before* you spend anything, refuses to fabricate, and compounds — your 30th application is measurably sharper than your 1st. Athena-inspired trust line: your career memory is yours — exportable markdown, delete anytime.
- **Wedge audience:** English-speaking remote/relocating knowledge workers (tech, product, data, marketing) applying in volume — highest pain, highest willingness to pay per interview.
- **Pricing (v1 hypothesis, test at P2 beta):** 2 free credits → packs $9/5, $29/20, $59/50; inference cost $0.15–0.40/generation (Headroom pushes floor lower) → 70–90% gross margin. Watch: refund policy on failed runs (auto-refund credit), fraud (disposable emails farming free credits → device/IP heuristics at P4).
- **Channels, in order:** (1) build-in-public + Reddit r/jobsearch, r/resumes, r/cscareerquestions value-posts; (2) Product Hunt at P4 launch; (3) programmatic SEO from P3 job data (role/city fit-guide pages — licensed data only, check Adzuna display terms); (4) career-coach affiliate credits; (5) LinkedIn founder content. No paid ads until credit-purchase conversion is known.
- **Metrics:** activation = onboarding complete; aha = first fit report; conversion = free→paid credit purchase; retention lever = interviews-per-credit (the Reflection loop's own goal — product architecture and GTM optimize the same number).
- **Legal/compliance flags:** job-data vendor display terms; AI-generated-content disclosure norms per market; GDPR (EU users in scope from day one) — export/delete shipped at P4; no PII in logs (existing rule).

## 6. User action items (start now, parallel to P0/P1)
1. Supabase cloud project + keys · 2. Google OAuth client · 3. Stripe account, test keys, credit-pack Prices, stripe CLI · 4. Anthropic API key · 5. Adzuna + RapidAPI(JSearch) developer applications (lead time — needed by P3) · 6. Confirm working name "CareerPlus" is fine to keep (domain check when branding starts)

## 7. Execution notes
- Backend before frontend inside every phase; each task ends verified; Ponytail ladder on every artifact; Headroom on every dev turn with large context
- Commit boundaries: update activeContext/STATE + HANDOFF + DECISIONS-LOG line, then commit (+push once remote exists)
- Phase gates: each of P2–P4 gets its own spec + plan cycle against this document before code
