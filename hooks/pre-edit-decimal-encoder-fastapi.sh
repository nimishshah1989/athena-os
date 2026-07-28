#!/usr/bin/env bash
# Block FastAPI Python files using Decimal without a project-wide json_encoders config.
# FIX #3: respect a SessionStart-cached scan result so we don't false-positive on
#         per-route handlers when the encoder is centralized in a base model.
set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // empty')
[ -z "$FILE" ] && exit 0
[ -z "$CONTENT" ] && exit 0

echo "$FILE" | grep -qE '\.py$' || exit 0

# Fintech / regulated context
FINTECH=0
echo "$FILE" | grep -qiE "(atlas|jip|fund|fintech|payment|wealth|finance)" && FINTECH=1

ROOT="$PWD"
while [ "$ROOT" != "/" ] && [ ! -f "$ROOT/CLAUDE.md" ]; do
  ROOT=$(dirname "$ROOT")
done
if [ "$ROOT" != "/" ] && [ -f "$ROOT/CLAUDE.md" ]; then
  head -20 "$ROOT/CLAUDE.md" | grep -qiE "regime:.*\b(SEBI|RBI|IRDAI|PFRDA)\b" && FINTECH=1
fi

[ "$FINTECH" = "0" ] && exit 0

# Only fires if THIS edit imports both fastapi AND Decimal
echo "$CONTENT" | grep -qE "(from fastapi|fastapi import)" || exit 0
echo "$CONTENT" | grep -qE "(from decimal|Decimal)" || exit 0

# This edit may already have json_encoders configured locally — fine
echo "$CONTENT" | grep -qE "json_encoders.*Decimal" && exit 0

# Otherwise, check the project-wide cache populated by session-start-scan-encoder.sh
CACHE="$ROOT/.ruflo/has-decimal-encoder"
if [ -f "$CACHE" ]; then
  if [ "$(cat "$CACHE")" = "true" ]; then
    # Centralized encoder exists somewhere in the project — let this edit through
    exit 0
  fi
fi

# No centralized encoder; this edit doesn't add one either → block
echo "BLOCKED: FastAPI file with Decimal but no json_encoders anywhere in the project." >&2
echo "File: $FILE" >&2
echo "" >&2
echo "Without json_encoders={Decimal: str}, FastAPI's default JSON encoder silently coerces" >&2
echo "Decimal -> float in the response, corrupting money precision." >&2
echo "" >&2
echo "Add ONE of these (in this file or in a base model module):" >&2
echo "  Pydantic v2: model_config = ConfigDict(json_encoders={Decimal: str})" >&2
echo "  Pydantic v1: class Config: json_encoders = {Decimal: str}" >&2
echo "" >&2
echo "After adding, re-run: bash ~/.claude/hooks/session-start-scan-encoder.sh" >&2
echo "to refresh the project-wide cache." >&2
exit 1
