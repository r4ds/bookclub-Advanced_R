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
             fluidRow(
               column(6, textInput("arg1", NULL)),
               column(6, textInput("val1", NULL))
             ),
             fluidRow(
               column(6, textInput("arg2", NULL)),
               column(6, textInput("val2", NULL))
             )
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
  
  argumentlist <- reactive({
    list(
      input$func,
      expr(!!parse_expr(input$val1)),
      expr(!!parse_expr(input$val2))
    ) %>% 
      setNames(c(".fn", input$arg1, input$arg2))
  })
  

  output$expression <- renderPrint({
    do.call(call2, argumentlist(), quote = TRUE)
    })
  
  output$tree <- renderPrint({
    ast(!! do.call(call2, argumentlist(), quote = TRUE))
  })
  
}

shinyApp(ui = ui, server = server)