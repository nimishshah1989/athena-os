#!/usr/bin/env bash
# Guard hook: blocks destructive database and code operations
# Exits with non-zero + STDERR message to block the command

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Destructive database operations
if echo "$COMMAND" | grep -qiE '(DROP\s+(TABLE|DATABASE|SCHEMA|INDEX)|TRUNCATE\s+|DELETE\s+FROM|ALTER\s+TABLE.*DROP)'; then
  echo "BLOCKED: Destructive database operation detected: $COMMAND" >&2
  echo "If you really need this, run it manually outside Claude Code." >&2
  exit 2
fi

# Destructive file operations
if echo "$COMMAND" | grep -qiE '(rm\s+-rf\s+/|rm\s+-rf\s+\.|rm\s+-rf\s+\*|rm\s+-rf\s+backend|rm\s+-rf\s+frontend|rm\s+-rf\s+src)'; then
  echo "BLOCKED: Destructive file deletion detected: $COMMAND" >&2
  exit 2
fi

# Force pushes to main/master
if echo "$COMMAND" | grep -qiE 'git\s+push\s+.*--force.*\s+(main|master)|git\s+push\s+-f.*\s+(main|master)'; then
  echo "BLOCKED: Force push to main/master: $COMMAND" >&2
  exit 2
fi

# Hard resets
if echo "$COMMAND" | grep -qiE 'git\s+reset\s+--hard'; then
  echo "BLOCKED: git reset --hard detected: $COMMAND" >&2
  exit 2
fi

# Alembic destructive (downgrade to nothing)
if echo "$COMMAND" | grep -qiE 'alembic\s+downgrade\s+base'; then
  echo "BLOCKED: Alembic downgrade to base: $COMMAND" >&2
  exit 2
fi

exit 0
