#!/usr/bin/env bash
# Post-execute_sql: consume one-shot approval markers + log to decisions.jsonl.
# Runs AFTER mcp__plugin_supabase_supabase__execute_sql succeeds.

set -u
INPUT="$(cat)"

# Consume approval markers (one-shot semantics).
for marker in .supabase-write-approved .supabase-delete-approved-1 .supabase-delete-approved-2; do
  [ -f "$marker" ] && rm -f "$marker"
done

# If the project keeps a decisions log, append a short audit entry.
if [ -f decisions.jsonl ] && command -v jq >/dev/null 2>&1; then
  TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  SQL_PREVIEW="$(printf '%s' "$INPUT" | jq -r '.tool_input.query // .tool_input.sql // ""' 2>/dev/null | head -c 500)"
  if [ -n "$SQL_PREVIEW" ]; then
    jq -nc \
      --arg ts "$TS" \
      --arg sql "$SQL_PREVIEW" \
      '{ts: $ts, kind: "supabase_sql_executed", sql_preview: $sql}' \
      >> decisions.jsonl 2>/dev/null || true
  fi
fi

exit 0
