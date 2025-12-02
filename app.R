# app.R
library(shiny)
library(shinyauthr)

source("ui.R")
source("server.R")

shinyApp(ui = ui, server = server)