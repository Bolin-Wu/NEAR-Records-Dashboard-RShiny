library("here")
library("DT")
library("tidyverse")
library("readxl")
library("bslib")
library("shiny")
library("shinythemes")
library("markdown")

# read data ---------------------------------------------------------------

data_dbpart <- read_excel("data/Troubleshooting_database.xlsx", sheet = "record", guess_max = 21474836)
data_harmopart <- read_excel("data/Troubleshooting_harmonization.xlsx", sheet = "record", guess_max = 21474836)
# tbs_harmonization <- read_docx("data/Troubleshooting_harmonization.docx")


# Define UI
ui <- fluidPage(
  theme = shinytheme("flatly"),
  titlePanel(
    div(
      img(src = "https://www.near-aging.se/wp-content/uploads/2018/09/near-logo-1.png", height = 60, style = "margin-right: 10px;"),  
      " Troubleshooting Records", 
      style = "display: flex; align-items: center;"
    )
  ),
  # Define tabs
  tabsetPanel(
    tabPanel(
      "Database",
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
          selectInput("database", "Select Database:", choices = unique(data_dbpart$Database))
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
      "Harmoniaztion",
      fluidRow(
        column(
          width = 12,
          includeMarkdown("text/harmonization_tab.md")
        )
      ),
      fluidRow(
        column(
          width = 6,
          selectInput("database_harmo", "Select Database:", choices = unique(data_harmopart$Database))
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
      "About",
      fluidRow(
        column(
          width = 12,
          includeMarkdown("text/about.md")
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Reactive expression to filter data based on database and variable search
  filtered_data_dbpart <- reactive({
    req(input$database)
    
    # Filter by database
    filtered <- data_dbpart %>%
      filter(Database == input$database)
    
    # If variable search is not empty, filter by variable
    if (input$variable != "") {
      filtered <- filtered %>%
        filter(str_detect(tolower(Variable), tolower(input$variable)))
    }
    
    return(filtered)
  })
  
  ## filter harmonization
  filtered_data_harmopart <- reactive({
    req(input$database)
    
    # Filter by database
    filtered <- data_harmopart %>%
      filter(Database == input$database_harmo)
    
    # If variable search is not empty, filter by variable
    if (input$variable_harmo != "") {
      filtered <- filtered %>%
        filter(str_detect(tolower(Variable), tolower(input$variable_harmo)))
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
    datatable(filtered_data_dbpart[, c("Variable", "Description", "Source")],
              options = list(dom = "t", paging = TRUE, ordering = TRUE), escape = FALSE
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
    datatable(filtered_data %>% select(-1),
              options = list(dom = "t", paging = TRUE, ordering = TRUE), escape = FALSE
    )
  })
}

# Run the application
shinyApp(ui = ui, server = server)
