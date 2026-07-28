#!/usr/bin/env bash
# Block bare `except:` clauses in Python files.
set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // empty')

[ -z "$FILE" ] && exit 0
echo "$FILE" | grep -qE '\.py$' || exit 0
[ -z "$CONTENT" ] && exit 0

if echo "$CONTENT" | grep -qE "^\s*except\s*:"; then
  echo "BLOCKED: Bare 'except:' in $FILE" >&2
  echo "Catch named exception types. Bare except hides bugs." >&2
  echo "If you genuinely need to catch all, use 'except Exception:' with a comment explaining." >&2
  exit 1
fi
exit 0
