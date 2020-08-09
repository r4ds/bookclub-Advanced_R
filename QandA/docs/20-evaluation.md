# Evaluation



## 20.1 Introduction {-}

:::question
There's an immediate distinction between unquotation (user) and evaluation (developer). What are they?
:::

Unquoting seems to be "evaluate this one part and then return the expression"
evaluate means "give me the result of this whole expression"

## 20.2.1 `local` {-}

:::question
This is such a cool function - where is it used in the wild?
:::

When wanting to have variables stored in the environment of a function, or if you want to run an expression that produces bindings, but you don't want those bindings to persist.


```r
counter <- local({ 
  i <- 0; function() { 
    i <<- i + 1; print(i)
  }
})

counter()
```

```
## [1] 1
```

```r
counter()
```

```
## [1] 2
```

```r
counter()
```

```
## [1] 3
```

We can also wrap `for` loops in a `local` call to avoid the object being iterated over getting assigned to the global environment


```r
f1 <- function(x) {
  for (x in 1:10) {
    # do something
  }
  x
}

f2 <- function(x) {
  local({
    for (x in 1:10) {
      # do something
    }
  })
  x
}

f1("hello")
#> [1] 10
f2("hello")
#> [1] "hello"
```

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
I think I understand this issue based on the concrete example but can we summarize the "gotcha" here?
:::

It's basically that the printing of the function is a lie (because base R doesn't get it). And that's dangerous and confusing, so use rlang to make it not a lie.


```r
x <- 10
y <- 20
f <- eval(expr(function(x, y) !!x + !!y))
f
```

```
## function(x, y) !!x + !!y
```

```r
f()
```

```
## [1] 30
```

```r
attributes(f)
```

```
## $srcref
## function(x, y) !!x + !!y
```


```r
attr(f, "srcref") <- NULL
f
```

```
## function (x, y) 
## 10 + 20
```

The REAL function is `10 + 20`, but the initial `srcref` keeps the `!!x` and `!!y`, which is meaningless. This might help explain why there's a problem:


```r
x <- 10
y <- 20
f <- eval(expr(function(x, y) !!x + !!y))
f
```

```
## function(x, y) !!x + !!y
```

```r
f()
```

```
## [1] 30
```


```r
x <- 2000
y <- 3000
f()
```

```
## [1] 30
```

```r
#> [1] 30
attributes(f)
```

```
## $srcref
## function(x, y) !!x + !!y
```

```r
#> $srcref
#> function(x, y) !!x + !!y
attr(f, "srcref") <- NULL
f
```

```
## function (x, y) 
## 10 + 20
## <bytecode: 0x7f7f25ea2b50>
```

```r
#> function (x, y) 
#> 10 + 20
#> <bytecode: 0x000000001421eb90>
```

## 20.2.4.5 Exercises {-}

:::question
Can we also go over what is happening in `local3`?
:::


```r
local3 <- function(expr, envir = new.env()) {
  call <- substitute(eval(quote(expr), envir))
  print(call)
  eval(call, envir = parent.frame())
}

local3({
  x <- 10
  x * 2
})

exists("x")
```

It creates a new environment with the calling environment as its parent and then evaluates the expression in that environment.

You are evaluating the call in the execution environment of `local3`. Its confusing because it's written as `eval(call, envir = parent.frame())`  but it is important to remember that `parent.frame` is evaluated in the execution environment of eval.

if instead you had:

```
pf <- parent.frame()
eval(call, envir = pf)
```

you would get something else. Because in this case, `parent.frame()` is evaluated in the execution environment of `local3` and thus returns `.GlobalEnv` (presumably you run it from the global env).

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
As a preliminary, I note that the following code also illustrates the point:


```r
f <- function(...) {
  x <- 1
  g(..., f = x)
}
g <- function(...) {
  enquos(...)
}
x <- 0
qs <- f(x)
qs
```

I think what he's trying to say is that if you didn't have quosures you would have to create a list of environments to match the list of expressions if you wanted your expressions to contain the same names but not necessarily have those names have the same meaning.

But here we have a magical situation where each quosure has the same expression but each environment is different and thus each `x` will be evaluated differently when the time comes.

I think the real barrier to truly getting it is figuring out a plausible example of wanting the same name to have different meanings in your list of expressions.. and I'm at a loss for that at the moment.
:::

## 20.3.4 Under the hood {-}

:::question
> Unfortunately, however, there is no clean way to make ~ a quasiquoting function.

Can we come up with a (broken) example of trying to quasiquote an object of type `formula`? I think seeing this fail will help me to understand its limitations
:::

:::TODO
To do this you would need to recreate the way rlang worked when quosures WERE formulas, probably by pulling the commit prior to the rewrite off of github. It looks like the old method would encode the expr as a formula and then overload the tilde operator so that it does tidy eval instead of..whatever it does normally
:::

## 20.3.6.2 Exercises {-}

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

The `enquo` is capturing the environment of the `x` being passed into enenv, so it returns a different environment (the one inside `capture_env`) than running `enenv(x)` on its own

## 20.4.1 Basics {-}

:::question
I am clearly missing something here. What is so special about multiplying across a vector? Is it that data masks allow us to just write `y` instead of `df$y`?
:::

I think the simplicity of the multiplication may be what he's going for: the reader can focus on the language feature provided without the distraction of a complex computation.

## 20.4.3 `subset` {-}

:::question
What is the `eval_tidy` doing here?
:::



