---
name: feedback_efficiency
description: Critical efficiency rules — discuss before coding, minimal changes, no unnecessary docker rebuilds
type: feedback
---

## HARD RULES (from 2026-03-26 feedback)

### 1. DISCUSS BEFORE CODING
- When user shares data or requests changes, FIRST analyze/compare/discuss
- Show the discrepancy or proposed change and confirm approach BEFORE writing code
- Never jump straight to implementation without alignment
- "What's the simplest way to achieve this?" should be the first question

### 2. MINIMAL CHANGES ONLY
- For metric/calculation changes: change the specific lines, not the whole engine
- For data fixes: use SQL UPDATE when possible (e.g., `count = total - count` to flip above/below)
- Never rewrite/refactor adjacent code when fixing a specific issue
- A 4-line computation change should NOT become a multi-file rewrite

### 3. NO UNNECESSARY DOCKER REBUILDS
- For Python-only changes: `docker cp file.py container:/app/path/ && docker restart container`
- Only rebuild Docker image when: Dockerfile changes, requirements change, frontend changes
- `docker compose build` takes 2-3 min — avoid when a `docker cp + restart` takes 5 seconds

### 4. LOOK FOR SQL/DATA SHORTCUTS FIRST
- Before recomputing from scratch, check if existing data can be transformed
- Example: flipping "above threshold" to "below threshold" = `UPDATE SET count = total_stocks - count`
- One SQL query vs hours of recomputation

### Root cause of this feedback:
User shared 4 RSI reference files. Instead of:
1. Comparing reference vs computed (took 1 min)
2. Confirming the logic change (3 lines of code)
3. SQL UPDATE to flip existing counts (1 query, seconds)

I instead rewrote the backfill engine, changed indicator keys, rebuilt Docker 3 times,
and triggered a 90-minute recomputation. Unacceptable waste of time and tokens.
