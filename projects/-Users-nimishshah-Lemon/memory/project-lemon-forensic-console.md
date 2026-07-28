---
name: project-lemon-forensic-console
description: "project-lemon (Dhwanil's live codebase) vs the Lemon strategy repo; the forensic + console correction-loop build on branch nimish (pushed to origin)"
metadata: 
  node_type: memory
  type: project
  originSessionId: 7289a408-0fca-4e62-81df-0a00a4607177
---

# project-lemon — forensic/anomaly track + owner console

Two codebases, don't conflate them:
- **`/Users/nimishshah/Lemon`** — the founder's *strategy/command-center* repo (SPEC, DECISIONS, research/, docs/, HTML vision docs). No product code. This is where the Recovery Engine plan lives (see [[project-recovery-engine]]).
- **`/Users/nimishshah/project-lemon`** — co-founder **Dhwanil's LIVE codebase**: a deterministic Tally-truth pipeline (`pipeline/`, zones bronze→canonical→truth→durable) + an owner-facing **console** (`console/`, FastAPI + Jinja2 + htmx, plain-language). This is where actual building happens. Distinct from the `tally-analytics-warehouse` *reference* implementation.

## Branch model + deploy
- Long-lived personal branch **`nimish`** on origin (`github.com/dhwanil-d/project-lemon`), Dhwanil owns `main`. NEVER merge nimish→main. Parallel-build model: Nimish/Claude build our version, Dhwanil builds his frontend, the better one wins. Work continues ON `nimish` (don't recreate feat branches — that caused a commit-on-wrong-branch slip once).
- **Live link = Render** (not Vercel — Vercel is for Dhwanil's frontend; our console is a Python FastAPI server). `render.yaml` blueprint + `console/DEPLOY.md` are on the branch. Secrets (`LEMON_DB_URL` Supabase pooler URI, `LEMON_USERS`) set in Render dashboard only, `sync:false`, never git/chat.
- **Forensic findings on real data need a pipeline re-run** with the branch code on the raw Tally CSVs (Dhwanil's machine — not present locally) + reload to Supabase. The console alone shows real companies but only whatever findings are already loaded.

## What was built (all on branch `nimish`)
The **anomaly/forensic track** — separate from the Recovery Engine's 7 collection agents:
1. **12 deterministic forensic rules** (`pipeline/src/truth/forensics.py`) — journal-settle, unreferenced-cash, duplicate-bill, group-sprawl, no-GSTIN, advance-in-debtor, concentration, round-receipt, march-spike, roundtrip, lapping, split-invoice. Pure functions, `F-*` rule codes, CRITICAL/MAJOR/MINOR. NOT RAG — auditable by design. Emitted into the `finding` table via `sqlout.py`.
2. **Console 4-level framework** — portfolio home `/` (per-company junk headline + per-rule issues/₹/entries table) → rule register `/t/{t}/findings` (table: nature/validates/issues/₹/entries per check + tabs) → rule list `?rule=F-*` (party/found/amount/entries + inline 3-verdict, rows clickable) → **issue evidence** `/t/{t}/finding/{id}` (verdict + "why we flagged" + THE ACTUAL ENTRIES via per-rule `_EVIDENCE` SQL builders reading warehouse tables live, capped 250). Structural notes on `?view=flat`. Metadata dicts in queries.py: `_RULE_SHORT/_NATURE/_VALIDATES/_IMPACT/_SEV/_MONEY_KEY/_ENTRIES_KEY`. **fmt.inr()/inr_compact() coerce Decimal→int** (Postgres SUM() arrives as Decimal, breaks `{r:02d}`). Evidence SQL: no `%` modulo (psycopg placeholder clash) — use integer division. `db.py _pg_normalize()` percent-encodes raw passwords in LEMON_DB_URL.
3. **3-stage correction loop** — the answer to "Tally is the single source, so issues persist unless the entries are actually fixed":
   - Stage 1 overlay: owner confirms/resolves/mutes a finding (`finding_resolution` durable table; `confirmed` = real issue).
   - Stage 2 correction pack (`/t/{tenant}/corrections`): confirmed findings → accountant-executable Tally instructions. Only 6 rules are mechanical fixes; the rest route to "investigate". Printable.
   - Stage 3 round-trip: a confirmed finding absent from the next build = the fix landed (rule stopped firing) → "cleared" banner. No schema change; durable zone persists across syncs.

**Read-only posture (D-021):** Lemon NEVER writes to Tally. The accountant executes; the next sync verifies.

## Reconciliation guard — every finding's number MUST tie to its evidence
- **`queries.reconcile(db, tenant)`** + `console/reconcile.py` + a suite test. Per rule a `_RECONCILE_MODE`: **sum** (evidence Σ == badge ₹), **count** (rows == badge n), **balance**/**flow** (no numeric tie; UI labels number as balance, rows as context). Run `reconcile.py` after EVERY warehouse load — must print 0. `finding_detail` is mode-aware.
- **Two root bugs it caught (fixed in forensics.py — do NOT reintroduce):** (1) rules aggregated per FY-file → badge = one year, evidence = all → now aggregate per ledger lifetime; (2) **Tally GUIDs repeat across FY files (~1,500 in reliable)** — `_effective` keyed vouchers by guid alone → entries borrowed wrong-year vouchers → FABRICATED findings. `_effective` now keys by `(file_id, guid)`; every entry→voucher join (rule AND evidence SQL) must include file_id or GUID fan-out inflates sums.
- Journal evidence shows the **counter-account** ("Booked against" = largest opposite leg): Bad Debts=write-off, TDS=legit, inter-branch=transfer — the "why".

## Semantic audit (owner-driven, 2026-07) — reconciliation alone is NOT validation
A finding can tie badge==evidence and still be FALSE (OAIC: journals countered by BANK = receipts typed as journals, not write-offs). Discipline: for each rule, pull real flagged data and try to REFUTE it before shipping. Outcomes baked into forensics.py:
- **journal-settle** counts only write-down-like counters; `_JOURNAL_INNOCENT_COUNTERS` = bank/cash (money arrived), sundry_debtor/creditor (transfer/netting), duty_tax_* (TDS). Innocent sums kept as detail context (`bank_countered_paise`, `transfer_tax_paise`). CRITICAL went 189→17 across tenants.
- **cash-unref** = gross on-account MINUS engine-matched (inference settlements' voucher_guids); fires on >30% ratio OR ≥₹1cr absolute (`unref_abs_warn`). Warehouse `_hydrate` supplies settlements to the truth stub.
- **dup-bill** = MINOR verify-flag (real data: sequential invoice numbers = batch dispatch); exposure = m×(n−1); reconcile mode `count`.
- **`_RULE_METHOD`** in queries.py: each rule's thresholds/exclusions rendered on rule + finding pages ("How it decides") — keep in lockstep with forensics.py when thresholds change.
- **Finding page = case file** (owner couldn't act on a bare verdict ask): summary → party standing TODAY (party_truth, + "this is NOT about the balance") → evidence → `_counter_reading()`/`_RULE_QUESTIONS` (likely cause → what to ask the accountant; counter-account NAME is interpreted: DEPOSIT=set-off, SUSPENSE=no explanation) → ±45d ledger window with flagged voucher highlighted (reuses party_statement) → verdict with consequences stated → mechanics in <details>. Design law: every verdict ask must carry the material to reach the verdict on the same page.

## Working facts
- Python **3.10+** required (`str | None`); system `python3` is 3.9 → run tests with **`uv run pytest`** (console: 33 pass; pipeline: 38 pass / 68 data-gated-skips).
- Supabase MCP is the pipeline's *output* store (read-only); raw Tally CSVs are gitignored on Dhwanil's machine.
- **Security action still open:** a Supabase access token was pasted in chat this session — user deferred rotation ("change later"). Rotate at the provider; `--read-only` limits the server, not the token.
