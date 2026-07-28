---
name: api-key-billing-fix
description: Found ANTHROPIC_API_KEY in .zshrc was causing pay-per-token billing instead of Max plan. Removed on 2025-03-25. Key needs rotation.
type: feedback
---

## Root cause of $19/day spend
`ANTHROPIC_API_KEY` was exported in `~/.zshrc` line 2. When Claude Code detects this env var, it uses the API key for billing (pay-per-token) instead of the Max subscription.

## Fix applied
- Commented out `export ANTHROPIC_API_KEY=...` in `~/.zshrc`
- Full Engineering OS settings restored (hooks/plugins/MCP are free on Max plan)
- Lean settings backup still available at `~/.claude/settings.json.full-os-backup` (but no longer needed)

## SECURITY: Keys exposed in conversation
These keys were visible and should be rotated:
1. Anthropic API key — rotate at console.anthropic.com
2. GitHub PAT — rotate at github.com/settings/tokens
3. Supabase keys — rotate in Supabase dashboard

## On Max plan
- All hooks, agents, plugins, MCP servers = included in subscription
- No per-token billing as long as ANTHROPIC_API_KEY is NOT set
- Rate limits apply but no dollar overage
