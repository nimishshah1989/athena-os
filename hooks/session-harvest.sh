#!/usr/bin/env bash
# Forge OS — session-harvest.sh
# Stop hook: fires after every Claude Code session.
# Extracts lessons → writes wiki draft → auto-commits to forge-os git.

set -euo pipefail

WIKI_DIR="$HOME/.claude/wiki"
DRAFTS_DIR="$WIKI_DIR/drafts"
FORGE_OS_DIR="/Users/nimishshah/projects/forge-os"
mkdir -p "$DRAFTS_DIR"

PAYLOAD=$(cat)
SESSION_ID=$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('session_id','unknown')[:8])" 2>/dev/null || echo "unknown")
TRANSCRIPT=$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('transcript',''))" 2>/dev/null || echo "")

if [ ${#TRANSCRIPT} -lt 500 ]; then
  exit 0
fi

TRANSCRIPT="${TRANSCRIPT: -8000}"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H%M)
OUTFILE="$DRAFTS_DIR/${DATE}-${TIME}-${SESSION_ID}.md"

echo "$TRANSCRIPT" | claude \
  --model claude-haiku-4-5-20251001 \
  --print \
  --system "You are the Forge OS knowledge curator for Nimish's JIP/YTIP engineering system.

Extract from this Claude Code session transcript:
1. CORRECTIONS — user said no/wrong/actually/don't do that (highest signal)
2. DOMAIN RULES — JIP/YTIP specific: Decimal not float, lakh/crore, SEBI constraints, schema facts, stack gotchas
3. PATTERNS — reusable things that worked well
4. SKILL FLAGS — which installed skills (code-reviewer, secure-code-guardian, feature-forge, the-fool, spec-miner, rag-architect, debugging-wizard, playwright-expert, git-worktrees) need updating
5. MISTAKES — anti-patterns Claude defaulted to that were corrected

Format as clean markdown with these exact headings.
Project context: JIP (Jhaveri Intelligence Platform) or YTIP (YoursTruly) or ForgeOS.
Be terse. No preamble." \
  > "$OUTFILE" 2>/dev/null

# Git commit wiki
if [ -d "$WIKI_DIR/.git" ]; then
  git -C "$WIKI_DIR" add "$OUTFILE" --quiet
  git -C "$WIKI_DIR" commit -m "harvest: session $SESSION_ID ($DATE $TIME)" --quiet 2>/dev/null || true
fi

# Git commit + push forge-os repo
if [ -d "$FORGE_OS_DIR/.git" ]; then
  FORGE_DRAFTS="$FORGE_OS_DIR/wiki/drafts"
  mkdir -p "$FORGE_DRAFTS"
  cp "$OUTFILE" "$FORGE_DRAFTS/"
  git -C "$FORGE_OS_DIR" add "$FORGE_DRAFTS/" --quiet
  git -C "$FORGE_OS_DIR" commit -m "harvest: session $SESSION_ID ($DATE)" --quiet 2>/dev/null || true
  if git -C "$FORGE_OS_DIR" remote -v 2>/dev/null | grep -q "push"; then
    git -C "$FORGE_OS_DIR" push --quiet 2>/dev/null || true
  fi
fi

LINES=$(wc -l < "$OUTFILE" 2>/dev/null || echo 0)
echo ""
echo "🧠 Forge OS harvested session $SESSION_ID → $OUTFILE ($LINES lines)"
echo "   Run /evolve-skills to apply learnings to SKILL.md files"
