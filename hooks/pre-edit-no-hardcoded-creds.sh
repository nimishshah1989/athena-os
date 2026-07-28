#!/usr/bin/env bash
# Block edits that introduce hardcoded credentials.
# Reads tool-call JSON on stdin (Claude Code PreToolUse hook contract).
# Exit 0 = allow, exit 1 = block (stderr surfaces to the agent).
set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // empty')
[ -z "$CONTENT" ] && exit 0

# AWS access key — strict pattern
if echo "$CONTENT" | grep -qE "AKIA[0-9A-Z]{16}"; then
  echo "BLOCKED: Hardcoded AWS access key in $FILE" >&2
  echo "Use AWS Secrets Manager or environment variables." >&2
  exit 1
fi

# Generic credentials with non-placeholder values
if echo "$CONTENT" | grep -qiE "(password|api_key|api-key|secret|jwt_secret|access_token|private_key|bearer)\s*[:=]\s*['\"][^'\"]+['\"]"; then
  if ! echo "$CONTENT" | grep -qiE "['\"](xxx|change_?me|placeholder|example|todo|<.+>|your_.+_here|fake|dummy|test_only|env\..+|process\.env|os\.getenv|os\.environ|secrets_manager)['\"]"; then
    echo "BLOCKED: Hardcoded credential in $FILE" >&2
    echo "Use AWS Secrets Manager or env vars. If placeholder, use 'CHANGE_ME', 'PLACEHOLDER', etc." >&2
    exit 1
  fi
fi

exit 0
