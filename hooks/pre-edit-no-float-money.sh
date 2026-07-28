#!/usr/bin/env bash
# Block float arithmetic on monetary values in fintech context.
# FIX #2: line-by-line scan; assignment+float AND money keyword on the SAME line.
# Allowlists scientific computing libraries (numpy/scipy/matplotlib).
set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // empty')
[ -z "$FILE" ] && exit 0
[ -z "$CONTENT" ] && exit 0

# Fintech context detection — path keyword OR project regime tag
FINTECH=0
echo "$FILE" | grep -qiE "(atlas|jip|fund|/mf|nav|payment|wealth|portfolio|brokerage|finance|fintech)" && FINTECH=1

# Read project CLAUDE.md regime tag if reachable
ROOT="$PWD"
while [ "$ROOT" != "/" ] && [ ! -f "$ROOT/CLAUDE.md" ]; do
  ROOT=$(dirname "$ROOT")
done
if [ "$ROOT" != "/" ] && [ -f "$ROOT/CLAUDE.md" ]; then
  if head -20 "$ROOT/CLAUDE.md" | grep -qiE "regime:.*\b(SEBI|RBI|IRDAI|PFRDA)\b"; then
    FINTECH=1
  fi
fi

# Pragma marker also activates
if echo "$CONTENT" | grep -qE "# *pragma: *finance-critical"; then
  FINTECH=1
fi

[ "$FINTECH" = "0" ] && exit 0

# Per-line scan: assignment+float pattern AND monetary keyword on SAME line, NOT in scientific code
BLOCKED_LINE=""
while IFS= read -r line; do
  # Skip comments and docstrings
  echo "$line" | grep -qE "^\s*(#|\"\"\"|''')" && continue

  # Look for actual float assignments / annotations / casts
  echo "$line" | grep -qE "(=\s*float\(|:\s*float\b|->\s*float\b|np\.float|numpy\.float)" || continue

  # Same line must have a monetary keyword (whole-word boundary)
  echo "$line" | grep -qiE "\b(price|amount|nav|cost|fee|balance|currency|inr|usd|money|rupee|principal|premium|interest|return|yield|pnl|profit|loss|tax|charge|commission|brokerage|payable|receivable)\b" || continue

  # Allowlist: scientific stack lines that legitimately use float
  echo "$line" | grep -qE "(np\.|numpy\.|scipy\.|matplotlib|plt\.|pd\.|pandas\.|sklearn|torch|jax)" && continue

  BLOCKED_LINE="$line"
  break
done <<< "$CONTENT"

if [ -n "$BLOCKED_LINE" ]; then
  echo "BLOCKED: float arithmetic on a monetary value in $FILE" >&2
  echo "Line: $BLOCKED_LINE" >&2
  echo "Use decimal.Decimal for money. ROUND_HALF_UP for customer-facing values." >&2
  echo "Example: from decimal import Decimal, ROUND_HALF_UP" >&2
  exit 1
fi

exit 0
