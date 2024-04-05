library("here")
library("DT")
library("tidyverse")
library("ggplot2")
library("readxl")
library("bslib")
library("shiny")
library("joycon")
library("shinythemes")
library("markdown")
library("wordcloud")

# read data ---------------------------------------------------------------

data_dbpart <- read_excel("data/Troubleshooting_database.xlsx", sheet = "record", guess_max = 21474836)
data_harmopart <- read_excel("data/Troubleshooting_harmonization.xlsx", sheet = "record", guess_max = 21474836)
source(here("R", "preprocess_harmo_history.R"))

# Get the current date
last_update_date <- "2024-03-26" # Sys.Date()
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
          plotOutput("database_plot")
        ),
        column(
          width = 12,
          br(),
          p("Part of history harmonized variables:", style = "text-align: center; font-weight: bold;"),
          plotOutput("word_cloud"),
          p("Last update: ", last_update_date)
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
          selectInput("database", "Select Database:", choices = c("All", sort(unique(data_dbpart$Database))))
        ),
        column(
          width = 6,
          textInput("variable", "Search Variable:", placeholder = "Type to search...")
        )
      ),
      column(
        width = 12,
        DTOutput("dbpart_table")
      )
    ),
    tabPanel(
      "Harmoniaztion inquiries",
      fluidRow(
        column(
          width = 12,
          includeMarkdown("text/harmonization_tab.md")
        )
      ),
      fluidRow(
        column(
          width = 6,
          selectInput("database_harmo", "Select Database:", choices = c("All", sort(unique(data_harmopart$Database))))
        ),
        column(
          width = 6,
          textInput("variable_harmo", "Search Variable:", placeholder = "Type to search...")
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
          width = 6,
          selectInput("category_history", "Select Category:", choices = c("All", sort(unique(data_history$Category))))
        ),
        column(
          width = 6,
          uiOutput("measure_ui")
        ),
        column(
          width = 6,
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

source("R/plot_code.R")
source("R/word_cloud.R")
measures <- unique(data_history$Measure)
# Define server logic
server <- function(input, output, session) {
  # Render Measure select input based on Category selection
  output$measure_ui <- renderUI({
    category <- input$category_history

    # If category is All, show all measures, else show measures based on category
    if (category == "All") {
      selectInput("measure_select_history", "Select Measure", choices = c("All", unique(data_history$Measure)))
    } else {
      selectInput("measure_select_history", "Select Measure", choices = c("All", unique(filter(data_history, Category == category)[["Measure"]])))
    }
  })

  # Render Project select input based on Category AND Measure selection
  output$project_ui <- renderUI({
    category <- input$category_history
    measure <- input$measure_select_history

    # If category is All, show all measures, else show measures based on category
    if (category == "All" & measure == "All") {
      selectInput("project_history", "Select Project", choices = c("All", sort(unique(data_history$Project))))
    } else if (category != "All" & measure == "All") {
      selectInput("project_history", "Select Project", choices = c("All", sort(unique(filter(data_history, Category == category)[["Project"]]))))
    } else if (measure != "All" & category == "All") {
      selectInput("project_history", "Select Project", choices = c("All", sort(unique(filter(data_history, Measure == measure)[["Project"]]))))
    } else {
      selectInput("project_history", "Select Project", choices = c("All", sort(unique(filter(data_history, Measure == measure, Category == category)[["Project"]]))))
    }
  })

  # Reactive expression to filter data based on database and variable search
  filtered_data_dbpart <- reactive({
    req(input$database)

    # Filter by database
    if (input$database == "All") {
      filtered <- data_dbpart
    } else {
      filtered <- data_dbpart %>%
        filter(Database == input$database) %>%
        select(-1)
    }

    # If variable search is not empty, filter by variable
    if (input$variable != "") {
      filtered <- filtered %>%
        filter(str_detect(tolower(Variable), tolower(input$variable)))
    }

    return(filtered)
  })

  ## filter harmonization
  filtered_data_harmopart <- reactive({
    req(input$database_harmo)

    # Filter by database
    if (input$database_harmo == "All") {
      filtered <- data_harmopart
    } else {
      filtered <- data_harmopart %>%
        filter(Database == input$database_harmo) %>%
        select(-1)
    }

    # If variable search is not empty, filter by variable
    if (input$variable_harmo != "") {
      filtered <- filtered %>%
        filter(str_detect(tolower(Variable), tolower(input$variable_harmo)))
    }

    return(filtered)
  })


  ## filter history harmonization tibble
  filtered_data_history <- reactive({
    req(input$project_history)

    # Filter by category
    if (input$category_history == "All") {
      filtered <- data_history
    } else {
      filtered <- data_history %>%
        filter(Category == input$category_history) %>%
        select(-Category)
    }

    # filter by project
    if (input$project_history == "All") {
      filtered <- filtered
    } else {
      filtered <- filtered %>%
        filter(Project == input$project_history) %>%
        select(-Project)
    }

    # filter by measure
    if (input$measure_select_history == "All") {
      filtered <- filtered
    } else {
      filtered <- filtered %>%
        filter(Measure == input$measure_select_history)
    }

    return(filtered)
  })

  # Render database part
  output$dbpart_table <- renderDT({
    filtered_data_dbpart <- filtered_data_dbpart()

    # If no records found, return an empty data table
    if (nrow(filtered_data_dbpart) == 0) {
      return(data.frame()) # Return empty data frame
    }

    # Display all descriptions and sources if no variable search is made
    datatable(filtered_data_dbpart,
      options = list(searching = FALSE, paging = TRUE, ordering = TRUE), escape = FALSE
    )
  })
  # Render harmonization part
  output$harmopart_table <- renderDT({
    filtered_data <- filtered_data_harmopart()

    # If no records found, return an empty data table
    if (nrow(filtered_data) == 0) {
      return(data.frame()) # Return empty data frame
    }

    # Display all descriptions and sources if no variable search is made
    datatable(filtered_data,
      options = list(searching = FALSE, paging = TRUE, ordering = TRUE), escape = FALSE
    )
  })

  # Render history harmonization part
  output$history_table <- renderDT({
    filtered_history_data <- filtered_data_history()

    # If no records found, return an empty data table
    if (nrow(filtered_history_data) == 0) {
      return(data.frame()) # Return empty data frame
    }

    # Display all descriptions and sources if no variable search is made
    datatable(filtered_history_data,
      options = list(searching = TRUE, paging = TRUE, ordering = TRUE, pageLength = length(unique(data_history$Database))), escape = FALSE
    )
  })



  # Create bar plot
  output$database_plot <- renderPlot({
    about_plot(data_dbpart, data_harmopart)
  })

  output$word_cloud <- renderPlot({
    word_cloud(data_history_raw)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
