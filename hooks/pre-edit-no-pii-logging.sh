#!/usr/bin/env bash
# Block PII (PAN, Aadhaar, DOB, mobile) from log lines in fintech context.
set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // empty')
[ -z "$FILE" ] && exit 0
[ -z "$CONTENT" ] && exit 0

# Fintech / regulated-data context
FINTECH=0
echo "$FILE" | grep -qiE "(atlas|jip|fund|/mf|nav|payment|wealth|portfolio|fintech|cas|kyc)" && FINTECH=1

ROOT="$PWD"
while [ "$ROOT" != "/" ] && [ ! -f "$ROOT/CLAUDE.md" ]; do
  ROOT=$(dirname "$ROOT")
done
if [ "$ROOT" != "/" ] && [ -f "$ROOT/CLAUDE.md" ]; then
  if head -20 "$ROOT/CLAUDE.md" | grep -qiE "regime:.*\b(SEBI|RBI|IRDAI|PFRDA|DPDP)\b"; then
    FINTECH=1
  fi
fi

[ "$FINTECH" = "0" ] && exit 0

# Per-line: must be a logging call AND contain a PII pattern AND not be redacted
while IFS= read -r line; do
  # Identify a logging call on this line
  echo "$line" | grep -qiE "(log\.|logger\.|logging\.|print\(|console\.(log|info|debug|warn|error))" || continue

  # PII patterns
  HAS_PII=0
  echo "$line" | grep -qE "\b[A-Z]{5}[0-9]{4}[A-Z]\b" && HAS_PII=1   # PAN
  echo "$line" | grep -qiE "(\baadhaar?\b|\baadhar\b|\bdob\b|date.of.birth)" && HAS_PII=1
  echo "$line" | grep -qE "\+91[0-9]{10}\b" && HAS_PII=1            # mobile +91…
  echo "$line" | grep -qE "\b[0-9]{12}\b" && HAS_PII=1              # 12-digit (Aadhaar shape)

  [ "$HAS_PII" = "0" ] && continue

  # Allow if obviously redacted / hashed / placeholder
  echo "$line" | grep -qiE "(redacted|masked|hashed|sha[0-9]|md5|placeholder|fake|test_only|# *example|<.+>|x{3,})" && continue

  echo "BLOCKED: PII pattern in a log call in $FILE" >&2
  echo "Line: $line" >&2
  echo "Never log PAN, Aadhaar, DOB, or mobile numbers in cleartext." >&2
  echo "Use redacted/hashed identifiers (e.g. last 4 digits, SHA-256 of PAN)." >&2
  exit 1
done <<< "$CONTENT"

exit 0
