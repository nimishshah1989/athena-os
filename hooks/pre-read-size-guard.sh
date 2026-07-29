#!/usr/bin/env bash
# Stop a single tool result from swallowing the context window.
#
# The 70% ceiling is only checkable BETWEEN turns. One Read of a huge file jumps
# from 20% to over 100% inside a single turn, past every threshold — which is
# exactly what happened on 2026-07-29 with a 2.5MB artifact export, three times.
# Auto-compact cannot catch that. This can.
#
# Only blocks an UNBOUNDED read of a large file. A sliced read (limit/offset) is
# always allowed, so the file stays reachable — you just have to aim.
set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
LIMIT=$(echo "$INPUT" | jq -r '.tool_input.limit // empty')
[ -z "$FILE" ] && exit 0
[ -n "$LIMIT" ] && exit 0          # a bounded read is always fine
[ -f "$FILE" ] || exit 0

MAX_BYTES=${CLAUDE_READ_GUARD_BYTES:-262144}   # 256KB ≈ 65k tokens
SIZE=$(stat -f %z "$FILE" 2>/dev/null || stat -c %s "$FILE" 2>/dev/null || echo 0)
[ "$SIZE" -le "$MAX_BYTES" ] && exit 0

LINES=$(wc -l < "$FILE" 2>/dev/null | tr -d ' ')
LINES=${LINES:-0}
KB=$((SIZE / 1024))

echo "BLOCKED: unbounded Read of a ${KB}KB file ($LINES lines) — ~$((SIZE / 4000))k tokens." >&2
echo "One tool result this size can exhaust the context window in a single turn." >&2
echo "" >&2
echo "Read a slice instead:  Read(file_path, offset=N, limit=200)" >&2
if [ "$LINES" -gt 0 ] && [ "$((SIZE / (LINES + 1)))" -gt 5000 ]; then
  echo "Heads up: average line is $((SIZE / (LINES + 1))) bytes — this is minified or an" >&2
  echo "export wrapper. Find the payload first:" >&2
  echo "  awk '{print length\": line \"NR}' '$FILE' | sort -rn | head -5" >&2
fi
echo "Or extract what you need with grep/jq/python and read that." >&2
echo "Override for one session: export CLAUDE_READ_GUARD_BYTES=999999999" >&2
exit 1
