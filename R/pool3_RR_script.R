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
