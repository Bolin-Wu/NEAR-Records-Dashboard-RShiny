library("here")
library("DT")
library("tidyverse")
library("bslib")
library("shiny")
library("joycon")
library("shinythemes")
library("markdown")


# read data ---------------------------------------------------------------

source(here("R", "preprocess_data.R"))

# Get the current date

# Define UI
ui <- fluidPage(
  title = "NEAR Harmonization Records",
  theme = shinytheme("flatly"),
  titlePanel(
    div(
      style = "display: flex; align-items: center;",
      img(src = "https://www.near-aging.se/wp-content/uploads/2018/09/near-logo-1.png", height = 60, style = "margin-right: 10px;"),
      " Harmonization Records",
      style = "display: flex; align-items: center;"
    )
  ),
  # Add padding to entire content
  div(
    style = "padding-left: 40px; padding-right: 40px;",
    # Define tabs
    tabsetPanel(
      tabPanel(
        "About",
        fluidRow(
          column(
            width = 12,
            includeMarkdown("text/about.md")
          ),
          column(
            width = 12,
            br(),
            p("Number of Collected Inquiries", style = "text-align: center; font-weight: bold;"),
            plotOutput("database_plot", width = "100%", height = "800px")
          ),
          column(
            width = 12,
            br(),
            p("Part of History Harmonized Variables", style = "text-align: center; font-weight: bold;"),
            plotOutput("word_cloud", width = "100%", height = "800px")
          )
        )
      ),
      tabPanel(
        "Database inquiries",
        fluidRow(
          column(
            width = 12,
            includeMarkdown("text/database_tab.md")
          )
        ),
        # verbatimTextOutput("database_info"),
        fluidRow(
          column(
            width = 6,
            selectInput("database", "Select database:", choices = c("All", sort(unique(data_dbpart$Database))))
          ),
          column(
            width = 6,
            textInput("variable", "Search variable:", placeholder = "Type to search...")
          )
        ),
        column(
          width = 12,
          DTOutput("dbpart_table")
        )
      ),
      tabPanel(
        "Harmonization inquiries",
        fluidRow(
          column(
            width = 12,
            includeMarkdown("text/harmonization_tab.md")
          )
        ),
        fluidRow(
          column(
            width = 6,
            selectInput("database_harmo", "Select database:", choices = c("All", sort(unique(data_harmopart$Database))))
          ),
          column(
            width = 6,
            textInput("variable_harmo", "Search variable:", placeholder = "Type to search...")
          ),
          column(
            width = 12,
            DTOutput("harmopart_table")
          )
        )
      ),
      tabPanel(
        "History harmonization",
        fluidRow(
          column(
            width = 12,
            includeMarkdown("text/history_harmonization_tab.md")
          )
        ),
        fluidRow(
          column(
            width = 4,
            uiOutput("category_ui")
          ),
          column(
            width = 4,
            uiOutput("measure_ui")
          ),
          column(
            width = 4,
            uiOutput("project_ui")
          ),
          column(
            width = 12,
            # output for rest of the information
            DTOutput("history_table")
          )
        )
      )
    )
  )
)
