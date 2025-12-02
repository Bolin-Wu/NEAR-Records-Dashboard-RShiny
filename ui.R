# ui.R
library(shiny)
library(shinyauthr)
library(shinythemes)
library(DT)      
library(markdown)   

ui <- fluidPage(
  # Logout button (top-right when logged in)
  div(class = "pull-right", shinyauthr::logoutUI(id = "logout")),
  
  # Login panel – ONLY these arguments are allowed
  shinyauthr::loginUI(
    id = "login",
    title = tags$strong("NEAR Harmonization Records")
  ),
  
  # Main app appears here after successful login
  uiOutput("main_app_ui")
)