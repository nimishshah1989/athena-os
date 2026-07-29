---
name: parallelize-with-agents
description: Founder directive — parallelize independent workstreams with agents; never serialize the day around one long-running pipeline
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 5e6a13b9-8a58-46ea-bef9-06af1be65cc2
originSessionId: 124d52ae-5f16-4eb5-88cb-9f5af7c8c885
---
Founder (13-Jul-2026, during PILOT-41): "For this kind of a process, we should just deploy multiple agents… The whole day, we will just go and download these documents only… that's not how I am expecting this to happen."

**Why:** I had interpreted the execution plan's "one stream at a time" as one *task* at a time, and sat watching a ~30-min document sweep serially while Phases 2–5 waited. The founder expects wall-clock throughput: heavy machine work runs unattended, independent streams advance in parallel via agents, and Claude orchestrates + verifies instead of babysitting.

**How to apply:** "One stream at a time" applies to *within-stream sequencing and verification discipline*, not to the calendar. When a stream enters a long unattended compute/wait, immediately (1) make the wait one-time (cache/incremental design — e.g. decrypt-text cache so re-sweeps cost seconds), and (2) fan out background agents on other independent streams with strict file-ownership boundaries so they can't collide. Verification of each stream's output stays with the orchestrator. See also [[founder-zero-friction-law]].

**Validated pipeline shape ("ultracode", 18/19-Jul night run — founder standing directive, worked cleanly):** spec with binding per-chunk goal+acceptance checks → 4-lens review panel as PARALLEL agents (CEO/design/eng/DX, auto-decide small calls, amendments folded as BINDING) → chunk builders in dependency-phased parallel waves (strict file ownership; shared files owned by exactly one chunk, others deliver components; own-test-file-only verify loops, max 5 iterations then honest failure log) → orchestrator commits each chunk with goal+evidence → ADVERSARIAL VERIFIER agent on the full diff before deploy (it caught real trust-boundary and float-money defects the builders' own tests missed). Orchestrator keeps all cloud mutations and shared-file edits to itself.
