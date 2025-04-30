library(dplyr)

# Initialize reactive values for selections
initialize_selections <- function() {
  reactiveValues(
    category = "All",
    measure = "All",
    project = "All"
  )
}

# Update reactive values based on input changes
observe_selection_updates <- function(input, selections) {
  observeEvent(input$category_history, {
    selections$category <- input$category_history
  })
  observeEvent(input$measure_select_history, {
    selections$measure <- input$measure_select_history
  })
  observeEvent(input$project_history, {
    selections$project <- input$project_history
  })
}

# Reactive dataset filtered by current selections
filtered_data <- function(selections, data_history) {
  reactive({
    data <- data_history
    if (selections$category != "All") {
      data <- data %>% filter(Category == selections$category)
    }
    if (selections$measure != "All") {
      data <- data %>% filter(Measure == selections$measure)
    }
    if (selections$project != "All") {
      data <- data %>% filter(Project == selections$project)
    }
    data
  })
}

# Render Category UI
render_category_ui <- function(output, selections, data_history) {
  output$category_ui <- renderUI({
    data <- data_history
    if (selections$measure != "All") {
      data <- data %>% filter(Measure == selections$measure)
    }
    if (selections$project != "All") {
      data <- data %>% filter(Project == selections$project)
    }
    category_choices <- c("All", sort(unique(data$Category)))

    selectInput(
      "category_history",
      "Select category",
      choices = category_choices,
      selected = selections$category
    )
  })
}

# Render Measure UI
render_measure_ui <- function(output, selections, data_history) {
  output$measure_ui <- renderUI({
    data <- data_history
    if (selections$category != "All") {
      data <- data %>% filter(Category == selections$category)
    }
    if (selections$project != "All") {
      data <- data %>% filter(Project == selections$project)
    }
    measure_choices <- c("All", sort(unique(data$Measure)))

    selectInput(
      "measure_select_history",
      "Select measure",
      choices = measure_choices,
      selected = selections$measure
    )
  })
}

# Render Project UI
render_project_ui <- function(output, selections, data_history) {
  output$project_ui <- renderUI({
    data <- data_history
    if (selections$category != "All") {
      data <- data %>% filter(Category == selections$category)
    }
    if (selections$measure != "All") {
      data <- data %>% filter(Measure == selections$measure)
    }
    project_choices <- c("All", sort(unique(data$Project)))

    selectInput(
      "project_history",
      "Select project",
      choices = project_choices,
      selected = selections$project
    )
  })
}

# Validate and update selections if they become invalid
validate_selections <- function(session, selections, filtered_data) {
  observe({
    category_choices <- c("All", sort(unique(filtered_data()$Category)))
    if (!selections$category %in% category_choices && selections$category != "All") {
      selections$category <- "All"
      updateSelectInput(session, "category_history", selected = "All")
    }

    measure_choices <- c("All", sort(unique(filtered_data()$Measure)))
    if (!selections$measure %in% measure_choices && selections$measure != "All") {
      selections$measure <- "All"
      updateSelectInput(session, "measure_select_history", selected = "All")
    }

    project_choices <- c("All", sort(unique(filtered_data()$Project)))
    if (!selections$project %in% project_choices && selections$project != "All") {
      selections$project <- "All"
      updateSelectInput(session, "project_history", selected = "All")
    }
  })
}


render_HistoryProj_table <- function(output, filtered_data_reactive) {
  output$history_table <- DT::renderDataTable(
    {
      filtered_data_reactive()
    },
    options = list(
      pageLength = 15, # Number of rows per page
      autoWidth = TRUE
    )
  )
}
