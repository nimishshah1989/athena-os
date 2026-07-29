---
name: Morningstar API endpoints
description: 10 Morningstar API endpoints available for MF data (more than the 2 originally spec'd)
type: project
---

Morningstar provides 10 API endpoints (not 1-2 as v2.0 spec assumed):

1. RiskDataMasterAPI - risk statistics (skewness, kurtosis, ratios)
2. Fund Holdings Detail - per-holding data with weights
3. Portfolio Summary + Sectors - sector allocation
4. Daily NAV for Simulation - NAV data
5. All Open End Schemes Identifier Data - fund identifiers (mstar_id, ISIN, AMFI code)
6. All Open End Schemes Category Data - category classification
7. All Open End Schemes Portfolio Data - portfolio composition
8. All Open End Schemes Factsheet Category Return Data - category-level returns
9. All Open End Schemes Factsheet Rank Data - fund rankings
10. All Open End Schemes Factsheet Nav Data - NAV data

Base URL pattern: `https://api.morningstar.com/v2/service/mf/{api_id}/{IdType}/{Identifier}?accesscode={accesscode}`
Also supports universe endpoint: `.../universeid/{universeId}?accesscode={accesscode}`

Access code and API IDs are in the project .env files on EC2.

**Why:** More APIs than spec'd means we can get richer fund data (risk stats, rankings, returns) directly from Morningstar rather than computing everything ourselves.
**How to apply:** Update MF pipeline to use relevant APIs. Risk data API eliminates need to compute some risk metrics from NAV. Holdings + Portfolio Summary APIs give us sector allocation directly.
