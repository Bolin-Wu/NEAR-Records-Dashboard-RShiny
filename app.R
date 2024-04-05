# app.R

library(shiny)

# Load UI and server functions from separate scripts
source("ui.R")
source("server.R")

# Run the application
shinyApp(ui = ui, server = server)