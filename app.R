library("here")
library("DT")
library("tidyverse")
library("readxl")

# read data ---------------------------------------------------------------

data <-  read_excel("data/Troubleshooting_database.xlsx",sheet = "record", guess_max = 21474836)
# tbs_harmonization <- read_docx("data/Troubleshooting_harmonization.docx")


# Define UI
ui <- fluidPage(
  titlePanel("NEAR troubleshooting records"),
  fluidRow( 
    column(
      width = 12,
      selectInput("database", "Select Database:", choices = unique(data$Database))
    ),
    column(
      width = 12,
      textInput("variable", "Search Variable:", placeholder = "Type to search...")
    )
  ),
  column(
    width = 12,
    DTOutput("description_table")
  )
)

# Define server logic
server <- function(input, output, session) {
  # Reactive expression to filter data based on database and variable search
  filtered_data <- reactive({
    req(input$database)

    # Filter by database
    filtered <- data %>%
      filter(Database == input$database)

    # If variable search is not empty, filter by variable
    if (input$variable != "") {
      filtered <- filtered %>%
        filter(str_detect(tolower(Variable), tolower(input$variable)))
    }

    return(filtered)
  })

  # Render description table
  output$description_table <- renderDT({
    filtered_data <- filtered_data()

    # If no records found, return an empty data table
    if (nrow(filtered_data) == 0) {
      return(data.frame()) # Return empty data frame
    }

    # Display all descriptions and sources if no variable search is made
    datatable(filtered_data[, c("Variable", "Description", "Source")],
      options = list(dom = "t", paging = TRUE, ordering = TRUE), escape = FALSE
    )
  })
}

# Run the application
shinyApp(ui = ui, server = server)
