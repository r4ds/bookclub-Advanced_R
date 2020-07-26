# Function operators



## 11.1 Introduction {-}

:::question
> A function operator is a function that takes one (or more) functions as input and returns a function as output

...How exactly does this definition differ from a function factory?
:::

\captionsetup[table]{labelformat=empty,skip=1pt}
\begin{longtable}{llll}
\toprule
Term & Required Input & Optional Output & Output \\ 
\midrule
Functionals & Function & Vector & Vector \\ 
Function Factory & NA & Vector,Function & Function \\ 
Function Operator & Function & Function & Function \\ 
\bottomrule
\end{longtable}

> Function operators are closely related to function factories; indeed they’re just a function factory that takes a function as input

:::question
Can anyone confirm that, by definition, function operators can only take functions as inputs (and not any kind of vector)? Book quote: "A function operator is a function that takes one (or more) functions as input and returns a function as output." If this is true, then something like the following would only be a function factory, not both a function factory and a function operator:


```r
sleepy <- function(f, n){
  force(f)
  function(...){
    cat(
      glue::glue('Sleeping for {n} second{ifelse(n != 1, "s", "")}.'), 
      sep = '\n'
    )
    Sys.sleep(n)
    f(...)
  }
}

sleepy_print <- sleepy(print, 1.5)
sleepy_print('hello world')
```

```
## Sleeping for 1.5 seconds.
## [1] "hello world"
```
:::


Function factories are “any function that returns a function” and Hadley uses “simple” examples where you pass in a numeric or character to get back a customized function (pass a number to a power function to get a function dedicated to cubes)

Function operators are factories where you pass in a function and modify its behaviour a little, without actually building up the logic for a function from scratch. The operator does not supply the actual meat of the logic.
examples: `safely`, `silently`, `rate-limity` etc


## 11.2.1 purrr::safely {-}

:::question
It seems like safely is a condition wrapper - are all conditions a kind of function operator?
:::

