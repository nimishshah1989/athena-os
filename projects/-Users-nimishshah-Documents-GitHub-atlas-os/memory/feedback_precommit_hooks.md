---
name: Pre-commit hook issues on Mac
description: Two global pre-commit hooks had bugs that caused silent hangs during git commit on Mac
type: feedback
originSessionId: 8e81118a-d2d6-4373-893a-df3d658699f4
---
Two hooks in `~/.claude/` had bugs that caused `git commit` to hang for 5-10 minutes on every attempt, fixed on 2026-05-07:

1. **`~/.claude/hooks/lib/verify-chain.sh`** — Expected `.prev` field in decisions.jsonl but the file uses a mix of `.prev_hash` (Atlas format, line 1) and `.prev` (substantive-edit hook format, multi-line JSON, lines 2+). Hook now skips lines that aren't valid single-line JSON and accepts both field names.

2. **`~/.claude/gates/gate-pragma-coverage.sh`** — `grep -rlE "# *pragma: *finance-critical" --include="*.py" .` was scanning `.venv/` (1017 Python files) causing the grep to take 5-10 minutes. Added `--exclude-dir=.venv --exclude-dir=__pycache__` etc. to the grep command.

**Why:** The `.venv/` directory has 1017 Python files on this machine and is not excluded from the grep even though it's in `.gitignore`.

**How to apply:** If `git commit` hangs after all named hooks show "Passed" in pre-commit output, check if the pragma coverage hook or chain verify hook is stuck. The fixes are already applied — but if new repos have this issue, apply the same exclusions.
