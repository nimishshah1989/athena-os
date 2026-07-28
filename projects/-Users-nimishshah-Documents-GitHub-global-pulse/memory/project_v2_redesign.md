---
name: Momentum Compass V2 Redesign Plan
description: Complete redesign plan — simplify to 3-screen Country→Sector→ETF flow with mega Stooq bulk data ingest, GICS sector standardization, no stocks, no mock data
type: project
---

## Momentum Compass V2 — Status (2026-03-20)

### COMPLETED

**Phase 1: Bug fixes + frontend cleanup**
- Fixed datetime.utcnow function reference bug in models.py
- Fixed opportunity insert datetime format
- Removed 8 old screens, all mock data files, unused hooks/stores/types
- Created 3 new screens: Countries.tsx, Sectors.tsx, ETFs.tsx

**Phase 2: Stooq bulk data ingestion**
- Exported 5,611 instruments + 7.8M price rows from Stooq CSVs
- Strategy: CSV export → SCP → server-side COPY (fast vs slow SSH tunnel)
- Cleaned price outliers (spike-down and spike-up patterns, 500+ bad rows removed)
- Final DB state: 9,021 instruments, 8.2M prices

**Phase 3: GICS sector standardization**
- Normalized 118 granular sectors → 11 GICS sectors via SQL
- Applied keyword-based classification for named ETFs
- Applied ticker-based overrides for known ETFs (XLK, IXN, TOPIX sectors)
- 690 instruments classified into GICS sectors
- ~6,600 remain unclassified (ticker-only names, yfinance enrichment rate-limited)

**Phase 4: RS computation**
- Modified compute_rs_batch.py to load instruments from DB (not JSON file)
- Added batched price loading (500 at a time)
- 7,676 instruments scored, 1,369 opportunities generated
- Fixed timezone-aware datetime issue for opportunities table

**Phase 5: Frontend deployed**
- 3-screen flow working: Country → Sector → ETF
- All data from real DB, no mock data
- Fixed ETF returns being null (missing _enrich_with_returns call)
- Fixed benchmark_id assignments for UK, HK, JP, US

### DB STATE
- 9,021 instruments (6,820 ETFs, 807 bond_etfs, 446 sector_etfs, 370 regional, 152 country_etfs, 125 indices)
- 8,197,422 price records
- 7,676 RS scores
- Countries covered: UK (4,849 ETFs), US (1,654), JP (497), HK (203), plus CN, CA, KR, BR, AU, TW, IN
- US: all 11 GICS sectors well-covered (10-236 ETFs per sector)
- Other countries: sparse sector coverage due to ticker-only names

### KNOWN LIMITATIONS
- UK has only 1 classified sector ETF (ZINC_UK materials) due to ticker-only names
- HK has only 1 sector ETF (KTEC_US tech)
- yfinance name enrichment failed due to rate limiting (429 errors)
- Data from Stooq is up to 2026-03-18 (not yet automated for daily refresh)

### SERVER
- EC2: 13.206.34.214 (jslwealth)
- URL: global-pulse.jslwealth.in
- Containers: compass-backend (8011), compass-frontend (8010), compass-db (5433), compass-redis (6380)
- Branch: claude/review-and-plan-architecture-6aWr1

### NEXT STEPS (future sessions)
1. Enrich UK/HK/JP ETF names via yfinance (with rate limiting — batch over multiple days)
2. Set up daily automated data refresh (Stooq CSV + yfinance gap-fill)
3. Add more sector ETFs for non-US markets
4. Consider dark mode toggle for traders
