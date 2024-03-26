library(tidyverse)

data_history_raw <- read_excel("data/NEAR_history_harmonized_variables.xlsx", skip = 4)
data_history <- data_history_raw %>%
  distinct(Measure, .keep_all = T) %>%
  pivot_longer(
    cols = -c("Category", "Measure", "Project", "Description", "Note"),
    names_to = "Database", values_to = "Variable_names"
  ) %>% 
  arrange(Measure, Project)
