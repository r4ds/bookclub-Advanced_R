# Translating R Code

## 21.2.3 Basic tag functions {-}

:::question
Why do we use `list2` here and not just `list` when they have the same output?


```r
list(a = 1, 2, b = 3, 4)
```

```
## $a
## [1] 1
## 
## [[2]]
## [1] 2
## 
## $b
## [1] 3
## 
## [[4]]
## [1] 4
```

```r
rlang::list2(a = 1, 2, b = 3, 4)
```

```
## $a
## [1] 1
## 
## [[2]]
## [1] 2
## 
## $b
## [1] 3
## 
## [[4]]
## [1] 4
```
:::


`list2` supports "tidy dots" and unquote splicing. Most of the time it won't make a difference, but there are instances where using `list2` does matter:


```r
library(rlang)
dots_partition <- function(...) {
  # create a list of arguments
  # why list2 and not regular list?
  # are the same...
  dots <- list2(...)
  # if there are no names in the whole list
  if (is.null(names(dots))) {
    # rep FALSE for the length of dots
    is_named <- rep(FALSE, length(dots))
  } else {
    # create boolean vector
    # if arg in list is named or not
    is_named <- names(dots) != ""
  }
  list(
    # subeset where is_named is true
    named = dots[is_named],
    # subset where is_named is false
    unnamed = dots[!is_named]
  )
}
```



```r
dots_partition(list(letters = letters))
```

```
## $named
## list()
## 
## $unnamed
## $unnamed[[1]]
## $unnamed[[1]]$letters
##  [1] "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s"
## [20] "t" "u" "v" "w" "x" "y" "z"
```

When we use `list` here the letters come back as unnamed elements, but if we use `!!!` with `list2` we return the letters as named arguments


```r
dots_partition(!!!list(letters = letters))
```

```
## $named
## $named$letters
##  [1] "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s"
## [20] "t" "u" "v" "w" "x" "y" "z"
## 
## 
## $unnamed
## named list()
```

## 21.2.4 Tag functions {-}

:::question
Can we explain this function?
:::
 


```r
tag <- function(tag) {
  new_function(
    # what is this line doing?
    # even Hadley calls it weird!
    exprs(... = ),
    expr({
      dots <- dots_partition(...)
      attribs <- html_attributes(dots$named)
      children <- map_chr(dots$unnamed, escape)
      html(paste0(
        !!paste0("<", tag), attribs, ">",
        paste(children, collapse = ""),
        !!paste0("</", tag, ">")
      ))
    }),
    caller_env()
  )
}

tag("b")
```

```
## function (...) 
## {
##     dots <- dots_partition(...)
##     attribs <- html_attributes(dots$named)
##     children <- map_chr(dots$unnamed, escape)
##     html(paste0("<b", attribs, ">", paste(children, collapse = ""), 
##         "</b>"))
## }
```

`expr(... = )` creates an expression with the argument name `...` with an empty values.

## 21.3.3 `to_math()`

:::question
Hadley uses `eval_bare` which is described as:

> eval_bare() is a lower-level version of function base::eval(). Technically, it is a simple wrapper around the C function Rf_eval(). You generally don't need to use eval_bare() instead of eval(). Its main advantage is that it handles stack-sensitive (calls such as return(), on.exit() or parent.frame()) more consistently when you pass an enviroment of a frame on the call stack.

Why use this instead of `tidy_eval`?
:::


```r
# eval the latex class expression
# in the latex environment
to_math <- function(x) {
  expr <- enexpr(x)
  out <- eval_bare(expr, latex_env(expr))
  latex(out)
}

# create the latex class expression
latex <- function(x) structure(x, class = "advr_latex")

# print the latex expression
print.advr_latex <- function(x) {
  cat("<LATEX> ", x, "\n", sep = "")
}
```

:::TODO
:::

## 21.3.5 

:::question
The following code below uses `switch_expr`... is this not an rlang function? What about `flat_map_chr`? (And what does this function do?)


```r
all_names_rec <- function(x) {
  rlang:::switch_expr(x,
    constant = character(),
    symbol =   as.character(x),
    # we get all the expr arguments
    # and remove the first element because that is the call
    # as per subsetting chapter 18.3.3.1
    call =  flat_map_chr(as.list(x[-1]), all_names)
  )
}

all_names <- function(x) {
  unique(all_names_rec(x))
}

all_names(expr(x + y + f(a, b, c, 10)))
```
:::

:::TODO
`switch_expr` is an rlang internal, `rlang:::switch_expr` that ....

```
function (.x, ...) 
{
    switch(expr_type_of(.x), ...)
}
<bytecode: 0x7fdba4adc070>
<environment: namespace:rlang>
```

In Chapter 18 Hadley defines the `flat_map_chr` function that....


```r
flat_map_chr <- function(.x, .f, ...) {
  purrr::flatten_chr(purrr::map(.x, .f, ...))
}

flat_map_chr(letters[1:3], ~ rep(., sample(3, 1)))
```

```
## [1] "a" "a" "a" "b" "b" "b" "c"
```
:::

## 21.3.6 Unknown functions 

:::question
My understanding of the LaTeX example starts to break down here. Can we go over the code chunks and comment them below?
:::

:::TODO

```
all_calls_rec <- function(x) {
  switch_expr(x,
    constant = ,
    symbol =   character(),
    call = {
      fname <- as.character(x[[1]])
      children <- flat_map_chr(as.list(x[-1]), all_calls)
      c(fname, children)
    }
  )
}
all_calls <- function(x) {
  unique(all_calls_rec(x))
}

all_calls(expr(f(g + b, c, d(a))))
#> [1] "f" "+" "d"

unknown_op <- function(op) {
  new_function(
    exprs(... = ),
    expr({
      contents <- paste(..., collapse = ", ")
      paste0(!!paste0("\\mathrm{", op, "}("), contents, ")")
    })
  )
}
unknown_op("foo")
#> function (...) 
#> {
#>     contents <- paste(..., collapse = ", ")
#>     paste0("\\mathrm{foo}(", contents, ")")
#> }
#> <environment: 0x4d608b8>
```
:::
