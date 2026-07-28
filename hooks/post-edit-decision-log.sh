#!/usr/bin/env bash
# Append substantive edits to <project>/decisions.jsonl with SHA-256 prev-hash chain.
# FIX #1: skip noise — small diffs in non-code files don't get logged.
set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
NEW_CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // empty')
[ -z "$FILE" ] && exit 0

# Find project root
ROOT="$PWD"
while [ "$ROOT" != "/" ] && [ ! -d "$ROOT/.git" ] && [ ! -f "$ROOT/CLAUDE.md" ]; do
  ROOT=$(dirname "$ROOT")
done
[ "$ROOT" = "/" ] && exit 0

# FIX #1 noise filter
DIFF_LINES=$(printf '%s\n' "$NEW_CONTENT" | wc -l | tr -d ' ')
IS_CODE=0
echo "$FILE" | grep -qE '\.(py|ts|tsx|jsx|js|go|rs|java|rb|sql|sh)$' && IS_CODE=1
if [ "$IS_CODE" = "0" ] && [ "$DIFF_LINES" -lt 5 ]; then
  exit 0
fi

LOG="$ROOT/decisions.jsonl"
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

if [ -f "$LOG" ] && [ -s "$LOG" ]; then
  PREV=$(tail -n 1 "$LOG" | sha256sum | cut -c1-16)
else
  PREV="GENESIS"
fi

LINES_CHANGED="$DIFF_LINES"
LINE_JSON=$(jq -n --arg ts "$TS" --arg prev "$PREV" --arg tool "$TOOL" \
                  --arg file "$FILE" --argjson lines "$LINES_CHANGED" \
                  --arg session "${CLAUDE_SESSION_ID:-unknown}" \
  '{ts: $ts, prev: $prev, tool: $tool, file: $file, lines_changed: $lines, session_id: $session, schema_version: 1}')

echo "$LINE_JSON" >> "$LOG"
exit 0
