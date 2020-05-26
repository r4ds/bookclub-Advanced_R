library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(arrow)
library(here)
library(tidyverse)

beers <- read_parquet(here('Presentations/Week9/data/beers.pdata'))

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
                  min = 0,max = 4000,step = 200,
                  value = c(2000,3000)),
      br(),
      pickerInput('beer_style',label = "Beer Style",
                  choices = unique(beers$beer_style),
                  selected = unique(beers$beer_style),
                  multiple = TRUE,
                  options = list(`selected-text-format` = "count>0",
                                 `actions-box` = TRUE,
                                 `live-search`=TRUE)),
      br(),
      sliderInput('review_avg',label = "Average Rating",
                  min = 0, max = 5, value = c(0,5), step = 0.25)
    ),
    box(
      title = "Select Beers to Review",
      width = 6,
      status = 'primary',
      pickerInput( "selected_beers", "Beer Selection",
        choices = beers$beer_name, selected = NULL,
        multiple = TRUE,options = list(title = "Select Beer",
                                       `selected-text-format` = "count>0",
                                       `live-search` = TRUE)
      )
    ),
    uiOutput("review_box")
    
  )
)

server <- function(input, output, session) {
  
  #### 1 - generate slider for each selected beer ####
  
  fn_beerslider <- function(input_id,input_label){
    box(width = 4,
    sliderInput(inputId = input_id, label = input_label, min = 0, max = 5, value = 2.5, step = 0.5)
    )
  }
  
  df_selectedbeers <- reactive({
    beers %>% 
      filter(beer_name %in% input$selected_beers) %>% 
      mutate(input_id = paste0("rating_",beer_id),
             input_label = paste0('Rating for ',beer_name))
  })
  
  output$review_box <- renderUI({
    
    req(input$selected_beers)
    
    box(width = 12, title = "Ratings Box",
        map2(df_selectedbeers()$input_id,df_selectedbeers()$input_label,fn_beerslider),
        br(),
        div(actionButton('submit_ratings',"Submit Ratings", class = 'btn-success'), style = 'text-align:center;')
        )
  })
  
  #### 2 - filter the original pickerinput [reduce] ####
  # filter function lifted from Hadley's Mastering Shiny ch10 #
  
  fn_filter <- function(x,val){
    
    if(is.numeric(x)) {return(!is.na(x) & x >= val[[1]] & x<=val[[2]])}
    
    if(is.character(x)) {return(x %in% val)}
    
    TRUE
  }
  
  filter_names <- c('review_count','beer_style','review_avg')
  
  filtered_beernames <- reactive({
    selected <- map(filter_names,~fn_filter(beers[[..1]],input[[..1]])) %>% 
      reduce(`&`)
    
    beers %>% 
      filter(selected) %>% 
      pull(beer_name)
  })
  
  observeEvent(filtered_beernames(),{
    updatePickerInput(session,"selected_beers",choices = filtered_beernames())
  })
  
  #### 3 - read inputs ####
  
  df_ratings <- eventReactive(input$submit_ratings,{
    df_selectedbeers() %>%
      mutate(user_rating= map_dbl(input_id,~input[[..1]])) %>%
      select(user_rating,everything())
  })
   
  #### 4 - write rows to csv based on brewery name [walk] ####
  
  observeEvent(df_ratings(),{
    
    df_save <- df_ratings() %>% 
      mutate(file_name = glue::glue('data/{brewery_name}.csv')) %>% 
      nest(data = -"file_name")
    
      walk2(df_save$data,df_save$file_name,~write_csv(..1,..2,append = file.exists(..2)))
      
      Sys.sleep(2)
      
      showModal(modalDialog("Saved to CSV!"))
  })


  
}

shinyApp(ui, server)