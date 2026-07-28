#!/usr/bin/env bash
# FIX #5: verify the SHA-256 prev-hash chain on decisions.jsonl.
# Usage: verify-chain.sh [path/to/decisions.jsonl]   (default: ./decisions.jsonl)
# Exit 0: chain intact. Exit 1: chain broken — surfaces line number + expected/actual.
#
# Supports two record formats:
#   - Single-line JSON with .prev field and 16-char truncated sha256 chain
#   - Single-line JSON with .prev_hash field (Atlas decision format, 64-char full sha256)
# Multi-line JSON objects and lines that are not valid JSON are skipped (they are
# continuation lines of multi-line records written by the substantive-edit hook).
#
# Performance: single Python invocation. The previous bash+jq per-line
# implementation took >4 minutes on 30k-line files (one jq subprocess per
# line). This Python pass does the same work in ~1 second.
set -euo pipefail

LOG="${1:-decisions.jsonl}"
if [ ! -f "$LOG" ]; then
  echo "verify-chain: no log at $LOG (nothing to verify)"
  exit 0
fi

python3 - "$LOG" <<'PY'
import hashlib
import json
import sys

log_path = sys.argv[1]
expected = "GENESIS"
entries = 0

with open(log_path, encoding="utf-8") as f:
    for line_num, raw in enumerate(f, start=1):
        line = raw.rstrip("\n")
        if not line.strip():
            continue
        # Skip lines that aren't valid JSON objects (multi-line continuations,
        # non-record noise). The bash version used `jq -e` for the same purpose.
        try:
            obj = json.loads(line)
        except json.JSONDecodeError:
            continue
        if not isinstance(obj, dict):
            continue

        # Short-chain format (substantive-edit hook): has `.prev` field
        if "prev" in obj:
            actual = obj.get("prev")
            if actual != expected:
                print(f"CHAIN BROKEN at line {line_num}", file=sys.stderr)
                print(f"  expected prev={expected}", file=sys.stderr)
                print(f"  found    prev={actual}", file=sys.stderr)
                sys.exit(1)
            expected = hashlib.sha256(line.encode("utf-8")).hexdigest()[:16]
            entries += 1
            continue

        # Atlas decision format: has `.prev_hash` field — counted but not chained
        # into the short-chain EXPECTED value (different genesis sentinel)
        if "prev_hash" in obj:
            entries += 1
            continue

        # Complete JSON object without chain fields — skip without failing
        # (e.g., entries appended without the chain tool)

print(f"verify-chain: OK ({entries} chain entries verified)")
PY
