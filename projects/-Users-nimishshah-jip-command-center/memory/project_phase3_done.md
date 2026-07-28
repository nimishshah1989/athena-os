---
name: project_phase3_done
description: Phase 3 completed — auto-fix loop, scanner calibration, architecture scoring, background scans
type: project
---

## Phase 3 — Completed 2026-03-24

### What was built
1. **Auto-fix loop** (`backend/services/auto_fixer.py`) — scheduler-driven, processes open issues:
   - 3-stage validation: syntax check → test suite → Claude diff review (haiku)
   - Deletion detection gate: flags for human approval if >20 lines removed, functions deleted, or DROP/DELETE ops
   - Runs daily at 2:20 AM IST, also manual trigger via POST /api/actions/auto-fix
   - Approval flow: GET /api/actions/issues/needs-approval + POST /api/actions/issues/{id}/approve-fix

2. **Scanner calibration** (honest scores):
   - Rate limiting: also checks Nginx configs
   - Session security: detects JWT stacks (cookie checks N/A)
   - Error leakage: only flags HTTP responses, not server-side logging
   - Auth coverage: detects global middleware/router-level auth
   - Financial decimal: removed "score", "value", "rate" from keywords
   - File modularity: threshold 300→400 lines, 500+ serious
   - Naming: removed data/result/item from bad names

3. **Architecture scoring**: added to /api/scores/scan, changed weekly→daily, creates Issue records for dims <70, fixed markdown fence stripping

4. **Background scans**: POST /scan returns immediately, frontend polls GET /scan/status every 3s

5. **Frontend UI**: Scan All + Auto-Fix All buttons on home page, Auto-Fix + Scan+AutoFix on Action Center, approval queue with per-issue approve button

### Current scores (2026-03-24)
| Platform | Security | Quality | Architecture |
|----------|----------|---------|-------------|
| Horizon | 72.9 | 40.0 | pending |
| Champion | 45.8 | 30.0 | pending |
| MF Pulse | 80.4 | 37.0 | pending |
| Market Pulse | 78.5 | 38.0 | pending |
| FIE2 | 65.4 | 38.0 | pending |

### Key failing checks across platforms
**Security (common failures):**
- auth_coverage: 0/10 (routes missing Depends())
- error_leakage: 0/5 (str(exc) in responses)
- input_validation: 0/5 (POST endpoints missing Pydantic models)
- session_security: 0/5 (no JWT/cookie detection working)
- financial_decimal: 4/8 (float used for financial values)
- https_enforcement: varies

**Code Quality (common failures):**
- test_coverage: 0-5/15 (most platforms have no tests — biggest weight)
- lint_errors: varies
- type_errors: varies
- file_modularity: varies (large files)
- function_complexity: varies
- dead_code: varies
- formatting: varies

### Next steps — get all scores to 90+
Need to fix actual platform codebases. Strategy:
1. Mechanical fixes first (ruff fix, black format, dead code removal) — no Claude needed
2. Auth/validation/error handling fixes via auto-fixer or direct PRs
3. Test coverage is the biggest quality gap (0/15 weight)
4. Architecture fixes based on Claude's dimension scores
