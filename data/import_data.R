library(readr)
library(here)
#library(arrow)

#### Tidy Tuesday Beer Data ####
## Readme 
## https://github.com/rfordatascience/tidytuesday/blob/master/data/2020/2020-03-31/readme.md

brewing_materials <- readr::read_csv(
  'https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-31/brewing_materials.csv')

beer_taxed <- readr::read_csv(
  'https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-31/beer_taxed.csv')

brewer_size <- readr::read_csv(
  'https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-31/brewer_size.csv')

beer_states <- readr::read_csv(
  'https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-31/beer_states.csv')

#### BeerAdvocate.com Reviews ####
## https://www.kaggle.com/rdoume/beerreviews

beer_reviews <- readr::read_csv(here::here('data/beer_reviews.csv.gz'))

## The following is faster to read, write, and stores smaller on-disk 
## (7 seconds read for csv.gz 27.4 MB vs 1 second read for parquet file 20.2 MB)
## Requires the arrow package (install.packages('arrow'))

# beer_reviews <- arrow::read_parquet(here::here('data/beer_reviews.pdata'))
