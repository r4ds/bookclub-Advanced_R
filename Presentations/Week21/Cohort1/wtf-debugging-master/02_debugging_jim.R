# dplyr::na_if(x, y) replaces NA values in `x` with `y`
# it works when x is a data.frame _without_ Date objects, but fails when there is a Date in the df
# Can you use our debugging tools to figure out where and why it is failing?
library(dplyr)

test <- tibble(a = lubridate::today() + runif(5) * 30, b = c(1:4, ""), c = c(runif(4), ""), d = c(sample(letters, 4, replace = TRUE), ""))
test

test %>% na_if("")

traceback()

# The traceback is easier to understand without the pipe involved
na_if(test, "")

# Also useful to look at the implementation of `na_if()`
# We get the same error from
test[test == ""] <- NA
traceback()

# And also from
as.Date("")

# So it seems we need to only use na_if on _character_ columns
test %>%
  mutate_if(is.character, ~ na_if(.x, ""))
