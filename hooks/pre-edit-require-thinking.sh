#!/usr/bin/env bash
# PreToolUse hook: blocks Write/Edit in modulith-protected paths unless the
# session has a "thinking marker" — meaning the model invoked a planning
# skill (karpathy-guidelines, plan-eng-review, simplify, frontend-design,
# brainstorming, ddd-context, writing-plans, test-driven-development) earlier
# in this session.
#
# The marker is created by post-skill-thinking-marker.sh.
#
# Scope: only the atlas-os repo's source paths — atlas/**, frontend/src/**,
# migrations/versions/**. Other paths and other repos are unaffected.

set -euo pipefail

PAYLOAD=$(cat)
TOOL=$(echo "$PAYLOAD" | jq -r '.tool_name // empty' 2>/dev/null || echo "")
PATH_=$(echo "$PAYLOAD" | jq -r '.tool_input.file_path // empty' 2>/dev/null || echo "")

# Only inspect Write/Edit
case "$TOOL" in
  Write|Edit) ;;
  *) exit 0 ;;
esac

# Only enforce in atlas-os protected paths
case "$PATH_" in
  *atlas-os/atlas/*|*atlas-os/frontend/src/*|*atlas-os/migrations/versions/*) ;;
  *) exit 0 ;;
esac

# Allow new test files freely (TDD-friendly)
case "$PATH_" in
  *test_*.py|*.test.ts|*.test.tsx|*.spec.ts|*.spec.tsx) exit 0 ;;
esac

# Marker is per-PPID so each Claude session has its own.
MARKER="/tmp/claude-thinking-${PPID}"

if [ ! -f "$MARKER" ]; then
  cat <<'MSG' >&2
✗ BLOCKED — atlas-os requires a planning skill before code edits.

Invoke one of these in this session BEFORE writing/editing source files:

  • andrej-karpathy-skills:karpathy-guidelines  (every meaningful edit)
  • plan-eng-review                              (new feature)
  • simplify                                     (refactor)
  • frontend-design:frontend-design              (UI components)
  • ruflo-ddd:ddd-context                        (new bounded context)
  • superpowers:brainstorming                    (unclear scope / new idea)
  • superpowers:writing-plans                    (multi-step task)
  • superpowers:test-driven-development          (feature/bugfix with TDD)

After invoking the skill, the session marker is created and edits proceed.
This rule is in CLAUDE.md "Engineering discipline (NON-NEGOTIABLE)".
MSG
  exit 2  # exit 2 = block + show stderr to model
fi

exit 0
