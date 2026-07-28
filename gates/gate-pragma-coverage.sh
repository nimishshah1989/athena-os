#!/usr/bin/env bash
# FIX #4 (heavy stage): on git commit, run pytest --cov on all `# pragma: finance-critical` files.
# Hard-fail if any pragma file has <100% line coverage.
# Wired by claude-config/templates/pre-commit-config.template.yaml as a pre-commit hook.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)" 2>/dev/null || { echo "not in a git repo"; exit 0; }

# Find pragma files (exclude venv, build artifacts, and cache dirs)
PRAGMA_FILES=$(grep -rlE "# *pragma: *finance-critical" --include="*.py" \
  --exclude-dir=.venv --exclude-dir=venv --exclude-dir=__pycache__ \
  --exclude-dir=.mypy_cache --exclude-dir=dist --exclude-dir=build \
  --exclude-dir=node_modules --exclude-dir=.git \
  . 2>/dev/null || true)
[ -z "$PRAGMA_FILES" ] && exit 0

[ "${FORGE_ALLOW_LOW_COVERAGE:-0}" = "1" ] && exit 0

command -v pytest > /dev/null || { echo "pytest not installed; install pytest pytest-cov to enforce pragma coverage"; exit 0; }

# Build separate --cov= flags (one per unique dir) — pytest-cov does not accept comma-separated paths
# Strip leading ./ so coverage.json keys match without prefix (e.g. atlas/signals not ./atlas/signals)
COV_FLAGS=$(echo "$PRAGMA_FILES" | xargs -n1 dirname | sort -u | sed 's|^\./||' | sed 's|^|--cov=|')

# Run pytest with coverage scoped to those dirs
# shellcheck disable=SC2086
pytest $COV_FLAGS --cov-report=json --cov-report=term -q -m "not integration" > /tmp/pragma-cov.out 2>&1 || {
  cat /tmp/pragma-cov.out >&2
  echo "" >&2
  echo "BLOCKED: pragma coverage gate — pytest run failed." >&2
  exit 1
}

# Parse coverage.json (pytest-cov default output: coverage.json in cwd)
[ -f coverage.json ] || { echo "no coverage.json produced"; exit 0; }

FAILED=""
for FILE in $PRAGMA_FILES; do
  # Strip leading ./ so the key matches coverage.json format (e.g. "atlas/signals/processor.py")
  REL=$(realpath --relative-to="$(pwd)" "$FILE" 2>/dev/null || echo "$FILE")
  REL="${REL#./}"
  PCT=$(jq -r --arg f "$REL" '.files[$f].summary.percent_covered // empty' coverage.json)
  if [ -z "$PCT" ]; then
    FAILED="$FAILED\n  $REL: no coverage data (test it or remove pragma)"
    continue
  fi
  # Compare floats via awk
  if awk "BEGIN { exit !($PCT < 100) }"; then
    FAILED="$FAILED\n  $REL: ${PCT}% (need 100%)"
  fi
done

if [ -n "$FAILED" ]; then
  echo "BLOCKED: pragma coverage gate" >&2
  printf "Pragma-tagged files below 100%% coverage:%b\n" "$FAILED" >&2
  echo "" >&2
  echo "Fix coverage or remove the pragma. Bypass: FORGE_ALLOW_LOW_COVERAGE=1 git commit ..." >&2
  exit 1
fi

echo "pragma coverage gate: OK"
exit 0
