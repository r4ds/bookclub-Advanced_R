# Functionals



## 9.2.2 Anonymous functions and shortcuts {-}

:::question
We saw you'll get an error if you try to map over elements that don't exist, and can use `.default` to override that. Is this related to `tryCatch` in some way? Can we look at the `map` source code for `.default?` And how would we overcome this error if we were to use base R's `lapply(x, 'two')`


```r
x <- list(
  list(one = "a"),
  list(two = "b"),
  list(three = "c")
)

map_chr(x, 'two', .default = NA)
```

```
## [1] NA  "b" NA
```


```r
lapply(x, 'two')
```

```
Error in get(as.character(FUN), mode = "function", envir = envir) : object 'two' of mode 'function' was not found
```
:::


Within `purrr` [there's the function](https://github.com/tidyverse/purrr/blob/7104367bb6599f13e56c554bd07488b508a8a02b/R/as_mapper.R#L98)


```r
find_extract_default <- function(.null, .default) {
  if (!missing(.null)) {
    .null
  } else {
    .default
  }
}
```

So it doesn't seem to be a conditional, but rather a way to deal with missing errors


```r
as.character(lapply(x,`[[`,"two"))
```

```
[1] "NULL" "b" "NULL"
```

## 9.2.6.4 Exercise {-}

:::question
In order to extract p-values the solution manual suggests using `map_dbl` but could we use `pluck` to get these values? If so how?
:::


```r
trials <- map(1:100, ~ t.test(rpois(10, 10), rpois(10, 7)))
# tibble(p_value = map_dbl(trials, "p.value"))
map_dbl(trials, pluck, "p.value")
```

```
##   [1] 7.203931e-02 4.568146e-03 5.007655e-01 6.343252e-03 1.423054e-02
##   [6] 5.315940e-02 2.715576e-02 1.424219e-02 5.817160e-02 7.991155e-02
##  [11] 6.216690e-03 1.159337e-02 1.085913e-01 5.258427e-02 8.325082e-02
##  [16] 2.267550e-02 6.206424e-04 2.284371e-03 1.683266e-01 3.089020e-01
##  [21] 2.806224e-01 1.899607e-01 4.089721e-01 9.643883e-02 4.460406e-03
##  [26] 6.169188e-01 1.672969e-02 5.458877e-03 6.889791e-01 1.124979e-03
##  [31] 2.660694e-03 1.832886e-01 1.203379e-01 2.036971e-02 8.973111e-02
##  [36] 4.572525e-02 2.054025e-01 1.730677e-02 1.171284e-01 1.050167e-01
##  [41] 8.931493e-03 3.038694e-02 8.090362e-02 3.796529e-04 1.415237e-02
##  [46] 6.112157e-01 1.406835e-02 7.143786e-04 2.910910e-01 1.341228e-02
##  [51] 8.191158e-04 1.510720e-01 4.637452e-02 7.593661e-03 4.092367e-01
##  [56] 3.592859e-02 5.233920e-03 3.512233e-03 2.810175e-03 2.272042e-01
##  [61] 4.077218e-02 7.051215e-01 3.817136e-01 5.029075e-02 6.669789e-01
##  [66] 3.751109e-02 2.775746e-02 7.167998e-02 1.629734e-01 1.559051e-01
##  [71] 9.623005e-03 2.236584e-01 4.749233e-01 3.770431e-01 2.467550e-03
##  [76] 1.063070e-02 3.695870e-04 1.274602e-01 3.736603e-03 1.219075e-01
##  [81] 3.042719e-01 1.178819e-04 9.016216e-02 5.284849e-01 2.204921e-03
##  [86] 1.199212e-04 1.157577e-03 2.462498e-01 2.266591e-05 3.444222e-03
##  [91] 5.144418e-03 1.728197e-03 2.571106e-01 4.501991e-03 5.858044e-02
##  [96] 1.880003e-02 1.573639e-01 2.425433e-02 4.520227e-03 4.793094e-04
```

## 9.2.6.5 Exercise {-}

:::question
Can we make this work?


```r
x <- list(
  list(1, c(3, 9)),
  list(c(3, 6), 7, c(4, 7, 6))
)

triple <- function(x) x * 3
# map(x, map, .f = triple)
```
:::

Specifying `.f` there replaces the second argument of the top level map function, so you'd be doing `map(.x = x, .f = triple, map)` which is not what you mean. What you want here is:


```r
map_depth(x, 2, triple)
```

```
## [[1]]
## [[1]][[1]]
## [1] 3
## 
## [[1]][[2]]
## [1]  9 27
## 
## 
## [[2]]
## [[2]][[1]]
## [1]  9 18
## 
## [[2]][[2]]
## [1] 21
## 
## [[2]][[3]]
## [1] 12 21 18
```

## 9.4.1 Same type of output as input: `modify()` {-}

When using modify we now get the warning:`Warning message: `modify()` is deprecated as of rlang 0.4.0. Vector tools are now out of scope for rlang to make it a more focused package.`

How should we rewrite this example?


```r
data.frame(
  x = 1:3,
  y = 6:4
) %>% 
  modify( ~ .x * 2)
```
:::

`rlang::modify` != `purrr::modify()`

## 9.4.5 Any number of inputs: pmap() and friends {-}

:::question
I want to use pmap to map over a vector, but the metadata for the functions other arguments is elsewhere - how would I combine these using `pmap`? The book says to name the metadata columns the same name as your function which I did but this still doesn't work?
:::


```r
my_data <- 1:3

metadata <- tribble(
  ~id, ~mult, ~adder,
  "one",   2,      5,
  "two",   3,      6,
  "three", 4,      7
)

the_function <- function(vec, id, mult, adder) {
  glue::glue("{id} is now {vec * mult + adder}")
}

# my_data doesn't change but we want to map over the metadata
# x = string
# y = multiplier
# z = adder
# pmap(list(metadata), ~the_function(vec = my_data))
```


```r
pmap(c(list(my_data), metadata), the_function)
```

```
## [[1]]
## one is now 7
## 
## [[2]]
## two is now 12
## 
## [[3]]
## three is now 19
```

## 9.4.6.2 Exercise {-}

:::question
I see how we can use `iwalk` and `walk2` for writing to multiple files, but the question asks about disadvantages to this - what would they be?
:::


```r
cyls <- split(mtcars, mtcars$cyl)
paths <- file.path(temp, paste0("cyl-", names(cyls), ".csv"))
walk2(cyls, paths, write.csv)

mtcars %>% 
  split(mtcars$cyl) %>% 
  set_names(~ file.path(temp, paste0("cyl-", .x, ".csv"))) %>% 
  iwalk(~ write.csv(.x, .y))
```

A readability problem mostly, as well as implicitly using `names(cyls)` as opposed to explicitly like it's used in paths


## 9.5.4 Multiple inputs {-}

:::question
Can we think of a simple example for `reduce()`?
:::

A Fibonacci function! 


```r
n <- 10
purrr::accumulate( .init = c(0L,1L),            # Starting with (0,1)
                   rep(0,n),                    # Accumulate n times
                   ~c(.x,sum(.x))[2:3]          # (x,y) -> (x, y, x+y)[2:3]
                 ) %>% 
    purrr::map_int( `[`, 1 ) 
```

```
##  [1]  0  1  1  2  3  5  8 13 21 34 55
```


## 9.6.3.2 Exercise {-}

:::question
I understand that `if (length(x) == 1L) return(x[[1L]])` covers the case like `simple_reduce(1, +)` but what's the deal with `if (length(x) == 0L) return(default)` and what exactly is `default`?
:::


```r
simple_reduce <- function(x, f, default) {
  # when would you use reduce on something length 0?
  if (length(x) == 0L) return(default)
  if (length(x) == 1L) return(x[[1L]])

  out <- x[[1]]
  for (i in seq(2, length(x))) {
    out <- f(out, x[[i]])
  }
  out
}
```

Default is the user supplied second number to add by, and we can use `integer(0)` to work with a `length(0)` vector.


```r
simple_reduce(integer(0), `+`, default = 0L)
```

```
## [1] 0
```

You would want to make sure your reduce is covered in the case of length zero so that your program doesn't crash when a user passes in an empty vector.

## 9.7.1 Matrices and arrays {-}

:::question
How would you tidyverse the `rowSums` function?


```r
x <- tribble(
  ~x, ~y,
  1, 1,
  2, 2,
  3, 3
)

apply(x, 1, function(x) sum(x>2))
```

```
## [1] 0 0 2
```
:::



```r
pmap_dbl(x, ~sum(c(...) > 2))
```

```
## [1] 0 0 2
```


:::question
I'm not quite sure what idempotent means but Hadley warns that `a2d` and `a1` aren't the same, but isn't that just because we're using `1` which is row wise, and not `2`? What is the warning he is heeding us against here?
:::


```r
a2d <- matrix(1:20, nrow = 5)
a1 <- apply(a2d, 1, identity)
identical(a2d, a1)
```

```
## [1] FALSE
```


I think he is just trying to drive home the idea that you might expect no change by apply-ing an operator like identity which leaves its input unchanged, however what it instead returns is the transpose.  So perhaps it would have been better to more specifically say that `apply(..., MARGIN = 1)` isn't idempotent.

## 9.7.3.2 Exercise {-}

:::question
What's an example of using `eapply` (iterates over the (named) elements of an environment)?
:::


```r
baseenv() %>% eapply(is.primitive) %>% unlist %>% which %>% names
```

:::question
Can we come up with an example for `rapply` allowing us to apply a function to only a specified class? Does something like this exist within `purrr`?
:::

Answer from [this community post](https://community.rstudio.com/t/recursive-purrr-mutate-if/16638/7):

#### rapply


```r
x <- list(list(a = as.character(1), b = as.double(2)), 
          c = as.character(3), 
          d = as.double(4))

as_integer_rapply <- function(x) {
  rapply(
    x,
    as.integer,
    "character",
    how = "replace"
  )
}

x %>% as_integer_rapply() %>% str()
```

```
## List of 3
##  $  :List of 2
##   ..$ a: int 1
##   ..$ b: num 2
##  $ c: int 3
##  $ d: num 4
```

#### map


```r
as_integer_recursive_map <- function(x) {
  x %>%
    map_if(is.character, as.integer) %>%
    map_if(is.list, as_integer_recursive_map)
}
x %>% as_integer_recursive_map() %>% str()
```

```
## List of 3
##  $  :List of 2
##   ..$ a: int 1
##   ..$ b: num 2
##  $ c: int 3
##  $ d: num 4
```

#### Comparing the two:


```r
microbenchmark::microbenchmark(
  as_integer_rapply(x),
  as_integer_recursive_map(x),
  times = 100
)
```

```
## Unit: microseconds
##                         expr     min        lq       mean   median        uq
##         as_integer_rapply(x)   9.752   11.7745   31.58971   18.450   19.9905
##  as_integer_recursive_map(x) 976.057 1027.4895 1058.79912 1039.714 1070.4145
##       max neval
##  1512.252   100
##  1479.304   100
```



```r
as_integer_safe <- function(y) {
  if (is.character(y) && all(grepl("^\\d+$", y))) {
    as.integer(y)
  } else {
    y
  }
}

x[[1]][[3]] <- "dog"

rapply(x, f = as_integer_safe, how = "replace")
```

```
## [[1]]
## [[1]]$a
## [1] 1
## 
## [[1]]$b
## [1] 2
## 
## [[1]][[3]]
## [1] "dog"
## 
## 
## $c
## [1] 3
## 
## $d
## [1] 4
```


