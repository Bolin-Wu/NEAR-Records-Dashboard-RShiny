library(tidyverse)
library(readxl)
library(here)

# read data ---------------------------------------------------------------

data <-  read_excel("data/Troubleshooting_database.xlsx",sheet = "record", guess_max = 21474836)
# tbs_harmonization <- read_docx("data/Troubleshooting_harmonization.docx")


