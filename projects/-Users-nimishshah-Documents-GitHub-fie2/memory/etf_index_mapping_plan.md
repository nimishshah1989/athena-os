---
name: etf_index_mapping_plan
description: Plan to map TradingView ETFs to indices for compass and market pulse — defense, metals, railways, etc.
type: project
---

## ETF → Index Mapping Plan (from TradingView watchlist 199222355)

### ETFs Already Mapped in Compass/Pulse
| ETF | Index | Status |
|-----|-------|--------|
| NIFTYBEES | NIFTY 50 | Tracked |
| BANKBEES | NIFTY BANK | Tracked |
| ITBEES | NIFTY IT | Tracked |
| PHARMABEES | NIFTY PHARMA | Tracked |
| JUNIORBEES | NIFTY NEXT 50 | Tracked |
| MID150BEES | NIFTY MIDCAP 150 | Tracked |
| PSUBNKBEES | NIFTY PSU BANK | Tracked |
| INFRABEES | NIFTY INFRASTRUCTURE | Tracked |
| AUTOBEES | NIFTY AUTO | Tracked |
| FMCGIETF | NIFTY FMCG | Tracked |
| CPSEETF | NIFTY CPSE | Tracked |
| PVTBANIETF | NIFTY PRIVATE BANK | Tracked |
| CONSUMBEES | NIFTY CONSUMPTION | Tracked |

### ETFs for Indices We Track but Haven't Mapped ETFs To
| ETF | Maps To Index | Action |
|-----|---------------|--------|
| METALIETF | NIFTY METAL | Add to ETF universe |
| ENERGY | NIFTY ENERGY | Add to ETF universe |
| HEALTHY | NIFTY HEALTHCARE INDEX | Add to ETF universe |
| OILIETF | NIFTY OIL & GAS | Add to ETF universe |
| MOREALTY | NIFTY REALTY | Add to ETF universe |
| GROWWDEFNC | NIFTY INDIA DEFENCE | Add to ETF universe |
| MAKEINDIA | NIFTY INDIA MANUFACTURING | Add to ETF universe |
| SMALLCAP | NIFTY SMALLCAP 250 | Add to ETF universe |
| MON100 | NIFTY 100 | Add to ETF universe |
| MONIFTY500 | NIFTY 500 | Add to ETF universe |
| SENSEXBEES | SENSEX | Add to ETF universe |

### ETFs for Sectors/Themes NOT Tracked as Indices
| ETF | Sector/Theme | Action Needed |
|-----|--------------|---------------|
| GROWWRAIL | Railways | Add NIFTY TRANSPORTATION & LOGISTICS index |
| MOCAPITAL | Capital Goods | Add NIFTY INDIA CAPITAL GOODS index if exists |
| MOTOUR | Tourism | Check if NIFTY index exists |
| MAHKTECH | Technology (broader) | May map to NIFTY INDIA DIGITAL |
| COMMOIETF | Commodities basket | No single NIFTY index — skip or map to GOLD+SILVER |
| DIVOPPBEES | Dividend Opportunities | Factor/strategy — NIFTY DIVIDEND OPPORTUNITIES 50 |
| HNGSNGBEES | Hang Seng | International — not Indian sector |

### Commodity ETFs (Track Separately)
| ETF | Commodity | Already In Pulse? |
|-----|-----------|-------------------|
| GOLDBEES | Gold | Yes (GOLD in global) |
| SILVERBEES | Silver | Yes (SILVER in global) |

### Implementation Steps
1. **Update compass ETF universe** — Add the 11 unmapped ETFs to the sector compass ETF data loader
   - File: `services/compass_history.py` → ETF ticker list
   - These ETFs have NSE price data via yfinance (e.g., METALIETF.NS, GROWWDEFNC.NS)

2. **Add missing indices to pulse** — For railways, capital goods, tourism
   - Check NSE API for NIFTY TRANSPORTATION & LOGISTICS, NIFTY INDIA CAPITAL GOODS
   - Add to INDEX_SECTOR_MAP in constants.ts if they exist on NSE

3. **Create ETF→Index mapping table** — In constants.ts or backend config
   - Maps each ETF ticker to its corresponding index
   - Used by compass to show "tradeable via" on index cards

4. **Run ETF sweep** — After adding to universe, run momentum sweep on ETF data
   - Part of the overnight sweep runbook

### Priority
- Step 1 (ETF universe) — do when running ETF sweep tonight
- Step 2 (missing indices) — do now, quick constants update
- Step 3 (mapping table) — do after ETF data is confirmed
