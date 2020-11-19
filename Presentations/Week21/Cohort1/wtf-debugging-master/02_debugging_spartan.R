# dplyr::na_if(x, y) replaces NA values in `x` with `y`
# it works when x is a data.frame _without_ Date objects, but fails when there is a Date in the df
# Can you use our debugging tools to figure out where and why it is failing?
library(dplyr)

test <- tibble(a = lubridate::today() + runif(5) * 30, b = c(1:4, ""), c = c(runif(4), ""), d = c(sample(letters, 4, replace = TRUE), ""))
test

test %>% na_if("")
