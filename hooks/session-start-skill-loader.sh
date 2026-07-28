#!/usr/bin/env bash
# FIX #7: at session start, read project regime tags from CLAUDE.md frontmatter
# and symlink matching skills from ~/forge-skills/<regime>/ into <project>/.claude/skills/.
#
# Multi-axis regulatory: SEBI / RBI / IRDAI / PFRDA / DPDP / GST.
# Each regime has its own SKILL.md authored separately by the operator.
set -euo pipefail

ROOT="$PWD"
while [ "$ROOT" != "/" ] && [ ! -f "$ROOT/CLAUDE.md" ]; do
  ROOT=$(dirname "$ROOT")
done
[ "$ROOT" = "/" ] && exit 0

# Parse the YAML frontmatter regime list
REGIMES=$(awk '
  /^---$/{f=!f; next}
  f && /^regime:/{
    gsub(/regime:[[:space:]]*\[/, "", $0);
    gsub(/\][[:space:]]*$/, "", $0);
    gsub(/[[:space:]]/, "", $0);
    gsub(/,/, "\n", $0);
    print
  }' "$ROOT/CLAUDE.md" 2>/dev/null | tr 'A-Z' 'a-z' | sort -u)

[ -z "$REGIMES" ] && exit 0

mkdir -p "$ROOT/.claude/skills"

LOADED=()
SKIPPED=()
for REGIME in $REGIMES; do
  SRC="$HOME/forge-skills/$REGIME/SKILL.md"
  if [ -f "$SRC" ]; then
    DEST="$ROOT/.claude/skills/$REGIME"
    mkdir -p "$DEST"
    ln -sf "$SRC" "$DEST/SKILL.md"
    LOADED+=("$REGIME")
  else
    SKIPPED+=("$REGIME")
  fi
done

# Surface to operator if any expected skill was missing
if [ "${#SKIPPED[@]}" -gt 0 ]; then
  echo "session-start-skill-loader: regimes loaded: ${LOADED[*]:-(none)}" >&2
  echo "session-start-skill-loader: regimes MISSING skill libraries: ${SKIPPED[*]}" >&2
  echo "  Author at: ~/forge-skills/<regime>/SKILL.md (stubs in nimish-os/forge-skills/)" >&2
fi

exit 0
