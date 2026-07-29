---
name: Osho Discourse Search Engine
description: Pure FTS5-based search over ~1.3M Osho discourse paragraphs with Hindi transliteration, deployed on EC2+Vercel
type: project
originSessionId: 54c47d62-fe1b-4181-83fe-65f5b6b04e1c
---
Osho Discourse Search — a verbatim search engine over ~20K Osho discourses.
Backend: FastAPI + SQLite FTS5 (BM25 ranking). Frontend: Next.js 14 on Vercel.
Deployed at osho-zeta.vercel.app, backend on EC2 13.206.34.214:8000.

**Why:** The user's collaborators (Osho community members) need reliable search across the full corpus including Hindi discourses. Key constraint: zero AI-generated content — every word must be Osho's verbatim text.

**How to apply:** Always test Hindi search alongside English. Ranking should favor events with more hits (not just best single paragraph). The user base includes elderly readers — font sizes and contrast matter. Never add AI paraphrasing or summaries.
