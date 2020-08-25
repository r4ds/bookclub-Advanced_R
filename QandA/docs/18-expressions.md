# Expressions

:::question
I understand how we can subset expression calls but why/when would you do that? What is the context for extracting stuff from a function as an expression ?

Let's build on this contrived example....


```r
x <- read.table("important.csv", row.names = FALSE)
lobstr::ast(read.table("important.csv", row.names = FALSE))
x[[1]]
```

Making this an expression, we can use subsetting to shove in `read.csv` or `read.tsv` where `read.table` is?
:::

You might need to do this in order to insert a line of code inside a function call:


```r
f <- function(x) {
  read.table("important.csv", row.names = FALSE)
}
body(f)[[2]][[1]] <- quote(read.csv)
f
```

```
## function (x) 
## {
##     read.csv("important.csv", row.names = FALSE)
## }
```

:::question
What's an application for this chapter?
:::


```r
library(rlang)
replace_sym <- function(x, sym, replace) {
  if (is_symbol(x, name = sym)) {
    replace
  } else if (is_atomic(x)) {
    x
  } else if (is_symbol(x)) {
    x
  } else if (is_call(x)) {
    as.call(lapply(x, replace_sym, sym, replace))
  } else if (is.pairlist(x)) {
    as.pairlist(lapply(x, replace_sym, sym, replace))
  } else {
    abort(glue::glue("Don't know how to handle {as_label(x)}"))
  }
}
replace_sym(expr(a + b + 1), "b", expr(f(x)))
```

```
## a + f(x) + 1
```

:::question
Why does the expression jump around between "data" and "values" on the env panel in RStudio? It would be nice if it stayed in the "data" pane so you can inspect it
:::

:::question
Why doesn't the last line return true?


```r
is_assignment <- function(expr) {
    (expr[[1]] == "<-" || expr[[1]] == "=")
}
exprs <- rlang::parse_exprs("x <- 1;x = 1")
is_assignment(exprs[[1]])
```

```
## [1] TRUE
```

```r
is_assignment(exprs[[2]])
```

```
## [1] TRUE
```

```r
is_assignment(expression(x <- 1)[[1]])
```

```
## [1] TRUE
```

```r
is_assignment(expression(x = 1)[[1]])
```

```
## [1] FALSE
```
:::

It is interpreting `x = 1` as an argument to expression. To quote equality you can do `parse(text = "x = 1")` and the output will print the same, but it isn't

:::question
Does all this go out the book if someone uses `"abc" -> x?`
:::

`"abc"->x` is internally parsed as `x <- "abc"`


```r
parse(text = "'xyz' -> x")[[1]]
```

```
## x <- "xyz"
```


:::question
Can you clarify the difference between:
- call
- language
- expression
- structure
:::


```r
identical(
  structure(expression(a <- print(123))),
  expression(a <- print(123))
)
```

```
## [1] TRUE
```

```r
is.language(expression(a <- print(123)))
```

```
## [1] TRUE
```

:::TODO
xxx
:::

:::question
When would I use `quote()` over `expression()`?
:::

Hadley advises not to use `expression()`, because it just makes a vector of expressions. He prefers lists of expressions, which you'd generate interactively with `quote()` (or inside functions with `substitute()`). We'll touch on the borders of this at least tonight.

## 18.5 Recursive functions {-}

:::question
What is the `...` allowing for in the recurisve switch function? 


```r
switch_expr <- function(x, ...) {
  switch(expr_type(x),
    ...,
    stop("Don't know how to handle type ", typeof(x), call. = FALSE)
  )
}
```
:::

:::TODO
:::

:::question
Can we go over this function in words? Specifically how `some` works and where/how to recursion is occuring


```r
logical_abbr_rec <- function(x) {
  switch_expr(x,
    # Base cases
    constant = FALSE,
    symbol = as_string(x) %in% c("F", "T"),

    # Recursive cases
    call = ,
    pairlist = purrr::some(x, logical_abbr_rec)
  )
}
```
:::

:::TODO
:::

:::question
I have a vauge understanding of this code but I'd like to comment it out line by line and explain it in english


```r
find_assign_call <- function(x) {
  if (is_call(x, "<-") && is_symbol(x[[2]])) {
    lhs <- as_string(x[[2]])
    children <- as.list(x)[-1]
  } else {
    lhs <- character()
    children <- as.list(x)
  }

  c(lhs, flat_map_chr(children, find_assign_rec))
}

find_assign_rec <- function(x) {
  switch_expr(x,
    # Base cases
    constant = ,
    symbol = character(),

    # Recursive cases
    pairlist = flat_map_chr(x, find_assign_rec),
    call = find_assign_call(x)
  )
}

find_assign(a <- b <- c <- 1)
#> [1] "a" "b" "c"
find_assign(system.time(x <- print(y <- 5)))
```
:::

:::TODO
:::

