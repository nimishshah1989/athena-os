---
name: project-jaltantra
description: "Jaltantra water intelligence system for Maharashtra — Latur district MVP, district-level groundwater early warning"
metadata: 
  node_type: memory
  type: project
  originSessionId: e0d52c47-d081-44f6-94a6-bef734408e59
---

District-level groundwater early warning system for Maharashtra. MVP = Latur district. Demo target = Rainmatter Foundation / Paani Foundation / Maharashtra government.

**Why:** India has no district-level GW early warning. 2016 Marathwada crisis (Latur epicentre) killed/displaced people. The analytical gap is real and documented.

**Plan file:** `/Users/nimishshah/.claude/plans/jaltantra-water-intelligence-system-shimmering-snowglobe.md`

**Build sequence (CEO review decision):** Proof-first. Week 1-2 = notebook proof (plot Latur WTD 2013-2016, validate pre-crisis signal exists). Week 3-4 = full data spine. Week 5 = XGBoost proof. Only then build production infrastructure.

**Key technical decisions:**
- GRACE excluded (too coarse for Latur 5,039 km²; minimum basin = 150,000 km²)
- Sentinel-2 NOT in ML training (launched 2015, training is 2000–2014)
- ML features: WTD + rainfall only (V2 adds crop features)
- Sy per well from metadata (shallow_weathered 0.03–0.05, deep_fractured 0.003–0.01), weighted taluka average
- XGBoost not LSTM (data too sparse: 4 readings/year)
- Data refresh: GitHub Actions cron (weekly)
- 8 Marathwada districts data collected; live forecast for Latur only

**Demo hero:** Three crisis proofs (2012, 2016, 2018-19) — model flagged [N] days before Maharashtra drought gazette notification. Need to find exact gazette dates (Week 1 task).

**Scope accepted beyond baseline:**
- Three crisis years (not just 2016)
- Water credit score (0–100) per taluka
- All 8 Marathwada districts data collection

**Stack:** Supabase + PostGIS, GEE Python, FastAPI + XGBoost, Next.js 14 + Mapbox

**Budget:** ₹16,000–31,000

**Highest risk:** CGWB pre-2010 data has no bulk API — elevated to HIGH risk. Training window may be 2010–2024 not 2000–2024.

**How to apply:** Resume any Jaltantra session by reading the plan file first. Always validate whether the pre-crisis CGWB signal exists before touching infrastructure.
