# server.R
library(shiny)
library(shinyauthr)
library(tibble)
library(here)
library(wordcloud)
library(ggplot2)

# ==================== USER DATABASE (must be here) ====================

load_users <- function() {
  user_file <- "data/near_users.rds"

  if (!file.exists(user_file)) {
    stop("User database not found. Contact administrator.")
  }

  tryCatch(
    {
      readRDS(user_file)
    },
    error = function(e) {
      stop("Could not read user database. Check file permissions.")
    }
  )
}

# Load users safely
user_base <- load_users()
# Load your existing code
source(here("R/preprocess_data.R"))
source("R/plot_code.R")
source("R/word_cloud.R")
source(here("R/history_proj_server.R"))
source(here("R/dbpart_server.R"))
source(here("R/harmopart_server.R"))

# ==================== THE FULL ORIGINAL UI (defined once) ====================
full_app_ui <- fluidPage(
  title = "NEAR Harmonization Records",
  theme = shinytheme("flatly"),
  titlePanel(div(
    style = "display: flex; align-items: center;",
    img(
      src = "https://www.near-aging.se/wp-content/uploads/2018/09/near-logo-1.png",
      height = 60, style = "margin-right: 10px;"
    ),
    " Harmonization Records"
  )),
  div(
    style = "padding-left: 40px; padding-right: 40px;",
    tabsetPanel(
      # ────── ALL ORIGINAL TABS (copy-paste exactly as before) ──────
      tabPanel(
        "About",
        fluidRow(column(12, includeMarkdown("text/about.md"))),
        fluidRow(column(
          8, br(),
          p("Number of Collected Inquiries",
            style = "text-align: center; font-weight: bold;"
          ),
          plotOutput("database_plot", height = "800px")
        ),column(
          4, br(),
          p("Part of History Harmonized Variables",
            style = "text-align: center; font-weight: bold;"
          ),
          plotOutput("word_cloud", height = "800px")
        ))
      ),
      tabPanel(
        "Database inquiries",
        fluidRow(column(12, includeMarkdown("text/database_tab.md"))),
        fluidRow(
          column(6, selectInput("database", "Select database:",
            choices = c("All", sort(unique(data_dbpart$Database)))
          )),
          column(6, textInput("variable", "Search variable:", placeholder = "Type to search..."))
        ),
        column(12, DTOutput("dbpart_table"))
      ),
      tabPanel(
        "Harmonization inquiries",
        fluidRow(column(12, includeMarkdown("text/harmonization_tab.md"))),
        fluidRow(
          column(6, selectInput("database_harmo", "Select database:",
            choices = c("All", sort(unique(data_harmopart$Database)))
          )),
          column(6, textInput("variable_harmo", "Search variable:", placeholder = "Type to search..."))
        ),
        column(12, DTOutput("harmopart_table"))
      ),
      tabPanel(
        "History harmonization",
        fluidRow(column(12, includeMarkdown("text/history_harmonization_tab.md"))),
        fluidRow(
          column(4, uiOutput("category_ui")),
          column(4, uiOutput("measure_ui")),
          column(4, uiOutput("project_ui"))
        ),
        column(12, DTOutput("history_table"))
      )
    )
  )
)

# ============================= SERVER =============================
server <- function(input, output, session) {
  # ---- Authentication ----
  credentials <- loginServer(
    id = "login",
    data = user_base,
    user_col = user,
    pwd_col = password,
    sodium_hashed = TRUE,
    log_out = reactive(logout_init())
  )

  logout_init <- logoutServer(
    id = "logout",
    active = reactive(credentials()$user_auth)
  )

  # ---- Show full app ONLY when logged in ----
  output$main_app_ui <- renderUI({
    req(credentials()$user_auth) # ← this line blocks everything
    full_app_ui # ← complete original dashboard
  })

  # ---- All the original server logic (unchanged) ----
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
