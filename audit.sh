#!/bin/bash
# JIP Engineering OS v2.1 — Audit
# Run anytime: bash ~/jip-engineering-os/audit.sh
# Shows exactly what's installed, what's active, and what Claude Code will load

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
hdr()  { echo ""; echo -e "${BOLD}── $1 ──${NC}"; }

echo ""
echo -e "${BOLD}╔═══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║   JIP Engineering OS v2.1 — System Audit      ║${NC}"
echo -e "${BOLD}╚═══════════════════════════════════════════════╝${NC}"

# ── 1. CLAUDE.md ──
hdr "1. CLAUDE.md (loaded every session)"
if [ -f "$HOME/.claude/CLAUDE.md" ]; then
    lines=$(wc -l < "$HOME/.claude/CLAUDE.md")
    ok "Global CLAUDE.md exists ($lines lines)"
    if [ "$lines" -gt 100 ]; then
        warn "CLAUDE.md is $lines lines — should be under 100 for best compliance"
    fi
    # Check for the 4 Laws
    for law in "PROVE" "SYNTHETIC" "BACKEND FIRST" "SEE WHAT YOU BUILD"; do
        if grep -qi "$law" "$HOME/.claude/CLAUDE.md" 2>/dev/null; then
            ok "Law found: $law"
        else
            fail "Law missing: $law"
        fi
    done
else
    fail "No global CLAUDE.md — Claude Code has no persistent instructions"
fi

# ── 2. Rules ──
hdr "2. Rules (always loaded, every session)"
EXPECTED_RULES=("development-process" "verification" "code-quality" "financial-domain" "security" "deployment")
if [ -d "$HOME/.claude/rules" ]; then
    for rule in "${EXPECTED_RULES[@]}"; do
        if [ -f "$HOME/.claude/rules/$rule.md" ]; then
            lines=$(wc -l < "$HOME/.claude/rules/$rule.md")
            ok "$rule.md ($lines lines)"
        else
            fail "$rule.md — MISSING"
        fi
    done
    # Check for extra rules
    for f in "$HOME/.claude/rules/"*.md; do
        [ -f "$f" ] || continue
        name=$(basename "$f" .md)
        found=false
        for exp in "${EXPECTED_RULES[@]}"; do
            [ "$name" = "$exp" ] && found=true
        done
        $found || warn "Extra rule: $name.md (not in standard set)"
    done
else
    fail "No rules/ directory — development process not enforced"
fi

# ── 3. Agents ──
hdr "3. Agents (subagents with persistent memory)"
EXPECTED_AGENTS=("architect" "reviewer" "qa" "deployer")
if [ -d "$HOME/.claude/agents" ]; then
    for agent in "${EXPECTED_AGENTS[@]}"; do
        if [ -f "$HOME/.claude/agents/$agent.md" ]; then
            # Check for proper YAML frontmatter
            if head -1 "$HOME/.claude/agents/$agent.md" | grep -q "^---"; then
                has_memory=$(grep -c "^memory:" "$HOME/.claude/agents/$agent.md" 2>/dev/null || echo 0)
                has_model=$(grep -c "^model:" "$HOME/.claude/agents/$agent.md" 2>/dev/null || echo 0)
                extras=""
                [ "$has_memory" -gt 0 ] && extras="memory:yes"
                [ "$has_model" -gt 0 ] && extras="$extras model:yes"
                ok "@$agent — proper frontmatter ($extras)"
            else
                warn "@$agent — NO YAML frontmatter (won't load as subagent)"
            fi
        else
            fail "@$agent — MISSING"
        fi
    done
    # Check for old-style agents
    for f in "$HOME/.claude/agents/"*.md; do
        [ -f "$f" ] || continue
        name=$(basename "$f" .md)
        found=false
        for exp in "${EXPECTED_AGENTS[@]}"; do
            [ "$name" = "$exp" ] && found=true
        done
        if ! $found; then
            if head -1 "$f" | grep -q "^---"; then
                warn "Extra agent: @$name (has frontmatter)"
            else
                warn "Extra agent: @$name (NO frontmatter — probably v1 legacy, won't load)"
            fi
        fi
    done
else
    fail "No agents/ directory"
fi

# ── 4. Skills ──
hdr "4. Skills (invokable workflows)"
EXPECTED_SKILLS=("research-plan-build" "visual-qa-loop" "verify-deployment" "api-health-check" "documentation-audit" "ui-match-check" "new-platform-scaffold" "audit-os")
if [ -d "$HOME/.claude/skills" ]; then
    for skill in "${EXPECTED_SKILLS[@]}"; do
        if [ -f "$HOME/.claude/skills/$skill/SKILL.md" ]; then
            lines=$(wc -l < "$HOME/.claude/skills/$skill/SKILL.md")
            ok "/$skill ($lines lines)"
        else
            fail "/$skill — MISSING"
        fi
    done
else
    fail "No skills/ directory"
fi

