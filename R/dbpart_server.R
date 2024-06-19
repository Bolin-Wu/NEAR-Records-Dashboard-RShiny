# Function to filter data based on database and variable search
filterData <- function(data, database, variable) {
  req(database)
  
  # Filter by database
  if (database == "All") {
    filtered <- data
  } else {
    filtered <- data %>%
      filter(Database == database) %>%
      select(-1)
  }
  
  # If variable search is not empty, filter by variable
  if (variable != "") {
    filtered <- filtered %>%
      filter(str_detect(tolower(Variable), tolower(variable)))
  }
  
  return(filtered)
}

# Function to render DataTable
renderDataTable <- function(filtered_data) {
  # If no records found, return an empty data table
  if (nrow(filtered_data) == 0) {
    return(data.frame()) # Return empty data frame
  }
  
  # Display all descriptions and sources if no variable search is made
  datatable(filtered_data,
            options = list(searching = TRUE, language = list(search = "Search all columns: "), paging = TRUE, ordering = TRUE, pageLength = 25), escape = FALSE
  )
}