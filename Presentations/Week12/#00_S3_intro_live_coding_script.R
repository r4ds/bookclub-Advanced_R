library(arrow)
library(here)
library(tidyverse)

reviews <- read_parquet(here("../data/beer_reviews.pdata"))

beer <- function(ratings, beer_name, beer_style){
  
  structure(
    ratings,
    name = beer_name,
    style = beer_style,
    class = "beer"
  )
}

most_common <- reviews %>% group_by(beer_beerid) %>%
  summarise(Count = n()) %>% arrange(desc(Count)) %>% 
  top_n(10)
df_2093 <- filter(reviews, beer_beerid == 2093)

ratings_2093 <- df_2093$review_overall 
name_2093 <- df_2093$beer_name[1]
style_2093 <- df_2093$beer_style[1]

beer_2093 <- beer(ratings_2093, name_2093, style_2093)
attributes(beer_2093)

print(beer_2093)


plot.beer <- function(my_beer){
  
  beer_df <- data.frame(reviews = unclass(my_beer))
  ggplot2::ggplot(beer_df, aes(x = reviews)) +
    ggplot2::geom_histogram(breaks = seq(0,5,0.5),
                            fill = "royalblue",
                            color = "black") + 
    theme_bw() + ggtitle(paste("Reviews of", attr(my_beer, "name")))
  
}

plot(beer_2093)

df_412 <- filter(reviews, beer_beerid == 412)
ratings_412 <- df_412$review_overall
name_412 <- df_412$beer_name[1]
style_412 <- df_412$beer_style[1]

beer_412 <- beer(ratings_412, name_412, style_412)

plot(beer_412)

class(ordered("x"))


ipa <- function(){
  
  structure(
    #blah blah blah
    
    
    class = c("ipa", "beer")
  )  
}


x1 <- 1:5
x2 <- structure(x1, class = "integer")
class(x2)

s3_dispatch(mean(x1))
s3_dispatch(mean(x2))





  
  