# ── 5. Settings & Hooks ──
hdr "5. Settings & Hooks (deterministic enforcement)"
if [ -f "$HOME/.claude/settings.json" ]; then
    ok "settings.json exists"
    
    # Check hooks
    if grep -q "PostToolUse" "$HOME/.claude/settings.json" 2>/dev/null; then
        ok "PostToolUse hooks configured (syntax check + synthetic data scan)"
    else
        fail "No PostToolUse hooks — edits won't be checked"
    fi
    if grep -q "PreToolUse" "$HOME/.claude/settings.json" 2>/dev/null; then
        ok "PreToolUse hooks configured (destructive op blocker)"
    else
        fail "No PreToolUse hooks — destructive commands not blocked"
    fi
    if grep -q "Stop" "$HOME/.claude/settings.json" 2>/dev/null; then
        ok "Stop hook configured (memory reminder)"
    else
        warn "No Stop hook"
    fi
    
    # Check auto-compact
    compact=$(grep "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE" "$HOME/.claude/settings.json" 2>/dev/null | grep -o '"[0-9]*"' | tr -d '"')
    if [ -n "$compact" ]; then
        ok "Auto-compact at $compact%"
        [ "$compact" -gt 70 ] && warn "Consider lowering to 60% for less instruction drift"
    else
        warn "Auto-compact not set (default 95% — too high, causes drift)"
    fi
    
    # Check Playwright MCP
    if grep -q "playwright" "$HOME/.claude/settings.json" 2>/dev/null; then
        ok "Playwright MCP configured"
    else
        fail "Playwright MCP not in settings — visual QA loop won't work"
    fi
else
    fail "No settings.json — hooks not configured"
fi

# ── 6. MCP Servers ──
hdr "6. MCP Servers (tool access)"
if command -v claude &>/dev/null; then
    echo -e "  ${DIM}Run 'claude mcp list' in Claude Code to see active MCPs${NC}"
fi
# Check known MCP configs
for mcp_check in "playwright" "context7" "github" "supabase" "computer-use"; do
    if grep -rq "$mcp_check" "$HOME/.claude/settings.json" "$HOME/.claude.json" 2>/dev/null; then
        ok "MCP: $mcp_check (found in config)"
    else
        case $mcp_check in
            playwright) fail "MCP: $mcp_check — MISSING (visual QA won't work)" ;;
            computer-use) warn "MCP: $mcp_check — enable via /mcp in Claude Code (built-in)" ;;
            *) warn "MCP: $mcp_check — not found (optional)" ;;
        esac
    fi
done

# ── 7. Memory System ──
hdr "7. Memory System"
# Auto memory (native)
echo -e "  ${DIM}Auto memory is a Claude Code native feature — verify with /memory${NC}"

# Legacy memory files
if [ -d "$HOME/.claude/memory" ]; then
    for f in "$HOME/.claude/memory/"*.md; do
        [ -f "$f" ] || continue
        lines=$(wc -l < "$f")
        name=$(basename "$f")
        ok "Legacy: $name ($lines lines — preserved for reference)"
    done
fi
if [ -d "$HOME/.claude/learning" ]; then
    for f in "$HOME/.claude/learning/"*.md; do
        [ -f "$f" ] || continue
        lines=$(wc -l < "$f")
        name=$(basename "$f")
        ok "Legacy: $name ($lines lines — preserved for reference)"
    done
fi

# Agent memory directories
if ls -d "$HOME/.claude/agent-memory"* 2>/dev/null | head -1 > /dev/null 2>&1; then
    ok "Agent memory directories exist (subagents accumulating knowledge)"
    for d in "$HOME/.claude/agent-memory"*/*; do
        [ -d "$d" ] || continue
        agent=$(basename "$d")
        files=$(find "$d" -name "*.md" | wc -l)
        ok "  @$agent memory: $files files"
    done
else
    warn "No agent memory yet — will build up after first subagent usage"
fi

# ── 8. Claude Code Version ──
hdr "8. Environment"
if command -v claude &>/dev/null; then
    version=$(claude --version 2>/dev/null || echo "unknown")
    ok "Claude Code: $version"
    # Check if version supports computer use (v2.1.85+)
else
    warn "Claude Code CLI not found in PATH"
fi
if command -v node &>/dev/null; then
    ok "Node.js: $(node --version)"
else
    fail "Node.js not installed (needed for Playwright MCP)"
fi
if command -v python3 &>/dev/null; then
    ok "Python: $(python3 --version 2>&1)"
else
    fail "Python3 not installed"
fi

# ── Summary ──
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════${NC}"
echo -e "${BOLD}  SUMMARY${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${CYAN}AUTOMATIC (every session):${NC}"
echo "    Rules loaded: $(ls "$HOME/.claude/rules/"*.md 2>/dev/null | wc -l)/6"
echo "    Hooks active: $(grep -c '"matcher"' "$HOME/.claude/settings.json" 2>/dev/null || echo 0) matchers"
echo "    CLAUDE.md: $(wc -l < "$HOME/.claude/CLAUDE.md" 2>/dev/null || echo 0) lines"
echo ""
echo -e "  ${CYAN}AVAILABLE (call when needed):${NC}"
echo "    Agents: $(ls "$HOME/.claude/agents/"*.md 2>/dev/null | wc -l)"
echo "    Skills: $(find "$HOME/.claude/skills" -name "SKILL.md" 2>/dev/null | wc -l)"
echo ""
echo -e "  ${CYAN}LEARNING (compounds over time):${NC}"
echo "    Auto memory: verify with /memory in Claude Code"
echo "    Agent memories: $(find "$HOME/.claude/agent-memory"* -name "*.md" 2>/dev/null | wc -l) files"
echo ""
