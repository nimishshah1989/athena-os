#!/usr/bin/env bash
# FIX #6 (token economics): at session start, generate a compressed repo-map so the
# agent can read ~1.5k-token AST summary instead of full files. ~40-50% reduction
# on file-context reads across an Atlas-scale build.
#
# Uses RepoMapper (https://github.com/pdavis68/RepoMapper) — Python port of aider's
# tree-sitter PageRank repo-map. Falls back to a simple file-tree if RepoMapper
# isn't installed.
#
# Output: $PROJECT_ROOT/.ruflo/repo-map.txt — agent reads this in lieu of `ls -R`.
set -euo pipefail

ROOT="$PWD"
while [ "$ROOT" != "/" ] && [ ! -f "$ROOT/CLAUDE.md" ]; do
  ROOT=$(dirname "$ROOT")
done
[ "$ROOT" = "/" ] && exit 0

mkdir -p "$ROOT/.ruflo"
OUT="$ROOT/.ruflo/repo-map.txt"

if command -v repomapper > /dev/null; then
  # Generate map (3000-token budget; tune via REPOMAP_TOKENS env var)
  TOKENS="${REPOMAP_TOKENS:-3000}"
  repomapper "$ROOT" --map-tokens "$TOKENS" > "$OUT" 2>/dev/null || {
    echo "# repomapper failed; using fallback file tree" > "$OUT"
    find "$ROOT" -type f \
      -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/__pycache__/*" \
      -not -path "*/.venv/*" -not -path "*/dist/*" -not -path "*/build/*" \
      -not -path "*/.ruflo/*" \
      | head -200 >> "$OUT"
  }
else
  # Fallback: simple file tree, capped at 200 entries
  echo "# RepoMapper not installed; install for a compressed AST repo-map." > "$OUT"
  echo "#   pip install repomapper" >> "$OUT"
  echo "" >> "$OUT"
  find "$ROOT" -type f \
    -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/__pycache__/*" \
    -not -path "*/.venv/*" -not -path "*/dist/*" -not -path "*/build/*" \
    -not -path "*/.ruflo/*" \
    | head -200 >> "$OUT"
fi

exit 0