```r
subset2 <- function(data, rows) {
  rows <- enquo(rows)
  # creates a quosure out of the enquoted rows
  # and uses the data as its environment
  rows_val <- eval_tidy(rows, data)
  stopifnot(is.logical(rows_val))

  # then subsets the data
  data[rows_val, , drop = FALSE]
}

df <- subset2(palmerpenguins::penguins, species == "Adelie")
table(df$species)
```

```
## 
##    Adelie Chinstrap    Gentoo 
##       152         0         0
```

## 20.4.5 `transform` {-}

:::question
Can we say in words what this one is doing or comment all the lines? 
:::


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
    # eval_tidy and values (single column) equal to the evaluated quosure (dot)"
    .data[[name]] <- eval_tidy(dot, .data)
  }

  .data
}
```

## 20.5.2 Handling ambiguity {-}

:::question
> There are subtle differences in when val is evaluated. If you unquote, val will be early evaluated by enquo(); if you use a pronoun, val will be lazily evaluated by eval_tidy(). These differences are usually unimportant, so pick the form that looks most natural.

Is there a case where this subtle distinction between `.env$val` vs `!!val` matters? 


```r
threshold_prefix <- function(df, val) {
  subset2(df, .data$x >= .env$val)
}

threshold_bangbang <- function(df, val) {
  subset2(df, .data$x >= !!val)
}

df <- data.frame(x = 1:3, val = 9:11)
threshold_prefix(df, 2) == threshold_bangbang(df, 2)
```

```
##      x  val
## 2 TRUE TRUE
## 3 TRUE TRUE
```
:::

In the `!!` case, `val` is evaluated early, (inside of `threshold_x`) whereas the `.env` case evaluated later (in the `eval_tidy`)

Tyler Grant Smith:m:  21 minutes ago
this could cause problems if, for example, the val in threshold_x was altered after subset2 was called, but before the eval_tidy


```r
subset2 <- function(data, rows) {
  rows <- enquo(rows)
  # change val from 2 to 3, breaking things
  env_bind(caller_env(), val = 3)
  rows_val <- eval_tidy(rows, data)
  stopifnot(is.logical(rows_val))
  data[rows_val, , drop = FALSE]
}
```

## 20.6.1 substitute() {-}

:::question
Why exactly can't we use `subset` with `map`?

This works, not sure why the book says it wouldn't....

```r
subset_base <- function(data, rows) {
  rows <- substitute(rows)
  rows_val <- eval(rows, data, caller_env())
  stopifnot(is.logical(rows_val))
  data[rows_val, , drop = FALSE]
}

local({
  zzz <- 2
  dfs <- list(data.frame(x = 1:3), data.frame(x = 4:6))
  map(dfs, ~subset_base(.x, x == zzz))
})
```

```
## [[1]]
##   x
## 2 2
## 
## [[2]]
## [1] x
## <0 rows> (or 0-length row.names)
```
:::

:::TODO
:::

:::question
> Calling subset() from another function requires some care: you have to use substitute() to capture a call to subset() complete expression

Why?!
:::

No reason to expect this to work:


```r
test <- function(df, expr) {
  subset(df, expr)
}

test(mtcars, cyl > 4)
```

```
#> Error in eval(e, x, parent.frame()): object 'cyl' not found
```

substitute only looks at the expression from which it was called. this doesn't work because subset sees `substitute(expr)`, not `cyl > 4`


```r
test <- function(df, expr) {
  subset(df, substitute(expr))
}
test(mtcars, cyl > 4)
```

```
#> Error in subset.data.frame(df, substitute(expr)): 'subset' must be logical
```

so instead, we are going to build the call to `subset`, substituting in what was passed as arguments, and then eval the call.


```r
test <- function(df, expr) {
  subset_call <- substitute(subset(df, expr))
  print(subset_call)
  eval(subset_call)
}
test(mtcars, cyl > 4)
```

```
#> subset(mtcars, cyl > 4)
```


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

I think these two functions should work identically assuming formula and data are the only two inputs that are set by the user. (The results will differ unless a seed is set.)

I suppose the `resample_lm0()` here provides more flexibility to the user (compared to `resample_lm2()`, i.e. the user can specify `resample_data` (since it's an argument) instead of being "forced" to use the custom function `resample()`, which is embedded in the body of `resample_lm2()`. 

Downside to `resample_lm0` is that there might be too much flexibility. Yes, `resample_data` is customizable, but so is `env`. What if the user changes `env = current_env()` to `env = caller_env()`? Then the function breaks.

:::question
Is the closest equivalent to `deparse(substitute(x))` with rlang `expr_text(enexpr(x))` (assuming this is in a function, hence the `en` in `enexpr`)?
:::


```r
penguins <- palmerpenguins::penguins
add_bleh <- function(df, nm = deparse(substitute(df))) {
  col_out <- sym(sprintf('new_%s_col', nm))
  df %>% 
    mutate(!!col_out := 'bleh')
}
add_bleh(penguins) %>% slice(1) %>% glimpse()
```

```
## Rows: 1
## Columns: 9
## $ species           <fct> Adelie
## $ island            <fct> Torgersen
## $ bill_length_mm    <dbl> 39.1
## $ bill_depth_mm     <dbl> 18.7
## $ flipper_length_mm <int> 181
## $ body_mass_g       <int> 3750
## $ sex               <fct> male
## $ year              <int> 2007
## $ new_penguins_col  <chr> "bleh"
```

:::TODO
:::

:::question
In [this thread](https://community.rstudio.com/t/quasiquotation-inside-a-formula/14929/11) Lionel says "`enexpr` should almost never be used. So when should it?
:::

Seems like when wrapping a base NSE function like `lm` or trying to `deparse(substitute(x))` using `rlang`

