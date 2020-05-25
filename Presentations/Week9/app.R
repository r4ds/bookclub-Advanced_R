library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(arrow)
library(here)

beers <- read_parquet('data/beers.pdata')

ui <- dashboardPage(
  skin = 'black',
  title = "AdvR Bookclub W9 - Beer Rating App",
  dashboardHeader(title = "AdvR Bookclub W9"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    titlePanel("map_shiny(v,fun) - Beer Rating App"),
    br(),
    box(
      title = "Filter the Picker", width = 6, status = 'primary',
      sliderInput('review_count',"Review Count",
                  min = 0,max = 4000,
                  value = c(2000,3000)),
      br(),
      pickerInput('beer_style',label = "Beer Style",
                  choices = unique(beers$beer_style),
                  multiple = TRUE),
      br(),
      sliderInput('average_rating',label = "Average Rating",
                  min = 0, max = 5, value = c(0,5))
    ),
    box(
      title = "Select Beers to Review",
      width = 6,
      status = 'primary',
      pickerInput( "selected_beers", "Beer Selection",
        choices = beers$beer_name, selected = NULL,
        multiple = TRUE,options = list(title = "Select Beer", `live-search` = TRUE)
      )
    ),
    box(width = 12, title = "Review")
    
  )
)

server <- function(input, output, session) {
  
  
}

shinyApp(ui, server)