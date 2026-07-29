---
name: Data richness priority
description: User wants every page and visual to be extremely rich and insightful, using all 200+ data points per fund. If something isn't available, add from APIs. Each visual must maximize data density.
type: feedback
---

User explicitly said: "I want to be able to display most data points that we have figured - we have over 200 data points per fund - so important we use them and if something is still not there - we can add from APIs. I want to ensure each of the pages and each visual within the page is extremely rich and insightful."

Key implications:
1. Always check reference_data_catalog.md before building any visual — use all relevant data points
2. Don't leave data on the table — if a metric exists in the DB, find a way to surface it
3. Pages that look sparse = failure. Every card should answer "so what?" with multiple data dimensions
4. Data not yet surfaced (from catalog): calendar year returns, kurtosis/skewness, capture ratios, fund manager data, investment strategy text, portfolio valuation metrics (P/E, P/B, ROE), bond metrics, index benchmarking, fund net flows
5. If a useful data point is missing, proactively suggest adding an API endpoint for it
