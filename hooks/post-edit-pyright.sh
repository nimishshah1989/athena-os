#!/usr/bin/env bash
# Run pyright on the edited Python file. Block on type errors.
set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -z "$FILE" ] && exit 0
[ ! -f "$FILE" ] && exit 0
echo "$FILE" | grep -qE '\.py$' || exit 0

command -v pyright > /dev/null || exit 0
[ "${FORGE_ALLOW_TYPE_ERRORS:-0}" = "1" ] && exit 0

# Pyright outputs JSON; count errorCount.
RAW=$(pyright --outputjson "$FILE" 2>/dev/null || true)
ERRORS=$(echo "$RAW" | jq -r '.summary.errorCount // 0' 2>/dev/null || echo 0)

if [ "$ERRORS" -gt 0 ]; then
  echo "TYPE ERRORS: $ERRORS in $FILE" >&2
  pyright "$FILE" 2>&1 | tail -25 >&2
  echo "" >&2
  echo "Fix type errors before claiming done. Bypass: export FORGE_ALLOW_TYPE_ERRORS=1" >&2
  exit 1
fi
exit 0
