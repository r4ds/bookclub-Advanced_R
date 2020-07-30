library(shiny)
library(tidyverse)



brewing_materials <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-31/brewing_materials.csv')
beer_taxed <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-31/beer_taxed.csv')
brewer_size <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-31/brewer_size.csv')
beer_states <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-31/beer_states.csv')


ui <- fluidPage(
    sidebarLayout(
        sidebarPanel(
            selectInput(inputId = "dataset",
                        label = "Choose a dataset:",
                        choices = c("materials", "size", "states", "taxed"))
        ),
        mainPanel(
            verbatimTextOutput("summary")
        )
    )
)


server <- function(input, output) {
    
    datasetInput <- reactive({
        switch(input$dataset,
               "materials" = brewing_materials,
               "size" = brewer_size,
               "states" = beer_states,
               "taxed" = beer_taxed)
    })

    output$summary <- renderPrint({
        dataset <- datasetInput()
        summary(dataset)
    })
    
}

shinyApp(ui = ui, server = server)