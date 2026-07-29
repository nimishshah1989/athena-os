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

# --- tier 1: large SOURCE file in a serena project → route to symbol lookup ---
# Measured on atlas-os: whole-file 20k tok, native grep+slice 1198, serena 725.
# Only fires where serena is actually activated, so it can never be dead advice.
if [ "$SIZE" -le "$MAX_BYTES" ]; then
  case "$FILE" in
    *.py|*.ts|*.tsx|*.js|*.jsx|*.go|*.rs|*.java|*.rb|*.php|*.cs) ;;
    *) exit 0 ;;
  esac
  SRC_LINES=$(wc -l < "$FILE" 2>/dev/null | tr -d ' '); SRC_LINES=${SRC_LINES:-0}
  [ "$SRC_LINES" -le "${CLAUDE_SYMBOL_ROUTE_LINES:-600}" ] && exit 0
  ROOT=$(cd "$(dirname "$FILE")" 2>/dev/null && pwd) || exit 0
  while [ "$ROOT" != "/" ] && [ ! -d "$ROOT/.serena" ]; do ROOT=$(dirname "$ROOT"); done
  [ "$ROOT" = "/" ] && exit 0        # serena not activated here — say nothing
  REL=${FILE#"$ROOT"/}
  echo "BLOCKED: whole-file Read of $SRC_LINES lines (~$((SIZE / 3800))k tokens)." >&2
  echo "Serena is active on this project — use the symbol tools instead:" >&2
  echo "  get_symbols_overview(relative_path=\"$REL\")   # the map, ~175 tok" >&2
  echo "  find_symbol(name_path_pattern=\"<name>\", relative_path=\"$REL\", include_body=true)" >&2
  echo "Measured on atlas-os: 725 tok vs 1198 native vs 20k whole-file." >&2
  echo "Genuinely need the whole file? Read(..., limit=$SRC_LINES) says so explicitly." >&2
  exit 1
fi

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
