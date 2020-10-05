# Improving performance {-}

## 24.3 Existing solutions {-}

:::question
What's another example besides speeding up the mean that we can find an answer to bo looking at the [CRAN task views](http://cran.rstudio.com/web/views/)?
:::

:::TODO
:::

## 24.5 Vectorize {-}

:::question
What do these examples of vectorized functions actually do?

```
rowAny <- function(x) rowSums(x) > 0
rowAll <- function(x) rowSums(x) == ncol(x)
```
:::

:::TODO
:::


:::question
What is meant by this? How do you achieve this with code?

> If you’re extracting or replacing values in scattered locations in a matrix or data frame, subset with an integer matrix.
:::

:::question
> If you’re converting continuous values to categorical make sure you know how to use cut() and findInterval().

As opposed to what slower, commonly used method? `as.factor`? Can we use them in some example and see how they're faster using `bench`?
:::

:::TODO
:::

## 24.8 Other Techniques {-}


mean1 <- function(x) mean(x)
mean2 <- function(x) sum(x) / length(x)

http://stackoverflow.com/questions/22515525#22518603
http://stackoverflow.com/questions/22515175#22515856
http://stackoverflow.com/questions/3476015#22511936
http://cran.rstudio.com/web/views/
http://cran.r-project.org/web/packages/Rcpp
http://www.burns-stat.com/pages/Tutor/R_inferno.pdf

