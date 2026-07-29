---
name: Server capacity limits
description: EC2 t3.large cannot handle multiple heavy Morningstar API fetches simultaneously — run one at a time
type: feedback
---

Never run more than 1-2 heavy Morningstar API fetches simultaneously on the EC2 t3.large (8GB RAM, 2 vCPUs). Running all 12 APIs + NAV backfill in parallel crashed the server and took down all products (Champions, Ops, MarketPulse, MF Pulse).

**Why:** t3.large has burst CPU credits. The Morningstar Portfolio Data API (#9) returns 50MB+ XML responses that consume all memory when parsed. Multiple simultaneous large XML downloads + DB inserts exhaust both CPU and RAM.

**How to apply:**
- Run Morningstar API fetches ONE AT A TIME, sequentially
- NAV backfill (mfapi.in) should use concurrency=2 max (not 5)
- Portfolio Data API (#9, hash s4bqvv72rjpelvwf) consistently fails with "peer closed connection" — the response is too large. Skip it; Fund Holdings Detail API (#11) provides the same data.
- Always check `uptime` load average before starting heavy operations — keep below 3.0
