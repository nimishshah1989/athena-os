---
name: reference-supabase-mcp-gate
description: "Supabase MCP write/delete gate — hook-enforced approval markers for execute_sql, hard-deny for migrations + branch ops"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 1dd229a0-410f-4ddc-a552-96d2f6e66e8a
---

Supabase MCP (`plugin:supabase:supabase`, HTTP transport) is gated by file markers + hooks. Source of truth lives in `~/.claude/settings.json` and `~/.claude/hooks/`.

## Tool tiers (global settings.json)

- **Auto-allowed (read-only)**: list_organizations, list_projects, get_project, get_project_url, get_anon_key, list_tables, list_extensions, list_migrations, list_branches, list_edge_functions, get_logs, get_advisors, generate_typescript_types, search_docs, authenticate, complete_authentication.
- **Hard-denied (no override)**: apply_migration (use Alembic instead), deploy_edge_function, create/delete/merge/reset/rebase_branch.
- **Gated (`execute_sql`)**: classified by `~/.claude/hooks/pre-supabase-sql-guard.py`.

## Marker protocol

Cwd-local marker files; each is one-shot (deleted by `post-supabase-sql-consume.sh` after the SQL runs).

| SQL kind | Required markers |
|---|---|
| SELECT / WITH / EXPLAIN / SHOW / VALUES / TABLE | none — allowed |
| INSERT / UPDATE / UPSERT / MERGE | `.supabase-write-approved` |
| DELETE / DROP / TRUNCATE / ALTER | BOTH `.supabase-delete-approved-1` AND `.supabase-delete-approved-2` |
| Anything unclassifiable | treated as destructive (fail-safe) |

User creates markers with `touch <marker>`. Hook strips string literals + comments before keyword matching, so `SELECT ... LIKE '%delete from%'` is correctly classified as read.

## How to apply

- Never bypass the gate or suggest workarounds — the rule is non-negotiable per the [[user_role]]'s explicit ask (two-person rule for destructive ops).
- Before any write: ask the user to `touch .supabase-write-approved`, then run.
- Before any destructive op: ask for BOTH delete markers.
- DDL never goes through MCP — route through Alembic per [[reference_repo_layout]].
- Every successful execute_sql appends a row to `decisions.jsonl` if the cwd has one.

## Auth + activation

`plugin:supabase:supabase` shows "Needs authentication" on first use. User completes auth via `/mcp` flow. Hook config is global, so it covers every project, not just atlas-os.
