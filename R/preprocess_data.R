library(tidyverse)

data_history_raw <- readxl::read_excel("data/NEAR_history_harmonized_variables.xlsx", skip = 4)
data_history <- data_history_raw %>%
  pivot_longer(
    cols = -c("Category", "Measure", "Project", "Description", "Note"),
    names_to = "Database", values_to = "Variable_names"
  ) %>% 
  arrange(Measure, Project)


data_dbpart <- readxl::read_excel("data/Troubleshooting_database.xlsx", sheet = "record", guess_max = 21474836)
data_harmopart <- readxl::read_excel("data/Troubleshooting_harmonization.xlsx", sheet = "record", guess_max = 21474836)