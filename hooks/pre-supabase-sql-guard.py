#!/usr/bin/env python3
"""Gate Supabase MCP `execute_sql` calls.

- SELECT / WITH / EXPLAIN / SHOW / VALUES → allow
- INSERT / UPDATE / UPSERT / MERGE       → require `.supabase-write-approved` in cwd
- DELETE / DROP / TRUNCATE / ALTER       → require BOTH
                                            `.supabase-delete-approved-1`
                                            `.supabase-delete-approved-2` in cwd
- Anything we can't classify confidently → deny (fail-safe)

Markers are one-shot — the PostToolUse companion removes them after execution.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

DESTRUCTIVE = re.compile(
    r"\b(drop\s+\w+|truncate(\s+table)?|delete\s+from|alter\s+\w+)\b",
    re.IGNORECASE,
)
WRITE = re.compile(
    r"\b(insert\s+into|update\s+\w+|upsert|merge\s+into)\b",
    re.IGNORECASE,
)
READ_HEAD = re.compile(
    r"^\s*(select|with|explain|show|values|table)\b",
    re.IGNORECASE,
)


def strip_strings_and_comments(sql: str) -> str:
    """Drop string literals + comments so keyword matching can't false-positive."""
    sql = re.sub(r"'(?:[^']|'')*'", "''", sql)
    sql = re.sub(r'"(?:[^"]|"")*"', '""', sql)
    sql = re.sub(r"--[^\n]*", "", sql)
    sql = re.sub(r"/\*.*?\*/", "", sql, flags=re.DOTALL)
    return sql


def classify(sql: str) -> str:
    cleaned = strip_strings_and_comments(sql)
    if DESTRUCTIVE.search(cleaned):
        return "destructive"
    if WRITE.search(cleaned):
        return "write"
    if READ_HEAD.match(cleaned):
        return "read"
    return "destructive"


def respond(decision: str, reason: str = "") -> None:
    out: dict = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": decision,
        }
    }
    if reason:
        out["hookSpecificOutput"]["permissionDecisionReason"] = reason
    print(json.dumps(out))
    sys.exit(0)


def main() -> None:
    payload = json.load(sys.stdin)
    tool_input = payload.get("tool_input", {}) or {}
    sql = tool_input.get("query") or tool_input.get("sql") or ""
    if not sql.strip():
        respond("deny", "No SQL provided to execute_sql.")

    kind = classify(sql)
    cwd = Path.cwd()

    if kind == "read":
        respond("allow")

    if kind == "write":
        marker = cwd / ".supabase-write-approved"
        if marker.exists():
            respond("allow")
        respond(
            "deny",
            "Write SQL (INSERT/UPDATE/UPSERT/MERGE) requires an approval marker.\n"
            f"  Create it: touch {marker}\n"
            "Then re-run. The marker is consumed after one execution.",
        )

    # destructive
    m1 = cwd / ".supabase-delete-approved-1"
    m2 = cwd / ".supabase-delete-approved-2"
    if m1.exists() and m2.exists():
        respond("allow")

    missing = [str(p) for p in (m1, m2) if not p.exists()]
    instructions = "\n".join(f"  touch {p}" for p in missing)
    respond(
        "deny",
        "Destructive SQL (DELETE/DROP/TRUNCATE/ALTER) requires TWO approvals.\n"
        f"Missing marker(s):\n{instructions}\n"
        "Both are consumed after one execution.",
    )


if __name__ == "__main__":
    main()
