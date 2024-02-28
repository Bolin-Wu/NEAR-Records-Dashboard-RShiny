library("joycon")
library("ggplot2")
library("tidyverse")
# bar chart at the about tab ----------------------------------------------
about_plot <- function(data_dbpart, data_harmopart) {
  data_dbpart %>%
    bind_rows(data_harmopart) %>%
    count(Database) %>%
    ggplot(aes(x = Database, y = n, fill = Database)) +
    geom_bar(stat = "identity") +
    geom_text(aes(label = n), vjust = -0.5, size = 4) +
    theme_minimal() +
    labs(x = "Database", y = "Number of Entries", title = "Number of Troubleshooting Records") +
    scale_fill_manual(values = c(joycon_pal("Brewster"), joycon_pal("SalmonRun"), joycon_pal("NewHorizons"))) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      plot.title = element_text(hjust = 0.5, size = 16),
      legend.position = "none"
    )
}
