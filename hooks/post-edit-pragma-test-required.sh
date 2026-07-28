#!/usr/bin/env bash
# When a `# pragma: finance-critical` Python file is edited, ensure a test file exists.
# This is the cheap per-edit check. The full coverage gate runs on commit
# via gates/gate-pragma-coverage.sh (FIX #4).
set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -z "$FILE" ] && exit 0
[ ! -f "$FILE" ] && exit 0
echo "$FILE" | grep -qE '\.py$' || exit 0

grep -qE "# *pragma: *finance-critical" "$FILE" || exit 0
[ "${FORGE_ALLOW_NO_TEST:-0}" = "1" ] && exit 0

BASE=$(basename "$FILE" .py)
ROOT="$PWD"
while [ "$ROOT" != "/" ] && [ ! -d "$ROOT/.git" ]; do
  ROOT=$(dirname "$ROOT")
done
[ "$ROOT" = "/" ] && ROOT="$PWD"

FOUND=0
for PATTERN in "test_${BASE}.py" "${BASE}_test.py" "${BASE}.test.py"; do
  if find "$ROOT" -type f -name "$PATTERN" 2>/dev/null | head -1 | grep -q .; then
    FOUND=1
    break
  fi
done

if [ "$FOUND" = "0" ]; then
  echo "BLOCKED: $FILE marked '# pragma: finance-critical' but no test file found." >&2
  echo "Pragma files require tests. Create test_${BASE}.py before continuing." >&2
  echo "Coverage of pragma files is enforced on commit by claude-config/gates/gate-pragma-coverage.sh." >&2
  echo "Bypass during initial scaffolding only: export FORGE_ALLOW_NO_TEST=1" >&2
  exit 1
fi
exit 0
