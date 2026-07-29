#!/usr/bin/env bash
# Runs just before the session is compacted. Whatever this prints becomes the
# custom instructions for the summariser, so it decides WHAT SURVIVES.
#
# Default compaction keeps the conversation's shape and loses the operational
# detail — which file was mid-edit, which command proved a claim, what was
# verified versus merely asserted. That is the detail this session runs on.
set -euo pipefail

INPUT=$(cat)
TRIGGER=$(echo "$INPUT" | jq -r '.trigger // "auto"')

cat <<'EOF'
Compact at a clean boundary. Never cut mid-task: if a file is part-edited, a
command is running, or a chunk is unverified, carry that forward in full.

Preserve, verbatim where short:
- The task in flight, and the next concrete action.
- Every path already touched, and what changed in each.
- Commands whose OUTPUT proved something, with the result. A claim without its
  evidence is worthless here — "prove, never claim" survives compaction.
- Anything the user corrected, decided, or rejected, and why.
- Failures and dead ends, so they are not re-attempted.
- Open questions still awaiting the user.

Drop freely:
- Tool output already superseded or acted on.
- File contents that can be re-read from disk.
- Exploration that led nowhere and is already recorded as a dead end.

State plainly what was dropped. A summary that reads complete while missing a
verification step is the failure mode this system exists to prevent.
EOF

[ "$TRIGGER" = "auto" ] && echo "
This was an automatic compaction at the context threshold, not a user request.
The user did not choose this moment — be conservative about what you discard."

exit 0
