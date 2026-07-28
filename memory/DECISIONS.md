# Permanent Architectural Decisions — JIP
# Claude never contradicts these. Ever.
---
[2024-Q4] Single Dockerfile — frontend + backend + Nginx in ONE container
Reason: Separate containers → CORS in production. Unfixable without this pattern.
Template: MF Pulse Dockerfile. Every new JIP module copies it.
Never: Vercel frontend + separate backend. Never separate Docker Compose services on different servers.

[2024-Q4] Decimal not float — all financial values
Reason: Float IEEE 754 → 1234.50 × 100 = 123449.999... Unacceptable for financial data.
Rule: from decimal import Decimal, ROUND_HALF_UP in every file touching money. Always via Decimal(str(x)).

[2025-Q1] RDS stays in jhaveritech account
Reason: Migration cost and risk > benefit. fie-db endpoint never changes.

[2025-Q1] Supabase service_role_key server-side only
Reason: Exposes full DB access to anyone who can view source.
Rule: No NEXT_PUBLIC_ on any secret key. Client-side uses anon_key only.

[2025-Q1] GitHub Actions auto-deploy gates: lint → typecheck → tests → deploy
Reason: Never ship broken code. tests must pass before deploy runs.

[2025-Q1] India Horizon composite scorer: piecewise-linear rescaling at P25/P50/P75/P90
Reason: Linear rescaling compressed top stocks — indistinguishable scores.
Verified: 86.7 composite on worked example = correct.

[2025-Q1] MF Recommendation Engine: QFS × 0.60 + FMSA × 0.40
Reason: Quantitative metrics more reliable than FM sector alignment.
13th metric: Category Alpha — mandatory, not optional.

[2025-Q1] Data residency — client data never leaves India
Client PII, CAS data, portfolio, behavioral scores → EC2/RDS only (Mumbai).
Supabase OK for: market data, fund metadata, screener results, app config, internal auth.
Never store anything identifying a client in Supabase. Ever.