`safely`/`possibly`/`quietly` are function operators that are condition-wrappers, but `tryCatch`/`withCallingHandlers` are not function operators (they catch the outputs and do X thing but don't actually return a function)

:::question
How would we apply `safely` to find which dataframe in a list of dataframes is causing an error?
:::


```r
library(tidyverse)

random_starwars <- function() { 
  starwars %>%
    sample_n(50) %>%
    select(name, height,mass)
}
	
broken_starwars <- function(){ 
  starwars %>%
  sample_n(50) %>%
  select(name, height,mass) %>% 
  mutate(height = as.character(height))
}
  
list_data <- list(a = random_starwars(),
                  b = random_starwars(),
                  c = broken_starwars(),
                  d = random_starwars())

map_dfr_safely <- function(.x, .f, ... ) {
  results <- map(.x, safely(.f), ...)
  list(result = bind_rows(!!!map(results, "result")), error = map(results, "error"))
}    

map_dfr_safely(list_data, semi_join, filter_starwars, by = c("name", "height"))
```

```
## Warning in is.data.frame(y): restarting interrupted promise evaluation

## Warning in is.data.frame(y): restarting interrupted promise evaluation

## Warning in is.data.frame(y): restarting interrupted promise evaluation
```

```
## $result
## data frame with 0 columns and 0 rows
## 
## $error
## $error$a
## <simpleError in is.data.frame(y): object 'filter_starwars' not found>
## 
## $error$b
## <simpleError in is.data.frame(y): object 'filter_starwars' not found>
## 
## $error$c
## <simpleError in is.data.frame(y): object 'filter_starwars' not found>
## 
## $error$d
## <simpleError in is.data.frame(y): object 'filter_starwars' not found>
```

## 11.2.2 memoise {-}

How do you check how much memory is allocated to memoise's caching? 


```r
random_starwars <- function(...){ 
  starwars %>%
    sample_n(3) %>%
    select(name)}
memoised_starwars <- memoise(random_starwars)
a <- random_starwars()
b <- memoised_starwars(1)
c <- memoised_starwars(2)
d <- memoised_starwars(3)

lobstr::obj_size(get("_cache",environment(memoised_starwars)))
```

```
## 16,264 B
```

:::question
Could we create a memoise wrapper that clears the cache when that's a certain number?
:::


```r
random_starwars <- function(...){ 
  dplyr::starwars %>%
    dplyr::sample_n(3) %>%
    dplyr::select(name)
  }
cache_memory_size <- function(f) {
  cache <- get("_cache", environment(f))
  lobstr::obj_size(cache)
}
capped_memoise <- function(..., .cache_size) {
  force(.cache_size)
  .self_ref <- memoise::memoise(...)
  f <- function(...) {
    env <- parent.env(environment())
    cache_size <- cache_memory_size(env[["_self_ref"]])
    if (cache_size > env[["_cache_size"]]) {
      message(paste0("Clearing cache [@",cache_size,"]\n"))
      memoise::forget(env[["_self_ref"]])
    }
    env[["_self_ref"]](...)
  }
  assign("_cache_size", .cache_size, environment(.self_ref))
  assign("_self_ref", .self_ref, environment(.self_ref))
  environment(f) <- environment(.self_ref)
  f
}
capped_memoised_starwars <- capped_memoise(random_starwars, .cache_size = 30000)
for (i in 1:100) {
  capped_memoised_starwars(i)
  print(cache_memory_size(capped_memoised_starwars))
}
```

```
## 14,456 B
## 15,352 B
## 16,248 B
## 17,144 B
## 18,064 B
## 18,960 B
## 19,848 B
## 20,744 B
## 21,568 B
## 22,408 B
## 23,248 B
## 24,144 B
## 24,984 B
## 25,760 B
## 26,616 B
## 27,488 B
## 28,320 B
## 29,096 B
## 29,936 B
## 30,776 B
```

```
## Clearing cache [@30776]
```

```
## 14,448 B
## 15,336 B
## 16,256 B
## 17,096 B
## 18,008 B
## 18,840 B
## 19,744 B
## 20,640 B
## 21,472 B
## 22,248 B
## 23,104 B
## 24,024 B
## 24,872 B
## 25,640 B
## 26,408 B
## 27,232 B
## 28,072 B
## 28,912 B
## 29,688 B
## 30,520 B
```

```
## Clearing cache [@30520]
```

```
## 14,456 B
## 15,352 B
## 16,272 B
## 17,176 B
## 18,088 B
## 18,880 B
## 19,768 B
## 20,664 B
## 21,560 B
## 22,392 B
## 23,168 B
## 24,040 B
## 24,896 B
## 25,752 B
## 26,528 B
## 27,304 B
## 28,136 B
## 28,968 B
## 29,744 B
## 30,584 B
```

```
## Clearing cache [@30584]
```

```
## 14,472 B
## 15,368 B
## 16,272 B
## 17,192 B
## 18,024 B
## 18,880 B
## 19,792 B
## 20,632 B
## 21,464 B
## 22,368 B
## 23,272 B
## 24,128 B
## 25,032 B
## 25,872 B
## 26,584 B
## 27,360 B
## 28,256 B
## 29,032 B
## 29,928 B
## 30,696 B
```

```
## Clearing cache [@30696]
```

```
## 14,456 B
## 15,352 B
## 16,248 B
## 17,152 B
## 18,048 B
## 18,952 B
## 19,888 B
## 20,776 B
## 21,552 B
## 22,448 B
## 23,352 B
## 24,184 B
## 24,960 B
## 25,856 B
## 26,632 B
## 27,456 B
## 28,232 B
## 28,944 B
## 29,840 B
## 30,672 B
```

:::question
Can we come up with simple example for these function operators?
:::


```r
x <- list(
  c(0.512, 0.165, 0.717),
  c(0.064, 0.781, 0.427),
  c(0.890, 0.785, 0.495),
  "oops"
)

f <- function(...) {sum(...)}
```

#### possibly {-}


```r
map_dbl(x, possibly(f, NA))
```

```
## [1] 1.394 1.272 2.170    NA
```

#### quietly {-}

Quetly doesn't work on errors, only warnings:


```r
map(x, quietly(function(x) tryCatch(f(x), error = function(e) warning(e)))
```

#### auto_browser {-}


```r
map_dbl(x, auto_browse(f))
```

## 11.2.3.1 Exercises {-}

:::question
> Vectorize() provides a convenient and concise notation to iterate over multiple arguments, but has some major drawbacks that mean you generally shouldn’t use it.

What are these drawbacks the solution manual is referring to?
:::


#### [Dean's Way](https://deanattali.com/blog/mutate-non-vectorized/)


```r
library(tidyverse)
patient_name <- function(path) {
  path_list <- str_split(path, "/") %>% unlist()
  paste(path_list[length(path_list) - 1], path_list[length(path_list)], sep = "_")
}

# Vectorize it with Vectorize
patient_name_v <- Vectorize(patient_name)
patient_name_v(path = c("some/path/abc/001.txt", "another/directory/xyz/002.txt"))
```

```
##         some/path/abc/001.txt another/directory/xyz/002.txt 
##                 "abc_001.txt"                 "xyz_002.txt"
```

#### [Jim's Way](https://www.jimhester.com/post/2018-04-12-vectorize/)


```r
patient_name_best <- function(path) {
  paste0(basename(dirname(path)), "_", basename(path))
}
```


1. `SIMPLIFY` logical or character string; attempt to reduce the result to a vector, matrix or higher dimensional array; see the simplify argument of sapply. **This means the type of the function output depends on the input.**


```r
patient_name_v("some/path/abc/001.txt")
```

```
## some/path/abc/001.txt 
##         "abc_001.txt"
```

```r
patient_name_v(character())
```

```
## named list()
```

```r
patient_name_v(NULL)
```

```
## list()
```

2. Vectorize does not generate functions with easily inspect-able code
3. Vectorize functions use `do.call()`, which can have unexpected performance consequences
4. Vectorize does not actually make your code execute faster

