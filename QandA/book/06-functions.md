# Functions



## 6.2.2 Primitives {-}

:::question
So if you are familiar with C can you just write a function in C *in* R? What does that process look like? I think this is a bigger question of digging into the relationship between C and R.
:::

I think we cover this in Chapter 25!

## 6.2.5.1 Exercises {-}

:::question
[This question is flagged as "started" let's try to complete it!](https://github.com/Tazinho/Advanced-R-Solutions/blob/5043d9b06c7469a010c568ecb85e12bedca75207/2-06-Functions.Rmd#L9)
:::

1. __[Q]{.Q}__: Given a name, like `"mean"`, `match.fun()` lets you find a function. Given a function, can you find its name? Why doesn't that make sense in R?

    __[A]{.started}__: A name can only point to a single object, but an object can be pointed to by 0, 1, or many names. What are names of the functions in the following block?

    
    ```r
      function(x) sd(x) / mean(x)
    ```
    
    ```
    ## function(x) sd(x) / mean(x)
    ```
    
    ```r
      f1 <- function(x) (x - min(x)) / (max(x) - min(x))
      f2 <- f1
      f3 <- f1
    ```

:::TODO
XXX
:::

## 6.4 Lexical scoping {-}

:::question
"The scoping rules use a parse-time, rather than a run-time structure"? What is "parse-time" and "run-time"? How do they differ?
:::

:::TODO
The function is run at parse-time, meaning it is only run when it is called.
:::

## 6.4.3 A fresh start {-}

:::question
How would we change this code so that the second call of `g11()` is 2?


```r
g11 <- function() {
  if (!exists("a")) {
    a <- 1
  } else {
    a <- a + 1
  }
  a
}

g11()
```

```
## [1] 1
```

```r
g11()
```

```
## [1] 1
```
:::

:::TODO
XXX
:::

##  6.5 Lazy evaluation {-}

:::question
"This allows you to do things like include potentially expensive computations in function arguments that will only be evaluated if needed"

Does anyone have an example of this?
:::

:::TODO
XXX
:::

## 6.5.1 Promises {-}

:::question
Can we discuss the order that this happening in? Is it that `Calculating...` is printed, then `x*2` then `x*2` again? I am still reading this as: `h03(double(20), double(20))` which is an incorrect mental model because the message is only printed once...


```r
double <- function(x) { 
  message("Calculating...")
  x * 2
}

h03 <- function(x) {
  c(x, x)
}

h03(double(20))
```

```
## Calculating...
```

```
## [1] 40 40
```
:::

:::TODO
XXX
:::

## 6.5.2 Default arguments {-}

:::question
I don't quite understand why `x = ls()` is different from `ls()` here; aren't we still assigning `x = ls()` but without specifying x?

```r
h05 <- function(x = ls()) {
  a <- 1
  x
}

# this makes sense to me
h05()
```

```
## [1] "a" "x"
```

```r
# how is this different from above?
h05(ls())
```

```
## [1] "double" "f1"     "f2"     "f3"     "g11"    "h03"    "h05"
```
:::

:::TODO
XXX
:::

## 6.5.3 Missing arguments {-}

:::question
Comparing the default sample function:

```r
sample <- function (x, size, replace = FALSE, prob = NULL) 
{
    if (length(x) == 1L && is.numeric(x) && is.finite(x) && x >= 
        1) {
        if (missing(size))
          # if you don't supply the sample size
          # you will just get random samples
          # the length of the supplied vector
            size <- x
        sample.int(x, size, replace, prob)
    }
    else {
        if (missing(size)) 
            size <- length(x)
        x[sample.int(length(x), size, replace, prob)]
    }
}

sample(1:10)
```

```
##  [1]  2  8  1 10  9  3  5  4  7  6
```

To using Hadley's recommended `NULL` version:


```r
my_sample_null <- function(x, size = NULL, replace = FALSE, prob = NULL) {
  size <- size %||% length(x)
  x[sample.int(length(x), size, replace = replace, prob = prob)]
}

my_sample_null(1:10)
```

```
##  [1]  8  9  3  7  1  6 10  4  5  2
```

The second function is obviously more concise, but why is Hadley recommending we we steer clear of `missing()`? Is this just for code read-ability or is there something inherent in the behavior of `missing` we need to consider that we don't when using `NULL`?
:::

:::TODO
XXX
:::

## 6.5.4.3 Exercise {-}

:::question

I understand this problem is showing us an example of name masking (the function doesn't need to use the `y = 0` argument because it gets `y` from within the definition of x, but I'm fuzzy on what exactly the `;` does. What does the syntax `{y <- 1; 2}` mean? Could it be read as "Set `y <- 1` and `x <- 2`?


```r
y <- 10
f1 <- function(x = {y <- 1; 2}, y = 0) {
  c(x, y)
}
f1()
```

```
## [1] 2 1
```
:::


## 6.5.4.4 Exercise {-}

:::question
I know this isn't exactly needed to answer the question, but how do we access a function that has methods? For instance - here I want to dig into the `hist` function using `hist`


```r
hist
```

```
## function (x, ...) 
## UseMethod("hist")
## <bytecode: 0x7faa49297440>
## <environment: namespace:graphics>
```
does not give me the actual contents of the actual function....
:::

:::TODO
XXX
:::

## 6.6 dot dot dot {-}

:::question
"(See also `rlang::list2()` to support splicing and to silently ignore trailing commas..." Can we come up with a simple use case for `list2` here?
:::

:::TODO
XXX
:::

:::question
"`lapply()` uses `...` to pass `na.rm` on to `mean()`" Um, how?


```r
x <- list(c(1, 3, NA), c(4, NA, 6))
str(lapply(x, mean, na.rm = TRUE))
```

```
## List of 2
##  $ : num 2
##  $ : num 5
```
:::

:::TODO
XXX
:::

## 6.6.1.2 Exercise {-}

:::question
I tried running `browser(plot(1:10, col = "red"))` to peek under the hood but only got `Called from: top level` in the console. What am I missing?
:::

:::TODO
XXX
:::

## 6.7.4 Exit handlers {-}

:::question
"Always set `add = TRUE` when using `on.exit()` If you don’t, each call to `on.exit()` will overwrite the previous exit handler." Can we come up with an example for not using `add = TRUE` and how it results in unwanted behavior?
:::

`add = TRUE` is important when you have more than one `on.exit` function!


```r
j08 <- function() {
  on.exit(message("a"))
  on.exit(message("b"), add=TRUE)
}

j08()
```

```
## a
```

```
## b
```


:::question
Can we go over this code? How does it not change your working directory after you run the function


```r
cleanup <- function(dir, code) {
  old_dir <- setwd(dir)
  on.exit(setwd(old_dir), add = TRUE)
  
  old_opt <- options(stringsAsFactors = FALSE)
  # what's happening here?
  on.exit(options(old_opt), add = TRUE)
}

# what is this output
cleanup("~")
# how is it different from this?
getwd()
```

```
## [1] "/Users/mayagans/Documents/bookclub-Advanced_R/QandA"
```
:::

:::TODO
XXX
:::

## 6.7.5.4 Exercise {-}

:::question
[This question is flagged as "started" let's try to complete it!](https://github.com/Tazinho/Advanced-R-Solutions/blob/5043d9b06c7469a010c568ecb85e12bedca75207/2-06-Functions.Rmd#L350) Hadley comments in the repo: "I think I'm more interested in supplying a path vs. a logical value here".
:::

__[Q]{.Q}__: How does the `chdir` parameter of `source()` compare to `in_dir()`? Why might you prefer one approach to the other?
   The `in_dir()` approach was given in the book as
       
    
    ```r
    in_dir <- function(dir, code) {
      old <- setwd(dir)
      on.exit(setwd(old))
      
      force(code)
    }
    ```
    
   __[A]{.started}__: `in_dir()` takes a path to a working directory as an argument. First the working directory is changed accordingly. `on.exit()` ensures that the modification to the working directory are reset to the initial value when the function exits.
    
   In `source()` the `chdir` argument specifies if the working directory should be changed during the evaluation of the `file` argument (which in this case has to be a path name). 

:::TODO
XXX
:::

## 6.7.5.5 Exercise {-}

:::question
Can we go over the source code of `capture.output` and `capture.output2`? 


```r
body(capture.output)
```

```
## {
##     args <- substitute(list(...))[-1L]
##     type <- match.arg(type)
##     rval <- NULL
##     closeit <- TRUE
##     if (is.null(file)) 
##         file <- textConnection("rval", "w", local = TRUE)
##     else if (is.character(file)) 
##         file <- file(file, if (append) 
##             "a"
##         else "w")
##     else if (inherits(file, "connection")) {
##         if (!isOpen(file)) 
##             open(file, if (append) 
##                 "a"
##             else "w")
##         else closeit <- FALSE
##     }
##     else stop("'file' must be NULL, a character string or a connection")
##     sink(file, type = type, split = split)
##     on.exit({
##         sink(type = type, split = split)
##         if (closeit) close(file)
##     })
##     pf <- parent.frame()
##     evalVis <- function(expr) withVisible(eval(expr, pf))
##     for (i in seq_along(args)) {
##         expr <- args[[i]]
##         tmp <- switch(mode(expr), expression = lapply(expr, evalVis), 
##             call = , name = list(evalVis(expr)), stop("bad argument"))
##         for (item in tmp) if (item$visible) 
##             print(item$value)
##     }
##     on.exit()
##     sink(type = type, split = split)
##     if (closeit) 
##         close(file)
##     if (is.null(rval)) 
##         invisible(NULL)
##     else rval
## }
```


```r
capture.output2 <- function(code) {
  temp <- tempfile()
  on.exit(file.remove(temp), add = TRUE)

  sink(temp)
  on.exit(sink(), add = TRUE)

  force(code)
  readLines(temp)
}
```


```r
identical(
  capture.output(cat("a", "b", "c", sep = "\n")),
  capture.output2(cat("a", "b", "c", sep = "\n"))
)
```

```
## [1] TRUE
```

The second function is more concise but what is it missing from the first? I'd like to go over the first one line by line.
:::

:::TODO
XXX
:::

## 6.8.4 Replacement functions {-}

:::question
Can we put into words the translation for 


```r
x <- c(a = 1, b = 2, c = 3)
names(x)
```

```
## [1] "a" "b" "c"
```

```r
names(x)[2] <- "two"
names(x)
```

```
## [1] "a"   "two" "c"
```

Being equal to


```r
`*tmp*` <- x
x <- `names<-`(`*tmp*`, `[<-`(names(`*tmp*`), 2, "two"))
rm(`*tmp*`)
```
:::

:::TODO
XXX
:::

## 6.8.6.3 Exercise {-}

:::question
[This question is flagged as "started" let's try to complete it!](https://github.com/Tazinho/Advanced-R-Solutions/blob/5043d9b06c7469a010c568ecb85e12bedca75207/2-06-Functions.Rmd#L433)
:::


__[Q]{.Q}__: Explain why the following code fails:
    
    ```r
    modify(get("x"), 1) <- 10
    #> Error: target of assignment expands to non-language object
    ```
    
   __[A]{.started}__: First, let's define `x` and recall the definition of `modify()` from the textbook:
    
    
    ```r
    x <- 1:3
    
    `modify<-` <- function(x, position, value) {
      x[position] <- value
      x
    }
    ```


:::TODO
XXX
:::
