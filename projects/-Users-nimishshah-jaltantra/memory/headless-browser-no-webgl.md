---
name: headless-browser-no-webgl
description: "gstack browse headless daemon has no WebGL — Jaltantra's maplibre map never renders in QA screenshots; app has a MapBoundary fallback"
metadata: 
  node_type: memory
  type: project
  originSessionId: 63a74e4a-f7fa-4806-8640-d56aaeed86ef
---

The gstack `browse` headless Chromium daemon reports `webgl:false` (probe: `$B js "!!document.createElement('canvas').getContext('webgl')"`), so Jaltantra's maplibre map canvas never renders in headless QA screenshots — the map area shows the MapBoundary fallback notice ("map view needs WebGL"). All DOM UI (panels, overlays, charts) verifies fine headless.

**Why:** maplibre-gl throws in its Map constructor without WebGL; before the `MapBoundary` error boundary in `App.tsx` this blanked the whole app in React 18.

**How to apply:** verify map-canvas visuals in the user's real browser or `browse connect` (headed); don't chase "blank map in screenshot" as an app bug. Related: [[two-session-coordination]].
