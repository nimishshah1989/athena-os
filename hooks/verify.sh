#!/usr/bin/env bash
# Forge OS — verify.sh
# Run anytime to confirm the full system is correctly installed and wired.
# Green = good. Red = broken. Yellow = warning.

CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SKILLS_DIR="$CLAUDE_DIR/skills/public"
SETTINGS="$CLAUDE_DIR/settings.json"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
WIKI_DIR="$CLAUDE_DIR/wiki"
FORGE_OS_DIR="/Users/nimishshah/projects/forge-os"

PASS=0; FAIL=0; WARN=0

ok()   { echo "   ✅ $1"; PASS=$((PASS+1)); }
fail() { echo "   ❌ $1"; FAIL=$((FAIL+1)); }
warn() { echo "   ⚠️  $1"; WARN=$((WARN+1)); }

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  Forge OS — System Verification          ║"
echo "╚══════════════════════════════════════════╝"

# ── Hook scripts ────────────────────────────────────────────
echo ""
echo "▶ Hook scripts"
[ -x "$HOOKS_DIR/session-harvest.sh" ] && ok "session-harvest.sh (executable)" || fail "session-harvest.sh missing"
[ -x "$HOOKS_DIR/skill-evolve.sh" ]     && ok "skill-evolve.sh (executable)"    || fail "skill-evolve.sh missing or not executable"
[ -x "$HOOKS_DIR/skill-activator.sh" ]  && ok "skill-activator.sh (executable)" || fail "skill-activator.sh missing or not executable"

# ── settings.json hooks ──────────────────────────────────────
echo ""
echo "▶ settings.json hook registration"
if [ -f "$SETTINGS" ]; then
  grep -q "session-harvest.sh" "$SETTINGS" && ok "Stop hook → session-harvest registered"    || fail "Stop hook NOT registered in settings.json"
  grep -q "skill-activator.sh" "$SETTINGS" && ok "UserPromptSubmit → skill-activator registered" || fail "UserPromptSubmit hook NOT registered in settings.json"
else
  fail "settings.json does not exist"
fi

# ── Skills ───────────────────────────────────────────────────
echo ""
echo "▶ Skills (9 required)"
SKILLS=(code-reviewer secure-code-guardian feature-forge the-fool spec-miner rag-architect debugging-wizard playwright-expert git-worktrees)
for skill in "${SKILLS[@]}"; do
  if [ -f "$SKILLS_DIR/$skill/SKILL.md" ]; then
    # Check JIP layer is present
    grep -q "JIP/YTIP Domain Layer" "$SKILLS_DIR/$skill/SKILL.md" \
      && ok "$skill (with JIP layer)" \
      || warn "$skill exists but JIP layer missing"
  else
    fail "$skill — SKILL.md not found"
  fi
done

# ── CLAUDE.md ────────────────────────────────────────────────
echo ""
echo "▶ CLAUDE.md"
[ -f "$CLAUDE_MD" ] || fail "CLAUDE.md not found" && \
  grep -q "Skills Registry" "$CLAUDE_MD" \
    && ok "Skills registry present in CLAUDE.md" \
    || warn "Skills registry missing from CLAUDE.md"

# ── Slash command ────────────────────────────────────────────
echo ""
echo "▶ Slash commands"
[ -f "$CLAUDE_DIR/commands/evolve-skills.md" ] \
  && ok "/evolve-skills command installed" \
  || fail "/evolve-skills command missing"

# ── Wiki git ─────────────────────────────────────────────────
echo ""
echo "▶ Wiki"
[ -d "$WIKI_DIR/.git" ] && ok "Wiki is a git repo" || warn "Wiki not a git repo — session harvests won't be versioned"
[ -d "$WIKI_DIR/drafts" ] && ok "Wiki drafts directory exists" || fail "Wiki drafts directory missing"

# ── Forge OS repo ────────────────────────────────────────────
echo ""
echo "▶ Forge OS git repo ($FORGE_OS_DIR)"
if [ -d "$FORGE_OS_DIR/.git" ]; then
  ok "Forge OS git repo found"
  UNCOMMITTED=$(git -C "$FORGE_OS_DIR" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  [ "$UNCOMMITTED" -eq 0 ] && ok "Repo is clean (nothing uncommitted)" || warn "$UNCOMMITTED uncommitted change(s) — run: git -C $FORGE_OS_DIR add -A && git -C $FORGE_OS_DIR commit"
  REMOTE=$(git -C "$FORGE_OS_DIR" remote -v 2>/dev/null | head -1)
  [ -n "$REMOTE" ] && ok "Remote configured: $REMOTE" || warn "No git remote — auto-push won't work"
else
  warn "Forge OS repo not found at $FORGE_OS_DIR — git commits disabled"
fi

# ── Summary ──────────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════"
echo "  Result: $PASS passed · $FAIL failed · $WARN warnings"
echo "══════════════════════════════════════════"

if [ "$FAIL" -eq 0 ] && [ "$WARN" -eq 0 ]; then
  echo "  🟢 Forge OS fully operational"
elif [ "$FAIL" -eq 0 ]; then
  echo "  🟡 Operational with warnings — review above"
else
  echo "  🔴 $FAIL critical issue(s) — re-run bootstrap or fix manually"
  exit 1
fi
echo ""
