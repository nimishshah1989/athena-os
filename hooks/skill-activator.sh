#!/usr/bin/env bash
# Forge OS — skill-activator.sh
# UserPromptSubmit hook: scans prompt, injects skill activation into context.

PAYLOAD=$(cat)
PROMPT=$(echo "$PAYLOAD" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('prompt', '').lower())
" 2>/dev/null || echo "")

inject() {
  # Output to stdout — Claude Code appends this to the prompt context
  echo "FORGE OS: Activate skill [$1] for this task."
}

# ── Keyword → Skill mapping ──────────────────────────────────
case "$PROMPT" in
  *"review"*|*"pull request"*|*"pr "*)
    inject "code-reviewer" ;;
esac

case "$PROMPT" in
  *"debug"*|*"breakpoint"*|*"step through"*|*"trace"*)
    inject "debugging-wizard" ;;
esac

case "$PROMPT" in
  *"auth"*|*"jwt"*|*"password"*|*"owasp"*|*"secure"*|*"vulnerab"*)
    inject "secure-code-guardian" ;;
esac

case "$PROMPT" in
  *"spec"*|*"feature"*|*"requirement"*|*"user stor"*|*"acceptance criteri"*)
    inject "feature-forge" ;;
esac

case "$PROMPT" in
  *"playwright"*|*"e2e"*|*"end to end"*|*"tdd"*|*"test driven"*)
    inject "playwright-expert" ;;
esac

case "$PROMPT" in
  *"rag"*|*"vector"*|*"embedding"*|*"retrieval"*|*"semantic search"*)
    inject "rag-architect" ;;
esac

case "$PROMPT" in
  *"challenge"*|*"poke holes"*|*"red team"*|*"devil"*|*"stress test"*|*"pre-mortem"*)
    inject "the-fool" ;;
esac

case "$PROMPT" in
  *"reverse engineer"*|*"undocumented"*|*"legacy"*|*"document this system"*|*"understand this code"*)
    inject "spec-miner" ;;
esac

case "$PROMPT" in
  *"worktree"*|*"multiple branch"*|*"isolate branch"*)
    inject "git-worktrees" ;;
esac

exit 0
