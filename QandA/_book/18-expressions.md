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


