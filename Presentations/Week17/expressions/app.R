library(shiny)
library(purrr)
library(lobstr)
library(rlang)
library(tidyverse)

source("get_all_formals.R")

ui <- fluidPage(
  
  includeCSS("styles.css"),
  
  titlePanel(h1("EXPRESSIONS", align = "center")),
  tags$p("Applying concepts from Chapter 18 of Hadley's Wickham's Advanced R", align="center"),
  
  br(), br(),
  
  fluidRow(
    column(4,
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
           ),
           textOutput("debug")
    ),
    column(4, 
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


server <- function(input, output, session) {
  
  # grab the formals based on the user specified function
  all_formals <- reactive({ 
    req(input$func)
    # if errors, return empty string
    safe_formals <- purrr::possibly(get_all_formals, "")
    # there are functions that don't have arguments
    # like switch, so we'll make an empty field 
    safe_formals(!!input$func) %||% " "
  })
  
  observeEvent(input$func, {
    x <- ifelse(input$func == "", 0, length(formals()))
    updateNumericInput(session, inputId = "n", value = x)
  })

  # create a list of formals that are not elipse
  formals <- reactive({
    req(all_formals())
    all_formals()[all_formals() != "..."]
  })
  
  
  arg_names <- reactive(paste0("arg", (seq_len(input$n))))
  val_names <- reactive(paste0("val", (seq_len(input$n))))

  # render the UI for arg1, arg2 etc etc... and val1, val2 etc etc
  output$arguments <- renderUI({
    args <- rep(NA, input$n)
    args <- formals()[1:length(args)]
    fluidRow(
      column(6, map2(arg_names(), args, function(x,y) textInput(x, NULL, value = y))),
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
    req(input$func)
    do.call(call2, argumentlist(), quote = TRUE)
    })

  output$tree <- renderPrint({
    req(input$func)
    ast(!! do.call(call2, argumentlist(), quote = TRUE))
  })
  
}

shinyApp(ui = ui, server = server)
