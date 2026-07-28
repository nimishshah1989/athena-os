---
name: Pipeline monitoring frontend requirement
description: User wants a live frontend dashboard to track data ingestion pipelines in real-time
type: project
---

Nimish explicitly requested a frontend dashboard for tracking data ingestion pipeline status live.

Requirements:
- Real-time pipeline status (running/complete/failed per track)
- Data ingestion progress (rows processed, time elapsed)
- Anomaly viewer (unresolved anomalies by severity)
- System health (Redis status, DB connections, disk space)
- SLA tracking (which pipelines met/missed deadlines)

**Why:** Nimish needs visibility into pipeline execution without SSH-ing into EC2. The orchestrator dashboard (port 8099) was specified as SSH-tunnel-only, but a proper frontend gives better UX.
**How to apply:** Build as a separate chunk. Can be a simple React/Next.js app or even server-rendered HTML from FastAPI. Must poll/websocket the admin API endpoints.
