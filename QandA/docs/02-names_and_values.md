# Names and Values



## 2.2 Binding basics {-}

:::question
Should we care about R internals?
:::

Guided by [this blogpost](https://www.brodieg.com/2019/02/18/an-unofficial-reference-for-internal-inspect/), we can use the `.Internal` function to inspect metadata associated with our objects:


```r
 x <- list(1:5)
.Internal(inspect(x))
# > @0x000001b6a4af9fc8 19 VECSXP g0c1 [NAM(7)] (len=1, tl=0)
# > @0x000001b6a3321d90 13 INTSXP g0c0 [NAM(7)]  1 : 5 (compact)
```

* `@0x000001b6a4af9fc8` -- address (memory location)
* `19 VECSXP` -- type ([full list here](https://cran.r-project.org/doc/manuals/r-release/R-ints.html#SEXPTYPEs))
* `g0` -- garbage collector info token 
* `c1` -- size of object (small vector)
* `NAM(7)` -- named value of the object (if greater than one copy on modify)
* `len=1` -- length of object
* `tl` -- true length of object
* small snippet of the data


```r
{
  x <- list(1:5)
  .Internal(inspect(x))
}
# < @0x000001b6a4b4a3a0 19 VECSXP g0c1 [NAM(1)] (len=1, tl=0)
# < @0x000001b6a3a814d0 13 INTSXP g0c0 [NAM(7)]  1 : 5 (compact)
```

It is of note here that without curly brackets we have to use copy-on-modify, but within curly brackes we can use copy-in-place because `NAM(1)`

## 2.3 Copy-on-modify {-}

:::question
copy-on-modify vs copy-in-place: is one more preferable in certain situations?
:::

modify in place only happens when objects with a single binding get a special performance optimization and to environments.

## 2.2.2 Exercises {-}

:::question
Question 3 digs into the syntactically valid names created when using `read.csv()`, but what is the difference between quotation and backticks? 

If we create an example csv

```r
example2223 <- tibble(
  `if` = c(1,2,3),
  `_1234` = c(4,5,6),
  `column 1` = c(7,8,9)
)

write.csv(example2223, "example2223.csv", row.names = FALSE)
```

Import using adjusted column names to be syntactically valid:

```r
read.csv(file = "example2223.csv",check.names = TRUE)
```

```
##   if. X_1234 column.1
## 1   1      4        7
## 2   2      5        8
## 3   3      6        9
```

Import using non-adjusted column names

```r
read.csv(file = "example2223.csv", check.names = FALSE)
```

```
##   if _1234 column 1
## 1  1     4        7
## 2  2     5        8
## 3  3     6        9
```

Import using the tidyverse where names are not adjusted

```r
df_non_syntactic_name  <- read_csv(file = "example2223.csv")
```

```
## Parsed with column specification:
## cols(
##   `if` = col_double(),
##   `_1234` = col_double(),
##   `column 1` = col_double()
## )
```

However I really don´t understand the difference between backticks and quotation marks. For example when I select a column in the case of non-syntactic in the tidyverse I can use quotation marks or backticks 


```r
df_non_syntactic_name %>% select("if")
```

```
## # A tibble: 3 x 1
##    `if`
##   <dbl>
## 1     1
## 2     2
## 3     3
```


```r
df_non_syntactic_name %>% select(`if`)
```

But in base R, I can do this with quotation marks, but not backticks:


```r
df__non_syntactic_name["if"]
```

```
Error in `[.default`(df__non_syntactic_name, `if`) : invalid subscript type 'special'
```

According to `?Quotes` backticks are used for "non-standard variable names" but why in base R they don´t work to select columns but in the tidyverse they work to select variables?
:::

The easiest way to think about this is that backticks refer to objects while quotation marks refer to strings. `dplyr::select()` accepts object references as well as string references, while base R subsetting is done with a string or integer position.

## 2.3.2 Function calls {-}

:::question
Can we go over and break down figure in 2.3.2
:::

When you create this function:


```r
crazyfunction <- function(eh) {eh}
```

`eh` doesn't exist in memory at this point.


```r
x <- c(1,2,3)
```

x exists in memory.


```r
z <- crazyfunction(x) 
```

`z` now points at `x`, and `eh` still doesn't exist (except metaphorically in Canada). `eh` was created and exists WHILE `crazyfunction()` was being run, but doesn't get saved to the global environment, so after the function is run you can't see its memory reference. 

The round brackets `(eh)` list the arguments, the curly brackets `{eh}` define the operation that it's doing - and you're assigning it to `crazyfunction`. 

**R functions automatically return the result of the last expression** so when you call that object (the argument `eh`) it returns the value of that argument. This is called **implicit returns**

## 2.3.3 Lists {-}

:::question

Checking the address for a list and its copy we see they share the same references:


```r
l1 <- list(1,2,3)
l2 <- l1
identical(lobstr::ref(l1),lobstr::ref(l2))
```

```
## [1] TRUE
```

```r
lobstr::obj_addr(l1[[1]])
```

```
## [1] "0x7fb00e0459d8"
```

```r
lobstr::obj_addr(l2[[1]])
```

```
## [1] "0x7fb00e0459d8"
```

But why isn't this the case for their subsets? Using `obj_addr` they have different addresses, but when we look at their references they are the same


```r
lobstr::obj_addr(l1[1])
```

```
## [1] "0x7fb00cca94f0"
```

```r
lobstr::ref(l1[1])
```

```
## █ [1:0x7fb00ccc1488] <list> 
## └─[2:0x7fb00e0459d8] <dbl>
```

```r
lobstr::obj_addr(l2[1])
```

```
## [1] "0x7fb00dbfc978"
```



```r
identical(lobstr::obj_addr(l1[1]), lobstr::obj_addr(l2[1]))
```

```
## [1] FALSE
```
:::

This is because using singular brackets wraps the value 1 in a new list that is created on the fly which will have a unique address. We can use double brackets to confirm our mental model that the sublists are also identical:


```r
identical(lobstr::obj_addr(l1[[1]]), lobstr::obj_addr(l2[[1]]))
```

```
## [1] TRUE
```


:::question
What's the difference between these 2 addresses `<0x55d53fa975b8>` and `0x55d53fa975b8`?
:::

Nothing - it has to do with the printing method:


```r
x <- c(1, 2, 3)
print(tracemem(x))
```

```
## [1] "<0x7fb00e218cc8>"
```

```r
cat(tracemem(x))
```

```
## <0x7fb00e218cc8>
```

```r
lobstr::obj_addr(x)
```

```
## [1] "0x7fb00e218cc8"
```

:::question
When would you prefer a deep copy of a list to a shallow copy? Is this something to consider when writing functions or package development or is this more something that's optimized behind the scenes?
:::

Automagical!

## 2.3.5 Character vectors {-}


:::question
Is there a way to clear the "global string pool"?
:::

According to [this post](https://community.rstudio.com/t/memory-usage-and-rs-global-string-pool/4762/3) it doesn't look like you can directly, but clearing all references to a string that's in the global string pool clears that string from the pool, eventually

## 2.3.6.2 Exercise {-}

:::question
When we look at `tracemem` when we modify `x` from an integer to numeric, x is assigned to three objects. The first is the integer, and the third numeric - so what's the intermediate type?


```r
x <- c(1L, 2L, 3L)
obj_addr(x)
tracemem(x)
x[[3]] <- 4
```

```
[1] "0x7f84b7fe2c88"
[1] "<0x7f84b7fe2c88>"
tracemem[0x7f84b7fe2c88 -> 0x7f84b7fe5288]: 
tracemem[0x7f84b7fe5288 -> 0x7f84bc0817c8]: 
```

What is `0x7f84b7fe5288` when the intermediate `x <- c(1L, 2L, 4)` is impossible?
:::

When we assign the new value as an integer there is no intermediate step. This probably means `c(1,2, NA)` is the intermediate step; creating an intermediate vector that's the same length of the final product with NA values at all locations that are new or to be changed


```r
x <- c(1L, 2L, 3L)
obj_addr(x)
```

```
## [1] "0x7fb00de04d48"
```

```r
tracemem(x)
```

```
## [1] "<0x7fb00de04d48>"
```

```r
x[[3]] <- 4L
```

```
## tracemem[0x7fb00de04d48 -> 0x7fb00cccbf88]: eval eval withVisible withCallingHandlers handle timing_fn evaluate_call <Anonymous> evaluate in_dir block_exec call_block process_group.block process_group withCallingHandlers process_file <Anonymous> <Anonymous> do.call eval eval eval eval eval.parent local
```

You can dig into the C code running this: 


```r
pryr::show_c_source(.Internal("[<-"))
```

## 2.4.1 Object size {-}

:::question
If I have two vectors, one `1:10` and another `c(1:10, 10)`, intuitively, I would expect the size of the second vector to be greater than the size of the first. However, it seems to be the other way round, why?

```r
x1 <- 1:10
x2 <- rep(1:10, 10)
lobstr::obj_size(x1)
```

```
## 680 B
```

```r
lobstr::obj_size(x2)
```

```
## 448 B
```
:::

If we start with the following three vectors:

```r
x1 <- c(1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L, 9L, 10L)
x2 <- 1:10
x3 <- rep(1:10, 10)
lobstr::obj_sizes(x1, x2, x3)
```

```
## *  96 B
## * 680 B
## * 448 B
```

Intuitively, we would have expected `x1` < `x2` < `x3` but this is not the case. It appears that the `rep()` function coerces a double into integer and hence optimizes on space. Using `:`, R internally uses [ALTREP](https://blog.revolutionanalytics.com/2017/09/altrep-preview.html). 

ALTREP would actually be more efficient if the numbers represented were significantly large, say `1e7`.


```r
x4 <- 1:1e7
x5 <- x4
x5[1] <- 1L
lobstr::obj_sizes(x4, x5)
```

```
## *        680 B
## * 40,000,048 B
```

Now, the size of x4  is significantly lower than that of x5 .  This seems to indicate that ALTREP becomes super efficient as the vector size is increased.

## 2.5.1 Modify-in-place {-}

:::question
"When it comes to bindings, R can currently only count 0, 1, or many. That means that if an object has two bindings, and one goes away, the reference count does not go back to 1: one less than many is still many. In turn, this means that R will make copies when it sometimes doesn’t need to."

Can we come up with an example of this? It seems really theoretical right now.
:::

First you need to switch your Environment tab to something other than global in RStudio!

Now we can create a vector:

```r
v <- c(1, 2, 3)
(old_address <- lobstr::obj_addr(v))
```

```
## [1] "0x7fb00e1c5c18"
```

Changing a value within it changes its address:

```r
v[[3]] <- 4
(new_address <- lobstr::obj_addr(v))
```

```
## [1] "0x7fb00e08cd78"
```

```r
old_address == new_address
```

```
## [1] FALSE
```

We can assign the modified vector to a new name, where `y` and `v` point to the same thing.

```r
y <- v
(y_address <- lobstr::obj_addr(y))
```

```
## [1] "0x7fb00e08cd78"
```

```r
(v_address <- lobstr::obj_addr(v))
```

```
## [1] "0x7fb00e08cd78"
```

```r
y_address == v_address
```

```
## [1] TRUE
```

Now if we modify `v` it won't point to the same thing as `y`:

```r
v[[3]] <- 3
(y_address <- lobstr::obj_addr(y))
```

```
## [1] "0x7fb00e08cd78"
```

```r
(v_address <- lobstr::obj_addr(v))
```

```
## [1] "0x7fb00e0fee88"
```

```r
y_address == v_address
```

```
## [1] FALSE
```

But if we now change `y` to look like `v`, the original address, in theory editing y should occur in place, but it doesn't - the "count does not go back to one"!


```r
y[[3]] <- 3
(new_y_address <- lobstr::obj_addr(y))
```

```
## [1] "0x7fb00e16e758"
```

```r
new_y_address == y_address
```

```
## [1] FALSE
```

:::question

Can we break down this code a bit more? I'd like to really understand when and how it's copying three times. **As of R 4.0 it's now copied twice, the 3rd copy that's external to the function is now eliminated!!**


```r
# dataframe of 5 columns of numbers
x <- data.frame(matrix(runif(5 * 1e4), ncol = 5))
# median number for each column
medians <- vapply(x, median, numeric(1))

# subtract the median of each column from each value in the column
for (i in seq_along(medians)) {
  x[[i]] <- x[[i]] - medians[[i]]
}
```
:::



```r
cat(tracemem(x), "\n")
```

```
<0x7fdc99a6f9a8> 
```


```r
for (i in 1:5) {
  x[[i]] <- x[[i]] - medians[[i]]
}
```

```
tracemem[0x7fdc99a6f9a8 -> 0x7fdc9de83e38]: 
tracemem[0x7fdc9de83e38 -> 0x7fdc9de83ea8]: [[<-.data.frame [[<- 
tracemem[0x7fdc9de83ea8 -> 0x7fdc9de83f18]: [[<-.data.frame [[<- 
tracemem[0x7fdc9de83f18 -> 0x7fdc9de83f88]: 
tracemem[0x7fdc9de83f88 -> 0x7fdc9de83ff8]: [[<-.data.frame [[<- 
tracemem[0x7fdc9de83ff8 -> 0x7fdc9de84068]: [[<-.data.frame [[<- 
tracemem[0x7fdc9de84068 -> 0x7fdc9de840d8]: 
tracemem[0x7fdc9de840d8 -> 0x7fdc9de84148]: [[<-.data.frame [[<- 
tracemem[0x7fdc9de84148 -> 0x7fdc9de841b8]: [[<-.data.frame [[<- 
tracemem[0x7fdc9de841b8 -> 0x7fdc9de84228]: 
tracemem[0x7fdc9de84228 -> 0x7fdc9de84298]: [[<-.data.frame [[<- 
tracemem[0x7fdc9de84298 -> 0x7fdc9de84308]: [[<-.data.frame [[<- 
tracemem[0x7fdc9de84308 -> 0x7fdc9de84378]: 
tracemem[0x7fdc9de84378 -> 0x7fdc9de843e8]: [[<-.data.frame [[<- 
tracemem[0x7fdc9de843e8 -> 0x7fdc9de84458]: [[<-.data.frame [[<- 
```

When we run `tracemem` on the for loop above we see each column is copied twice followed by the `[[<-.data.frame [[<- `, the stack trace showing exactly where the duplication occurred.

So what is ``[[<-.data.frame``? It's a function! By looking at `?``[[<-.data.frame`` we see this is used to "extract or replace subsets of data frames."

When we write `x[[i]] <- value`, it's really shorthand for calling the function `[[<-.data.frame` with inputs `x`, `i`, and `value`. 

Now let's step into the call of this base function by running `debug(``[[<-.data.frame``)`:


```r
debug(`[[<-.data.frame`)
```

and once inside, use `tracemem()` to find where the new values are assigned to the column:


```r
function (x, i, j, value) 
{
  if (!all(names(sys.call()) %in% c("", "value"))) 
    warning("named arguments are discouraged")
  cl <- oldClass(x)
  # this is where another copy of x is made!
  class(x) <- NULL
```

```
 # tracemem[0x7fdc9d852a18 -> 0x7fdc9c99cc08]: 
```


```r
nrows <- .row_names_info(x, 2L)
  if (is.atomic(value) && !is.null(names(value))) 
    names(value) <- NULL
  if (nargs() < 4L) {
    nc <- length(x)
    if (!is.null(value)) {
      N <- NROW(value)
      if (N > nrows) 
        stop(sprintf(ngettext(N, "replacement has %d row, data has %d", 
          "replacement has %d rows, data has %d"), N, 
          nrows), domain = NA)
      if (N < nrows) 
        if (N > 0L && (nrows%%N == 0L) && length(dim(value)) <= 
          1L) 
          value <- rep(value, length.out = nrows)
        else stop(sprintf(ngettext(N, "replacement has %d row, data has %d", 
          "replacement has %d rows, data has %d"), N, 
          nrows), domain = NA)
    }
    x[[i]] <- value
    if (length(x) > nc) {
      nc <- length(x)
      if (names(x)[nc] == "") 
        names(x)[nc] <- paste0("V", nc)
      names(x) <- make.unique(names(x))
    }
    class(x) <- cl
    return(x)
  }
  if (missing(i) || missing(j)) 
    stop("only valid calls are x[[j]] <- value or x[[i,j]] <- value")
  rows <- attr(x, "row.names")
  nvars <- length(x)
  if (n <- is.character(i)) {
    ii <- match(i, rows)
    n <- sum(new.rows <- is.na(ii))
    if (n > 0L) {
      ii[new.rows] <- seq.int(from = nrows + 1L, length.out = n)
      new.rows <- i[new.rows]
    }
    i <- ii
  }
  if (all(i >= 0L) && (nn <- max(i)) > nrows) {
    if (n == 0L) {
      nrr <- (nrows + 1L):nn
      if (inherits(value, "data.frame") && (dim(value)[1L]) >= 
        length(nrr)) {
        new.rows <- attr(value, "row.names")[seq_len(nrr)]
        repl <- duplicated(new.rows) | match(new.rows, 
          rows, 0L)
        if (any(repl)) 
          new.rows[repl] <- nrr[repl]
      }
      else new.rows <- nrr
    }
    x <- xpdrows.data.frame(x, rows, new.rows)
    rows <- attr(x, "row.names")
    nrows <- length(rows)
  }
  iseq <- seq_len(nrows)[i]
  if (anyNA(iseq)) 
    stop("non-existent rows not allowed")
  if (is.character(j)) {
    if ("" %in% j) 
      stop("column name \"\" cannot match any column")
    jseq <- match(j, names(x))
    if (anyNA(jseq)) 
      stop(gettextf("replacing element in non-existent column: %s", 
        j[is.na(jseq)]), domain = NA)
  }
  else if (is.logical(j) || min(j) < 0L) 
    jseq <- seq_along(x)[j]
  else {
    jseq <- j
    if (max(jseq) > nvars) 
      stop(gettextf("replacing element in non-existent column: %s", 
        jseq[jseq > nvars]), domain = NA)
  }
  if (length(iseq) > 1L || length(jseq) > 1L) 
    stop("only a single element should be replaced")
  x[[jseq]][[iseq]] <- value
  # here is where x is copied again!
  class(x) <- cl
```

```
# tracemem[0x7fdc992ae9d8 -> 0x7fdc9be55258]: 
```

```r
  x
}
```

Thus seeing exactly where the three **as of R 4.0: two!** copies are happening.
