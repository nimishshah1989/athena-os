---
name: two-session-coordination
description: TWO Claude sessions build Jaltantra concurrently overnight (2026-07-03/04) — division of labor to avoid duplicate jobs and bandwidth contention.
metadata: 
  node_type: memory
  type: project
  originSessionId: dfccce8f-6529-45df-aeea-caa4140ef602
---

On the night of 2026-07-03/04 two Claude Code sessions work the jaltantra repo simultaneously under the founder's autonomous mandate ([[autonomous-build-mandate]]):

- **Session A (a217c514…, "Fable build loop")** — owns the climatology backfills: `build_climatology.py --term et` (PID ~74601, since 19:13) and `--term sm` (since 23:32). Its logs live in ITS scratchpad (`…/a217c514-e259-4c4f-ae3e-d66ad6f9e2ae/scratchpad/`).
- **Session B (dfccce8f…, this one)** — owns: 4 parallel veg slices (scratchpad_veg_A-D.log in repo root), migration 0011 (soil_watershed), load_soil.py run, API routes, frontend.

**Why:** duplicate jobs share `data/raw/` cache paths — two curls writing the same zip can corrupt it, and duplicated downloads saturate bandwidth (killed Session B's duplicate ET run via curl timeout).

**How to apply:** before launching any long job, `ps aux | grep -E 'build_climatology|nowcast_sync|load_soil'` and check both scratchpads; never start a job the other session already runs. Check `climatology_weekly` term coverage (rows/n_years per term) to verify a climatology actually landed before computing WAI — Session A's ET run predates the 20:27 edit of build_climatology.py, so verify its output rather than assume.
