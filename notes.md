# Pool 3 Response Ratio Project Notes

## Day 1 – Project setup

- Created project folder `pool3-responseratios`
- Initialized git
- Added README and notes
- Created `R/pool3_RR_script.R` for main R code
- Data files:
  - `pool3_responseratios.xlsx`: contains raw signals, RR results, etc.
  - `MIT research .pdf`: meeting notes with Eddie explaining self vs non-self normalization

## Data import

- Used `excel_sheets()` to list sheet names in `pool3_responseratios.xlsx`
- Confirmed that the main raw signal sheet is named `"reorder clean pair"`
- Loaded it as `raw_pairs` using `read_excel()`
- `glimpse(raw_pairs)` shows:
  - First column: `<whatever the name is>`
  - Remaining columns: metabolite and internal standard peak areas

## Reshape to long format

- Used `pivot_longer()` to convert `raw_pairs` from wide (1 row per sample, many metabolite columns)
  to long (`long_signals`):
  - Columns: `Filename` (sample ID), `metabolite`, `signal`
- This structure will make it easier to:
  - Attach metadata about each metabolite (internal standard, self vs non-self)
  - Join the internal standard signal for each (sample, metabolite)
