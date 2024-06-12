library(shiny)
library(here)
library("wordcloud")
library("ggplot2")


source("R/plot_code.R")
source("R/word_cloud.R")
# read data ---------------------------------------------------------------

source(here("R", "preprocess_data.R"))
source(here("R", "history_proj_server.R"))

# Define server logic
server <- function(input, output, session) {

  
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

  # History harmonization tab: make the ui input reactive on other input i --------
  # Render Measure select input based on Category selection
  observe({
    output$measure_ui <- renderUI({
      renderMeasureUI(input, data_history)
    })
  })
  
  observe({
    # Render Project select input based on Category AND Measure selection
    output$project_ui <- renderUI({
      renderProjectUI(input, data_history)
    })
  })
  
  filtered_data_history <- reactive({
    filterHistoryData(
      data_history, 
      input$category_history, 
      input$project_history, 
      input$measure_select_history
    )
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
      options = list(searching = TRUE, language = list(search = "Search all columns: "), paging = TRUE, ordering = TRUE, pageLength = 25), escape = FALSE
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
      options = list(searching = TRUE, language = list(search = "Search all columns: "), paging = TRUE, ordering = TRUE, pageLength = 25), escape = FALSE
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
