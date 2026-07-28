#!/usr/bin/env bash
# FIX #3 companion: at session start, scan the project for json_encoders.*Decimal.
# Cache the result so pre-edit-decimal-encoder-fastapi.sh doesn't false-positive on
# per-route handlers when the encoder is centralized in a base model module.
#
# Cache lives at $PROJECT_ROOT/.ruflo/has-decimal-encoder ("true" or "false").
# Re-run manually anytime: bash ~/.claude/hooks/session-start-scan-encoder.sh
set -euo pipefail

# Find project root
ROOT="$PWD"
while [ "$ROOT" != "/" ] && [ ! -f "$ROOT/CLAUDE.md" ]; do
  ROOT=$(dirname "$ROOT")
done
[ "$ROOT" = "/" ] && exit 0

# Only fintech projects need this scan
if [ -f "$ROOT/CLAUDE.md" ]; then
  if ! head -20 "$ROOT/CLAUDE.md" | grep -qiE "(domain:.*fintech|regime:.*\b(SEBI|RBI|IRDAI|PFRDA)\b)"; then
    exit 0
  fi
fi

mkdir -p "$ROOT/.ruflo"
CACHE="$ROOT/.ruflo/has-decimal-encoder"

# Find any Python file with json_encoders ... Decimal anywhere in the project
FOUND="false"
if grep -rlE "json_encoders.*Decimal" --include="*.py" \
    --exclude-dir=.venv --exclude-dir=venv --exclude-dir=__pycache__ \
    --exclude-dir=.mypy_cache --exclude-dir=dist --exclude-dir=build \
    --exclude-dir=node_modules --exclude-dir=.git \
    "$ROOT" 2>/dev/null | head -1 | grep -q .; then
  FOUND="true"
fi

echo "$FOUND" > "$CACHE"
exit 0
