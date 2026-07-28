#!/usr/bin/env bash
# Block frontend file edits without an approved design.
# Approved design = $PROJECT_ROOT/.design-approved.json present.
set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -z "$FILE" ] && exit 0

echo "$FILE" | grep -qE '\.(tsx|jsx|vue|svelte)$' || exit 0
[ "${FORGE_DESIGN_BYPASS:-0}" = "1" ] && exit 0

# Find project root (first ancestor with CLAUDE.md)
ROOT="$PWD"
while [ "$ROOT" != "/" ] && [ ! -f "$ROOT/CLAUDE.md" ]; do
  ROOT=$(dirname "$ROOT")
done
[ "$ROOT" = "/" ] && exit 0

if [ ! -f "$ROOT/.design-approved.json" ]; then
  echo "BLOCKED: Frontend edit without design approval ($FILE)" >&2
  echo "Generate the design as a claude.ai Artifact first." >&2
  echo "Then create $ROOT/.design-approved.json with feature name + timestamp:" >&2
  echo "  echo '{\"feature\":\"<name>\",\"approved_at\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}' > $ROOT/.design-approved.json" >&2
  echo "Bypass for session: export FORGE_DESIGN_BYPASS=1" >&2
  exit 1
fi
exit 0
