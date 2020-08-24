library(shiny)
library(DBI)
library(pool)
library(dplyr)

# App that connects to a database instance on AWS
# table to fetch from mydb is called table1

conf <- config::get()

pool <- dbPool(
  drv = RMariaDB::MariaDB(),
  dbname = conf$dbname,
  username = conf$username,
  password = conf$password,
  host = conf$host,
  port = conf$port)

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(numericInput("num", "Input to DB", 0),
                 actionButton("add", "Add to DB")),
    mainPanel(tableOutput("tbl"))
  )
)

server <- function(input, output, session) {
  
  data <- reactivePoll(1000, session = NULL, 
                       checkFunc = function() {
                         row_count <- dbGetQuery(pool, "SELECT * FROM table1;") %>% nrow()
                       },
                       valueFunc = function() {
                         dbGetQuery(pool, "SELECT * FROM table1;")
                       })
  output$tbl <- renderTable({
    data()
  })
  current_data <- 
  observeEvent(input$add,
               {
                 dbExecute(pool, paste0("INSERT INTO table1 (var1) VALUES (", as.integer(input$num), ");"))
               })
}

shinyApp(ui, server)