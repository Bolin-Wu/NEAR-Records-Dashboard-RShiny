renderMeasureUI <- function(input, data_history) {
  category <- input$category_history
  
  if (category == "All") {
    selectInput("measure_select_history", "Select measure", choices = c("All", unique(data_history$Measure)))
  } else {
    selectInput("measure_select_history", "Select measure", choices = c("All", unique(filter(data_history, Category == category)[["Measure"]])))
  }
}

renderProjectUI <- function(input, data_history) {
  category <- input$category_history
  measure <- input$measure_select_history
  
  if (category == "All" & measure == "All") {
    selectInput("project_history", "Select project", choices = c("All", sort(unique(data_history$Project))))
  } else if (category != "All" & measure == "All") {
    selectInput("project_history", "Select project", choices = c("All", sort(unique(filter(data_history, Category == category)[["Project"]]))))
  } else if (measure != "All" & category == "All") {
    selectInput("project_history", "Select project", choices = c("All", sort(unique(filter(data_history, Measure == measure)[["Project"]]))))
  } else {
    selectInput("project_history", "Select project", choices = c("All", sort(unique(filter(data_history, Measure == measure, Category == category)[["Project"]]))))
  }
}


filterHistoryData <- function(data, category, project, measure) {
  req(category, project, measure)
  
  # Filter by category
  if (category == "All") {
    filtered <- data
  } else {
    filtered <- data %>%
      filter(Category == category) %>%
      select(-Category)
  }
  
  # Filter by project
  if (project == "All") {
    filtered <- filtered
  } else {
    filtered <- filtered %>%
      filter(Project == project) %>%
      select(-Project)
  }
  
  # Filter by measure
  if (measure == "All") {
    filtered <- filtered
  } else {
    filtered <- filtered %>%
      filter(Measure == measure)
  }
  
  return(filtered)
}