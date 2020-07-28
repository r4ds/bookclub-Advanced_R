library(shiny)

beer_states <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-31/beer_states.csv')

ui <- fluidPage(
    sidebarPanel(numericInput('xqty', 'Number of States', 3, 1, 10)),
    mainPanel(tableOutput("while_debug")))

server <- function(input, output, session) {
    
   states <- unique(beer_states$state)
    
   my_vector <- reactive({
        i <- 0
        my_vector <- vector()
        while (i <= input$xqty) {
            my_vector[i] <- i
            i = i+1
        }
        return(my_vector)
    })
    
    output$while_debug <- renderTable({
        
        beer_states %>%
            filter(state %in% unique(beer_states$state)[my_vector()]) %>%
            filter(state != "total") %>%
            group_by(state) %>%
            summarise(num_barrels = sum(barrels))
    })
}  
shinyApp(ui = ui, server = server)