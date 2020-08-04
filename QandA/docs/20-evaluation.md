# Evaluation



## 20.1 Introduction {-}

:::question
There's an immediate distinction between unquotation (user) and evaluation (developer). What are they?
:::

:::TODO
:::

## 20.2.1 `local` {-}

:::question
This is such a cool function - where is it used in the wild? Maybe we can come up with a TidyModels example or something where you'd want to throw away your intermediates? 
:::

:::TODO
:::

:::question
Can we go over again what is happening in `local2`? Why isn't the environment included as a function argument? Furthermore I'm a little confused by what the function `caller_env()` does.


```r
local2 <- function(expr) {
  env <- env(caller_env())
  eval(enexpr(expr), env)
}

foo <- local2({
  x <- 10
  y <- 200
  x + y
})
```
:::

:::TODO
:::

## 20.2.2 `source` {-}

:::question
Expression vectors get a shout out again (they are an aside in the Expression chapter) and while Hadley advises against introducing another data structure, I wanted to make sure my high level understanding was correct: eval can be vectorized if the input is of type `expression vector` [but not if it's of type `list`]?
:::



```r
exp_vec <- expression(x <- 4, x)
eval(exp_vec)
```


```r
exp_list <- list2(
  rlang::expr(x <- 4),
  rlang::expr(x)
)
eval(exp_list)
```

## 20.2.3 `function` {-}

:::question
I think I understand this issue based on the concrete example but can we summarize the "gotcha" here? Is it that the developer could assume that using `eval` with a quasiquoted function will result in returning the function, but really it evaluates because `srcref` is sneaky?
:::

:::TODO
:::

## Exercises 20.2.4.4 {-}

:::question
Can we go over what exactly is happening here in the solutions manual prior to applying a `map`? I don't really understand what this is returning...


```r
source2 <- function(path, env = caller_env()) {
  file <- paste(readLines(path, warn = FALSE), collapse = "\n")
  exprs <- parse_exprs(file)

  res <- vector(mode = "list", length = length(exprs))      
  for (i in seq_along(exprs)) {
    res[[i]] <- eval(exprs[[i]], env)
  }

  invisible(res)
}

tmp_file <- tempfile()
writeLines(
  "x <- 1
   x
   y <- 2
   y  # some comment",
  tmp_file
)

(source2(tmp_file))
```
:::

:::TODO
:::

## Excercises 20.2.4.5 {-}

:::question
Can we also go over what is happening in this question and come up with our own solution?


```r
local3 <- function(expr, envir = new.env()) {
  call <- substitute(eval(quote(expr), envir))
  eval(call, envir = parent.frame())
}
```
:::

:::TODO
:::

## 20.3.3 Dots {-}

:::question
I have no idea what's happening in this section. Can we go over the point/what this code is showing us? 


```r
f <- function(...) {
  x <- 1
  g(..., f = x)
}
g <- function(...) {
  enquos(...)
}

x <- 0
qs <- f(global = x)
qs
```
:::

:::TODO
:::

## 20.3.4 Under the hood {-}

:::question
> Unfortunately, however, there is no clean way to make ~ a quasiquoting function.

Can we come up with a (broken) example of trying to quasiquote an object of type `formula`? I think seeing this fail will help me to understand its limitations
:::

:::TODO
:::

## Exercises 20.3.6.2 

:::question
What is going on here?? 


```r
enenv <- function(x){
  get_env(enquo(x))
}

# Test
capture_env <- function(x){
  enenv(x)
}

enenv(x)
#> <environment: R_GlobalEnv>
capture_env(x)  # functions execution environment is captured
#> <environment: 0x60a2538>
```

:::

:::TODO
:::

## 20.4.1 Basics {-}

:::question
I am clearly missing something here. What is so special about multiplying across a vector? Is it that data masks allow us to just write `y` instead of `df$y`?
:::

:::TODO
:::

## 20.4.3 `subset` {-}

:::question
What is the `eval_tidy` doing here?


```r
subset2 <- function(data, rows) {
  rows <- enquo(rows)
  rows_val <- eval_tidy(rows, data)
  stopifnot(is.logical(rows_val))

  data[rows_val, , drop = FALSE]
}
```
:::

:::TODO
:::

## 20.4.5 `transform` {-}

:::question
Can we say in words what this one is doing or comment all the lines? 
:::

:::TODO

```r
transform2 <- function(.data, ...) {
  
  # create quosures for all the supplied arguments and values
  dots <- enquos(...)

  # for all argument value pairs
  for (i in seq_along(dots)) {
    # get the names of the arguments
    name <- names(dots)[[i]]
    # get their values
    dot <- dots[[i]]

    # add column with names equal to argument names
    # eval_tidy .... TODO
    .data[[name]] <- eval_tidy(dot, .data)
  }

  .data
}
```
:::

## 20.5.2 Handling ambiguity {-}

:::question
> If you unquote, val will be early evaluated by enquo(); if you use a pronoun, val will be lazily evaluated by eval_tidy().

What is the case where this subtile distinction between `.env$val` vs `!!val` matters? 
:::

:::TODO
:::

## 20.6.1 substitute() {-}

:::question
Why exactly can't we use `subset` with `map`?
:::

:::TODO
:::

:::question
> Calling subset() from another function requires some care: you have to use substitute() to capture a call to subset() complete expression

Why?!
:::

:::TODO
:::

## 20.6.2 `match.call` {-}

:::question
Can we speak more about the differences in these two functions and their pros and cons?
:::


```r
resample_lm2 <- function(formula, data, env = caller_env()) {
  formula <- enexpr(formula)
  resample_data <- resample(data, n = nrow(data))

  lm_env <- env(env, resample_data = resample_data)
  lm_call <- expr(lm(!!formula, data = resample_data))
  expr_print(lm_call)
  eval(lm_call, lm_env)
}
resample_lm2(y ~ x, data = df)
```



```r
resample_lm0 <- function(
  formula, data,
  resample_data = data[sample(nrow(data), replace = TRUE), ,
                       drop = FALSE],
  env = current_env()
) {
  formula <- enexpr(formula)

  lm_call <- expr(lm(!!formula, data = resample_data))
  expr_print(lm_call)
  eval(lm_call, env)
}

df <- data.frame(x = 1:10, y = 5 + 3 * (1:10) + round(rnorm(10), 2))
(resamp_lm1 <- resample_lm0(y ~ x, data = df))
```

:::TODO
:::
