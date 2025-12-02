library(shiny)
library(shinyauthr)
library(shinythemes)
library(DT)
library(markdown)

# ==================== THE UI DEFINITION WITH LOGIN ====================
ui <- fluidPage(
  br(),
  theme = shinytheme("flatly"),
  # Logout button (top-right when logged in)
  div(class = "pull-right", shinyauthr::logoutUI(id = "logout")),
  
  
  shinyauthr::loginUI(id = "login", title = "Harmonization Records",additional_ui = tagList(
    tags$hr(style = "margin:10px 0; border-color:#eee;"),
    
    tags$p(style = "color:#555; font-size:14px;",
           "Only authorized NEAR members can access this dashboard."),
    
    tags$p(style = "color:#555; font-size:14px;",
           "If you need access, please contact ",
           tags$a(href = "mailto:bolin.wu@ki.se",
                  "Bolin Wu"
                  ),
           "."
    ),
    tags$div(style = "text-align:center; margin-bottom:25px;",
             img(src = "https://www.near-aging.se/wp-content/uploads/2018/09/near-logo-1.png",
                 style = "width:140px; height:auto;",
                 alt = "NEAR Logo")
    )
  )),
  
  # Main app appears here after successful login
  uiOutput("main_app_ui")
)