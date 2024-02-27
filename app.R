library("here")
source("R/clean_wdfile.R")

# Define UI
ui <- fluidPage(
  titlePanel("NEAR Records Troubleshooting"),
  sidebarLayout(
    sidebarPanel(
      selectInput("database", "Select Database:", choices = unique(tbs_database$Database)),
      textInput("variable", "Search Variable:", placeholder = "Type to search...")
    ),
    mainPanel(
      tableOutput("description_table")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Reactive expression to filter data based on database and variable search
  filtered_data <- reactive({
    req(input$database)
    
    # Filter by database
    filtered <- tbs_database %>%
      filter(Database == input$database)
    
    # If variable search is not empty, filter by variable
    if (input$variable != "") {
      filtered <- filtered %>%
        filter(str_detect(tolower(Variable), tolower(input$variable)))
    }
    
    return(filtered)
  })
  
  # Render description table
  output$description_table <- renderTable({
    filtered_data <- filtered_data()
    
    # If no records found, return NULL
    if (nrow(filtered_data) == 0) {
      return(NULL)
    }
    
    # Display all descriptions and sources if no variable search is made
    if (input$variable == "") {
      return(filtered_data[, c("Variable","Description", "Source")])
    } else {
      return(filtered_data[, c("Variable", "Description", "Source")])
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)