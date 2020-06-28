#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <-

    fluidPage(
        wellPanel(
            column(width = 9,
                   div("Test", style="background-color:red;")),
            column(width = 3,
                   div("hello", style="background-color:blue;"))
        )
    )

# Define server logic required to draw a histogram
server <- function(input, output) {
}

# Run the application
shinyApp(ui = ui, server = server)
