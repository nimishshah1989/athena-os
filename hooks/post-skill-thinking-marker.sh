#!/usr/bin/env bash
# PostToolUse hook on Skill: create the thinking marker when a planning
# skill is invoked. Pairs with pre-edit-require-thinking.sh.
#
# The marker is per-PPID (per Claude session). Lasts the lifetime of the
# session — once you've thought about the problem in this session, you're
# free to make multiple edits. Restart of Claude clears the marker so
# every new session must think again.

set -euo pipefail

PAYLOAD=$(cat)
TOOL=$(echo "$PAYLOAD" | jq -r '.tool_name // empty' 2>/dev/null || echo "")

# Only create the marker for Skill invocations
[ "$TOOL" = "Skill" ] || exit 0

SKILL=$(echo "$PAYLOAD" | jq -r '.tool_input.skill // empty' 2>/dev/null || echo "")

# Whitelisted planning skills
case "$SKILL" in
  andrej-karpathy-skills:karpathy-guidelines | \
  karpathy-guidelines | \
  plan-eng-review | \
  plan-design-review | \
  plan-ceo-review | \
  simplify | \
  frontend-design:frontend-design | \
  frontend-design | \
  ruflo-ddd:ddd-context | \
  ddd-context | \
  ruflo-ddd:ddd-aggregate | \
  ddd-aggregate | \
  superpowers:brainstorming | \
  brainstorming | \
  superpowers:writing-plans | \
  writing-plans | \
  superpowers:test-driven-development | \
  test-driven-development | \
  office-hours)
    touch "/tmp/claude-thinking-${PPID}"
    ;;
esac

exit 0
