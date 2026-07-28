---
name: Learning Pipeline Status
description: AutoOptimize learning loop — fully wired, cost-optimised, Decimal/float fixed
type: project
---

## Current State (2026-03-25)

### The Closed Loop (WORKING)
1. **AutoOptimize** (6PM-8AM IST) → deterministic parameter sweep picks what to test → modifies strategy.py PARAMETERS
2. **Backtest engine** → runs 90-day backtest with modified params → scores with composite formula
3. **Compare** → KEEP (git commit) or REVERT (restore old value)
4. **After 10 experiments** → ONE Claude API call analyses the batch ($0.10/session)
5. **Signal Agent** reads PARAMETERS via `_get_effective_parameters()` → regime-aware filtering
6. **Learning Agent** writes post-mortems (template-based, no AI) → updates signal attribution
7. **Attribution flags** underperforming signal x regime combos → informs next AutoOptimize session

### Cost: ~$2.20/month
- AutoOptimize session analysis: $0.10/night × 22 trading days
- CIO Brief: rule-based (free)
- Learning notes: template-based (free)
- All scanning/regime/risk: pure math (free)

### Key Fixes Applied (2026-03-25)
- **Decimal/float crash**: `expire_on_commit=False` on backtest session + float() casts on all SimulationTrade field reads
- **calculate_position returns Decimal**: converted to float before storing on SimulationTrade in backtest
- **autooptimize_scoring.py**: float() casts on all DB values in compute_composite_score
- **Experiment cap**: MAX_EXPERIMENTS_PER_SESSION = 10
- **Claude removed from**: cio_agent.py (rule-based recommendation), learning_agent.py (template notes), autooptimize_proposals.py (deterministic sweep)
- **Claude kept in**: autooptimize_analysis.py (ONE call per session for batch analysis)

### Files
- `backend/intelligence/autooptimize.py` — main loop, start/stop, experiment cap
- `backend/intelligence/autooptimize_proposals.py` — deterministic sweep, strategy file mutation
- `backend/intelligence/autooptimize_scoring.py` — composite score with float() safety
- `backend/intelligence/autooptimize_analysis.py` — ONE AI call per session (new)
- `backend/intelligence/strategy.py` — PARAMETERS dict (only file AutoOptimize modifies)
- `backend/services/backtest_engine.py` — expire_on_commit=False, float() conversions

### Fixes Applied (2026-03-25 session 3)
- **Learning agent persistence**: Replaced in-memory `_processed_trade_ids` set with `ProcessedPostMortem` DB table (table 21). Survives container restarts.
- **Shadow portfolio**: track_setup() IS used — called from `/approve/{symbol}` and `/skip/{symbol}` endpoints. NOT dead code.
- **Production deployed**: Both backend + frontend containers rebuilt and live on EC2 (commit 74bdd83).

### Remaining Work
- No automated deployment pipeline (manual docker build + restart via SSH)
- Consider adding CI/CD auto-deploy on push to main (GitHub Actions workflow exists but may need secrets configured)
