# pool3_RR_script.R
# Purpose: automate response ratio (RR) calculations for Pool 3 mass spec data.
# Author: Blaise
# Date: <today’s date>

# ----------------------------
# 1. Load packages
# ----------------------------

# If you haven't installed these yet, run IN THE R CONSOLE:
# install.packages(c("readxl", "dplyr", "tidyr", "writexl"))

library(readxl)
library(dplyr)
library(tidyr)
library(writexl)
# added for step 5:
library(readr)


# ----------------------------
# 2. Define file paths
# ----------------------------

excel_path <- "pool3_responseratios.xlsx"
# ----------------------------
# 3. Inspect Excel workbook
# ----------------------------

# List sheets to verify names
# These are the tabs in the xlsx file Eddie gave me
sheets <- excel_sheets(excel_path)
print(sheets) # (If names are slightly different, note thhat to adapt the code.)

# Read the main sheet with raw signals and pairings
raw_pairs <- read_excel(excel_path, sheet = "reorder clean pair")

# Quick look at structure
glimpse(raw_pairs)
head(raw_pairs)

# ----------------------------
# 4. Reshape to a long-ways format
# ----------------------------

# Change this to the actual name of your sample ID column (from glimpse)
sample_col <- "Filename"

long_signals <- raw_pairs %>%
  pivot_longer(
    cols = -all_of(sample_col),
    names_to = "metabolite",
    values_to = "signal"
  )
# Convert signal from character (text) to numeric
# Added for stage 6
long_signals <- long_signals %>%
  mutate(signal = as.numeric(signal))

# Inspect the reshaped data
head(long_signals)

# # ----------------------------
# # 5. Define metabolite ↔ internal standard mapping
# # ----------------------------

# metabolite_map <- tibble::tribble(
#   ~metabolite,                 ~internal_standard,        ~norm_type,

#   # -------------------------
#   # SELF-normalized examples
#   # -------------------------
#   "creatinine",                "creatinine-D3",           "self",
#   "hypoxanthine",              "hypoxanthine-13C5",       "self",

#   # -------------------------
#   # NON-SELF-normalized example
#   # (lactate IS is used for 3-hydroxybutyrate here)
#   # -------------------------
#   "3-hydroxybutyrate",         "lactate-13C9",            "non-self"

#   # TODO:
#   # Add ALL remaining metabolites found in `raw_pairs`
#   # including ones with ...15, ...17, ...19, ...21, ...23 suffixes
# )

# metabolite_map
# ----------------------------
# 5. Define metabolite ↔ internal standard mapping
# ----------------------------

# Read mapping from external CSV so we can edit it without changing code
metabolite_map <- readr::read_csv(
  "metabolite_map.csv",
  show_col_types = FALSE
)

metabolite_map

# ----------------------------
# 5b. Check that all metabolites have a mapping
# ----------------------------

# unique metabolite names from the data
data_mets <- sort(unique(long_signals$metabolite))

# metabolites that exist in data but have no row in the mapping
unmapped <- setdiff(data_mets, metabolite_map$metabolite)

if (length(unmapped) > 0) {
  warning("These metabolites appear in the data but are missing from metabolite_map.csv:\n",
          paste(unmapped, collapse = ", "))
}

# ----------------------------
# 6. Compute response ratios
# ----------------------------

# 6.1 Attach internal_standard and norm_type to each (sample, metabolite)
rr_long <- long_signals %>%
  left_join(metabolite_map, by = "metabolite")

# 6.2 Join internal standard signal: match on Filename + internal_standard name
rr_long <- rr_long %>%
  left_join(
    long_signals,
    by = c("Filename" = "Filename",
           "internal_standard" = "metabolite"),
    suffix = c("", "_IS")
  ) %>%
  mutate(
    response_ratio = signal / signal_IS
  )

# 6.3 Inspect a few rows
head(rr_long)
