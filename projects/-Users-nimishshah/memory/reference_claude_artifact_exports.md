---
name: reference-claude-artifact-exports
description: "A downloaded Claude artifact .html is an export wrapper, not the page — never read it whole, extract line with the JSON-escaped HTML"
metadata: 
  node_type: memory
  type: reference
  originSessionId: f34205e6-1748-433d-a426-df8c2fdfa990
  modified: 2026-07-29T10:07:49.995Z
---

A `.html` file downloaded from a Claude artifact is an **export wrapper**, not the page itself.
Typical shape: ~390 lines, but one line (~379) is a 2.4 MB gzip+base64 blob of conversation
state, and a later line (~391) holds the real page as a JSON-escaped string.

Reading the file whole costs 600k+ tokens and will exhaust the context window. This happened
repeatedly on 2026-07-29 with "Atlas Investor Dashboard (standalone).html" — three
"Prompt is too long" failures in a row before the cause was found.

**How to handle one:**
```
awk '{print length": line "NR}' FILE | sort -rn | head -5   # find the fat lines
sed -n '391p' FILE | cut -c1-300                            # confirm which holds the HTML
python3 -c "import json;open('out.html','w').write(json.loads(open('FILE').readlines()[390].strip().rstrip(',')))"
```
The real payload is usually 40–60 KB — entirely readable once unwrapped.

**Why it matters:** the founder sends design work this way. Diagnose the packaging before
concluding the file is too big to use. See [[athena-os-v2-rebuild]] for the wider pattern —
the failures were silent, and silence was the actual defect.
