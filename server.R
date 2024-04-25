library(shiny)
library(here)
library("wordcloud")
library("ggplot2")


source("R/plot_code.R")
source("R/word_cloud.R")
# read data ---------------------------------------------------------------

source(here("R", "preprocess_data.R"))


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
              options = list(searching = TRUE, language = list(search = "Search in all columns"), paging = TRUE, ordering = TRUE), escape = FALSE
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
              options = list(searching = TRUE, language = list(search = "Search in all columns"),paging = TRUE, ordering = TRUE), escape = FALSE
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