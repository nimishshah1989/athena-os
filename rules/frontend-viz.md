---
globs: ["*.tsx", "*.jsx", "*.css", "*.html", "src/components/**", "src/pages/**"]
---
# Frontend + visualization conventions

## Design
- Professional wealth management aesthetic. Not generic Bootstrap
- White backgrounds, subtle borders, teal accents (#1D9E75)
- Data density: information-rich screens. Financial professionals want detail
- Mobile responsive but desktop-first (advisors use large screens)

## Visualization libraries
- Recharts: standard 2D charts (default choice)
- D3.js: complex interactive visualizations, force graphs
- Three.js: 3D correlation surfaces, terrain maps, multi-dimensional data
- Plotly: interactive 3D charts with zoom/rotate
- AG Grid: data-heavy tables with sorting, filtering, grouping

## Financial display
- Numbers: Indian lakh/crore (₹1,23,45,678). Never million/billion
- Percentages: always +/- sign. Green positive, red negative
- Currency: ₹ prefix. 2 decimal display, 4 decimal calculations
- Dates: DD-MMM-YYYY (04-Apr-2026). IST timezone
- Tables: right-align numbers, left-align text. Fixed header on scroll
- Charts: axis labels, legend, data source attribution always

## Interactivity
- Every chart: hover tooltip with exact values
- Every table: sortable, searchable, filterable, CSV export
- Drill-down: click aggregate → see constituent data
- Loading: skeleton screens, not spinners
