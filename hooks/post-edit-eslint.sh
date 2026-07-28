#!/usr/bin/env bash
# Run eslint on the edited TS/JS file (only if project has an eslint config).
set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -z "$FILE" ] && exit 0
[ ! -f "$FILE" ] && exit 0
echo "$FILE" | grep -qE '\.(ts|tsx|js|jsx)$' || exit 0

ROOT="$PWD"
while [ "$ROOT" != "/" ] && [ ! -f "$ROOT/package.json" ]; do
  ROOT=$(dirname "$ROOT")
done
[ "$ROOT" = "/" ] && exit 0

HAS_ESLINT=0
for cfg in .eslintrc .eslintrc.json .eslintrc.yml .eslintrc.yaml .eslintrc.js eslint.config.js eslint.config.mjs eslint.config.cjs; do
  [ -f "$ROOT/$cfg" ] && HAS_ESLINT=1 && break
done
[ "$HAS_ESLINT" = "0" ] && exit 0
[ "${FORGE_ALLOW_LINT_ERRORS:-0}" = "1" ] && exit 0

cd "$ROOT"
ERRORS=$(npx --no-install eslint --format json "$FILE" 2>/dev/null | jq '[.[].errorCount] | add // 0' 2>/dev/null || echo 0)

if [ "$ERRORS" -gt 0 ]; then
  echo "ESLINT ERRORS: $ERRORS in $FILE" >&2
  npx --no-install eslint "$FILE" 2>&1 | tail -25 >&2
  echo "" >&2
  echo "Fix lint errors. Bypass: export FORGE_ALLOW_LINT_ERRORS=1" >&2
  exit 1
fi
exit 0
