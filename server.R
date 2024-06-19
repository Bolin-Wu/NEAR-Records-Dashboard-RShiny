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

 
 

  # Render history harmonization part
  output$history_table <- renderDT(
    renderHistoryProjTable(filtered_data_history())
  )



  # Create bar plot
  output$database_plot <- renderPlot({
    about_plot(data_dbpart, data_harmopart)
  })

  output$word_cloud <- renderPlot({
    word_cloud(data_history_raw)
  })
}
