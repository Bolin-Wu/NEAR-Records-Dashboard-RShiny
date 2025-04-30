library(shiny)
library(here)
library("wordcloud")
library("ggplot2")


source("R/plot_code.R")
source("R/word_cloud.R")
# read data ---------------------------------------------------------------

source(here("R", "preprocess_data.R"))
source(here("R", "history_proj_server.R"))
source(here("R", "dbpart_server.R"))
source(here("R", "harmopart_server.R"))

# Define server logic
server <- function(input, output, session) {
  # Database tab: Reactive expression to filter data based on database and variable search
  filtered_data_dbpart <- reactive({
    filterData(data_dbpart, input$database, input$variable)
  })

  # Render database part
  output$dbpart_table <- renderDT({
    renderDataTable(filtered_data_dbpart())
  })

  # Harmonization tab: Reactive expression to filter harmonization data based on database and variable search
  filtered_data_harmopart <- reactive({
    filterHarmonizationData(data_harmopart, input$database_harmo, input$variable_harmo)
  })

  # render the table
  output$harmopart_table <- renderDT({
    renderHarmonizationTable(filtered_data_harmopart())
  })


  # History harmonization tab: make the ui input reactive on other input i --------
  # Initialize reactive values
  selections <- initialize_selections()

  # Update selections based on input changes
  observe_selection_updates(input, selections)

  # Create reactive filtered data
  filtered_data_reactive <- filtered_data(selections, data_history)

  # Render UI components
  render_category_ui(output, selections, data_history)
  render_measure_ui(output, selections, data_history)
  render_project_ui(output, selections, data_history)

  # Validate selections
  validate_selections(session, selections, filtered_data_reactive)

  # Render selected values for debugging
  render_selected_values(output, selections)

  # Render history harmonization part
  render_HistoryProj_table(output, filtered_data_reactive)

  # Create bar plot
  output$database_plot <- renderPlot({
    about_plot(data_dbpart, data_harmopart)
  })

  output$word_cloud <- renderPlot({
    word_cloud(data_history_raw)
  })
}
