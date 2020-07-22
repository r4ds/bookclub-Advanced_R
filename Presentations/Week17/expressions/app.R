library(shiny)
library(purrr)
library(lobstr)
library(rlang)

ui <- fluidPage(
  
  includeCSS("styles.css"),
  
  titlePanel(h1("EXPRESSIONS", align = "center")),
  tags$p("Applying concepts from Chapter 18 of Hadley's Wickham's Advanced R", align="center"),
  
  br(), br(),
  
  fluidRow(
    column(2,
           h2("Functions"),
           br(),
           wellPanel(textInput("func", NULL, placeholder = "mean")),
           br(),
           wellPanel(
            numericInput("n", "Number of Arguments", value = 2, min = 1),
            fluidRow(
                column(6, "Arguments"),
                column(6, "Values")
             ),
             uiOutput("arguments")
           )
    ),
    column(6, 
           h2("Constructed Call"),
           br(),
           wellPanel(verbatimTextOutput("expression"))
           ),
    column(4, 
           h2("AST"),
           br(),
           wellPanel(verbatimTextOutput("tree"))
           )
  )
)


server <- function(input, output) {
  
  # create arg and val names 
  # for the number of user selected argument inputs
  arg_names <- reactive(paste0("arg", seq_len(input$n)))
  val_names <- reactive(paste0("val", seq_len(input$n)))
  
  # render the UI for arg1, arg2 etc etc... and val1, val2 etc etc 
  output$arguments <- renderUI({
    fluidRow(
      column(6, map(arg_names(), ~ textInput(.x, NULL, value = isolate(input[[.x]])) %||% "")),
      column(6, map(val_names(), ~ textInput(.x, NULL, value = isolate(input[[.x]])) %||% ""))
    )
  })
  
  argumentlist <- reactive({
    input_argnames <- map_chr(arg_names(),~input[[.x]])
    input_valnames <- map_chr(val_names(),~input[[.x]])
    c(
      # the function name as a string is fine
      list(input$func),
      # now get all the input$val's
      # and expr(!!parse_expr()) each of them
      map(input_valnames, ~ expr(!!parse_expr(.x)))
    ) %>%
      # set their names to the input$args
      setNames(c(".fn", input_argnames))
  })
 
  output$expression <- renderPrint({
    do.call(call2, argumentlist(), quote = TRUE)
    })
  
  output$tree <- renderPrint({
    ast(!! do.call(call2, argumentlist(), quote = TRUE))
  })
  
}

shinyApp(ui = ui, server = server)
