#!/usr/bin/env bash
# FIX #6: append a daily token-spend snapshot from ruflo-cost-tracker into
# $PROJECT_ROOT/.ruflo/cost-history.jsonl. Provides week-over-week visibility
# beyond Ruflo's running statusline.
set -euo pipefail

ROOT="$PWD"
while [ "$ROOT" != "/" ] && [ ! -f "$ROOT/CLAUDE.md" ]; do
  ROOT=$(dirname "$ROOT")
done
[ "$ROOT" = "/" ] && exit 0

mkdir -p "$ROOT/.ruflo"
OUT="$ROOT/.ruflo/cost-history.jsonl"

# Only snapshot once per UTC day per project (cheap rate-limit)
TODAY=$(date -u +%Y-%m-%d)
if [ -f "$OUT" ] && tail -n 5 "$OUT" 2>/dev/null | grep -q "\"date\":\"$TODAY\""; then
  exit 0
fi

# Read ruflo-cost-tracker if available
SNAPSHOT='{}'
if command -v npx > /dev/null && [ -d "$ROOT/.ruflo" ]; then
  SNAPSHOT=$(cd "$ROOT" && npx ruflo cost-tracker status --json 2>/dev/null || echo '{}')
fi

LINE=$(jq -n --arg d "$TODAY" --argjson s "$SNAPSHOT" \
   '{date: $d, snapshot: $s, schema_version: 1}' 2>/dev/null || echo "{\"date\":\"$TODAY\",\"snapshot\":{},\"error\":\"jq build failed\"}")

echo "$LINE" >> "$OUT"
exit 0
