# Architecture Corpus — JIP Platform
# Claude reads before any infrastructure/architecture decision.
---
[2025-Q1] Single container vs separate | Chosen: single | Rejected: Vercel+EC2, separate containers
[2025-Q1] EC2 over PaaS | Chosen: EC2 Mumbai | Rejected: Railway/Render/fly.io
Reason: Data sovereignty — client financial data stays in India. Cost control.
[2025-Q1] Supabase for new modules, RDS stays for existing
[2025-Q1] FastAPI over Django/Flask | Async native, Pydantic v2, fastest Python framework
