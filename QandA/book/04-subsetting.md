# Subsetting



## 4.1 Introduction {-}

:::question
"There are three subsetting operators `[`. `[[`, `$`. What is the distinction between an operator and a function? When you look up the help page it brings up the same page for all three extraction methods. What are their distinctions and do their definitions change based on what you're subsetting? Can we make a table? 
:::

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:left;"> [ </th>
   <th style="text-align:left;"> [[ </th>
   <th style="text-align:left;"> $ </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;font-weight: bold;border-right:1px solid;"> ATOMIC </td>
   <td style="text-align:left;"> RETURNS VECTOR WITH ONE ELEMENT </td>
   <td style="text-align:left;"> SAME AS [ </td>
   <td style="text-align:left;"> NOPE! </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;border-right:1px solid;"> LIST </td>
   <td style="text-align:left;"> RETURNS A LIST </td>
   <td style="text-align:left;"> RETURNS SINGLE ELEMENT FROM WITHIN LIST </td>
   <td style="text-align:left;"> RETURN SINGLE ELEMENT FROM LIST [CAN ONLY USE WHEN LIST VECTOR HAS A NAME] </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;border-right:1px solid;"> MATRIX </td>
   <td style="text-align:left;"> RETURNS A VECTOR </td>
   <td style="text-align:left;"> RETURNS A VECTOR OR SINGLE VALUE </td>
   <td style="text-align:left;"> NOPE! </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;border-right:1px solid;"> DATA FRAME </td>
   <td style="text-align:left;"> RETURNS A VECTOR OR DATA FRAME </td>
   <td style="text-align:left;"> RETURNS VECTOR/LIST/MATRIX OR SINGLE VALUE </td>
   <td style="text-align:left;"> RETURNS VECTOR/LIST/MATRIX USING COLUMN NAME </td>
  </tr>
  <tr>
   <td style="text-align:left;font-weight: bold;border-right:1px solid;"> TIBBLE </td>
   <td style="text-align:left;"> RETURNS A TIBBLE </td>
   <td style="text-align:left;"> RETURNS A VECTOR OR SINGLE VALUE </td>
   <td style="text-align:left;"> RETURNS THE STR OF THE COLUMN - TIBBLE/LIST/MATRIX </td>
  </tr>
</tbody>
</table>

If we think of everything as sets (which have the properties of 0,1, or many elements), if the set has 1 element it only contains itself and `NULL` subsets. Before you subset using `[` or `[[` count the elements in the set. If it has zero elements you are done, if it has one element `[` will return itself - to go further you need to use `[[` to return its contents. If there is more than one element in the set then `[` will return those elements. [You can read more about subsetting here](https://bookdown.org/rdpeng/rprogdatascience/subsetting-r-objects.html#subsetting-a-vector)

## 4.2.1 Selecting multiple elements {-}

:::question
Why is `numeric(0)` "helpful for test data?"
:::

This is more of a general comment that one should make sure one's code doesn't crash with vectors of zero length (or data frames with zero rows)

:::question
Why is subsetting with factors "not a good idea"
:::

Hadley's notes seem to say subsetting with factors uses the "integer vector of levels" - and if they all have the same level, it'll just return the first argument. Subsetting a factor vector leaves the factor levels behind unless you explicitly drop the unused levels

## 4.2.2 lists {-}

:::question
We've been talking about `$` as a shorthand for `[[`. Using the example list `x <- list(1:3, "a", 4:6)` can we use `x$1` as shorthand for `x[[1]]`?
:::

The "shorthand" refers to using the name of the vector to extract the vector. If we give `1:3` a name such as test = `1:3`


```r
x <- list(named_vector = 1:3, "a", 4:6)
x[[1]] == x$named_vector
```

```
## [1] TRUE TRUE TRUE
```

As such, `$` is a shorthand for `x[["name_of_vector"]]` and not shorthand for `x[[index]]`

## 4.3.1 `[[` {-}

:::question

The book states: 

*While you must use [[ when working with lists, I’d also recommend using it with atomic vectors whenever you want to extract a single value. For example, instead of writing:*


```r
for (i in 2:length(x)) {
  out[i] <- fun(x[i], out[i - 1])
}
```

*It's better to write*


```r
for (i in 2:length(x)) {
  out[[i]] <- fun(x[[i]], out[[i - 1]])
}
```

Why? Can we see this in action by giving `x`, `out`, and `fun` real life values?
:::

If we have a vector

```r
df_x <- c("Advanced","R","Book","Club")
```

We can use `[` or `[[` to extract the third element of `df_x`

```r
df_x[3]
```

```
## [1] "Book"
```

```r
df_x[[3]]
```

```
## [1] "Book"
```

But in the case where we want to extract an element from a list `[` and `[[` no longer give us the same results

```r
df_x <- list(A = "Advanced", B = "R", C = "Book", D = "Club")

df_x[3]
```

```
## $C
## [1] "Book"
```

```r
df_x[[3]]
```

```
## [1] "Book"
```

Because using `[[` returns "one element of this vector" in both cases, it makes sense to default to `[[` instead of `[` since it will reliably return a single element. 

## 4.3.5 Exercise {-}

:::question
The question asks to describe the `upper.tri` function - let's dig into it!
:::


```r
x <- outer(1:5, 1:5, FUN = "*")
upper.tri(x)
```

```
##       [,1]  [,2]  [,3]  [,4]  [,5]
## [1,] FALSE  TRUE  TRUE  TRUE  TRUE
## [2,] FALSE FALSE  TRUE  TRUE  TRUE
## [3,] FALSE FALSE FALSE  TRUE  TRUE
## [4,] FALSE FALSE FALSE FALSE  TRUE
## [5,] FALSE FALSE FALSE FALSE FALSE
```

We see that it returns the upper triangle of the matrix. But I wanted to walk through how this function actually works and what is meant in the solution manual by leveraging `.row(dim(x)) <= .col(dim(x))`.


```r
# ?upper.tri
function (x, diag = FALSE) 
{
    d <- dim(x)
    # if you have an array thats more than 2 dimension
    # we need to flatten it to a matrix
    if (length(d) != 2L) 
        d <- dim(as.matrix(x))
    if (diag) 
      # this is our subsetting logical!
         .row(d) <= .col(d)
    else .row(d) < .col(d)
}
```

The function `.row()` and `.col()` return a matrix of integers indicating their row number


```r
.row(dim(x))
```

```
##      [,1] [,2] [,3] [,4] [,5]
## [1,]    1    1    1    1    1
## [2,]    2    2    2    2    2
## [3,]    3    3    3    3    3
## [4,]    4    4    4    4    4
## [5,]    5    5    5    5    5
```


```r
.col(dim(x))
```

```
##      [,1] [,2] [,3] [,4] [,5]
## [1,]    1    2    3    4    5
## [2,]    1    2    3    4    5
## [3,]    1    2    3    4    5
## [4,]    1    2    3    4    5
## [5,]    1    2    3    4    5
```


```r
.row(dim(x)) <= .col(dim(x))
```

```
##       [,1]  [,2]  [,3]  [,4] [,5]
## [1,]  TRUE  TRUE  TRUE  TRUE TRUE
## [2,] FALSE  TRUE  TRUE  TRUE TRUE
## [3,] FALSE FALSE  TRUE  TRUE TRUE
## [4,] FALSE FALSE FALSE  TRUE TRUE
## [5,] FALSE FALSE FALSE FALSE TRUE
```


:::question
Is there a high level meaning to a `.` before function? Does this refer to internal functions? [see: ?`row` vs ?`.row`]
:::

Objects in the global environment prefixed with `.` are hidden in the R (and RStudio) environment panes - so functions prefixed as such are not visible unless you do `ls(all=TRUE)`. [Read more here](https://community.rstudio.com/t/function-argument-naming-conventions-x-vs-x/7764) and (here)[https://stackoverflow.com/questions/7526467/what-does-the-dot-mean-in-r-personal-preference-naming-convention-or-more]

## 4.3.3 Missing and OOB {-}

:::question
Let's walk through examples of each
:::

### LOGICAL ATOMIC {-}


```r
c(TRUE, FALSE)[[0]] # zero length
# attempt to select less than one element in get1index <real>
c(TRUE, FALSE)[[4]] # out of bounds
# subscript out of bounds
c(TRUE, FALSE)[[NA]] # missing
# subscript out of bounds
```

### LIST {-}

```r
list(1:3, NULL)[[0]] # zero length
# attempt to select less than one element in get1index <real>
list(1:3, NULL)[[3]] # out of bounds
# subscript out of bounds
list(1:3, NULL)[[NA]] # missing
# NULL
```

### NULL {-}


```r
NULL[[0]] # zero length
# NULL
NULL[[1]] # out of bounds
# NULL
NULL[[NA]] # missing
# NULL
```

## 4.5.8 Logical subsetting {-}

:::question
"Remember to use the vector Boolean operators `&` and `|`, not the short-circuiting scalar operators `&&` and `||`, which are more useful inside if statements." 

Can we go over the difference between `&` and `&&` (and `|` vs `||`) I use brute force to figure out which ones I need...
:::

`&&` and `||` only ever return a single (scalar, length-1 vector) `TRUE` or `FALSE` value, whereas `|` and `&` return a vector after doing element-by-element comparisons.

The only place in R you routinely use a scalar `TRUE`/`FALSE` value is in the conditional of an `if` statement, so you'll often see `&&` or `||` used in idioms like: `if (length(x) > 0 && any(is.na(x))) { do.something() }`

In most other instances you'll be working with vectors and use `&` and `|` instead.

Using `&&` or `||` results in some unexpected behavior - which could be a big performance gain in some cases:

- `||` will not evaluate the second argument when the first is `TRUE`
- `&&` will not evaluate the second argument when the first is `FALSE`


```r
true_one <- function() { print("true_one evaluated."); TRUE}
true_two <- function() { print("true_two evaluated."); TRUE}
# arguments are evaluated lazily.  Unexpected behavior can result:
c(T, true_one()) && c(T, true_two())
```

```
## [1] "true_one evaluated."
## [1] "true_two evaluated."
```

```
## [1] TRUE
```

```r
c(T, true_one()) && c(F, true_two())
```

```
## [1] "true_one evaluated."
## [1] "true_two evaluated."
```

```
## [1] FALSE
```

```r
c(F, true_one()) && c(T, true_two()) 
```

```
## [1] "true_one evaluated."
```

```
## [1] FALSE
```

```r
c(F, true_one()) && c(F, true_two()) 
```

```
## [1] "true_one evaluated."
```

```
## [1] FALSE
```

```r
c(T, true_one()) || c(T, true_two())
```

```
## [1] "true_one evaluated."
```

```
## [1] TRUE
```

```r
c(T, true_one()) || c(F, true_two())
```

```
## [1] "true_one evaluated."
```

```
## [1] TRUE
```

```r
c(F, true_one()) || c(T, true_two()) 
```

```
## [1] "true_one evaluated."
## [1] "true_two evaluated."
```

```
## [1] TRUE
```

```r
c(F, true_one()) || c(F, true_two()) 
```

```
## [1] "true_one evaluated."
## [1] "true_two evaluated."
```

```
## [1] FALSE
```

Read more about [Special Primatives](https://cran.r-project.org/doc/manuals/r-release/R-ints.html#Special-primitives) here

## 4.5.8 Boolean algebra {-}

:::question
The `unwhich()` function takes a boolean and turns it into a numeric - would this ever be useful? How?
:::

:::TODO
XXX
:::

:::question
"`x[-which(y)]` is not equivalent to `x[!y]`: if `y` is all FALSE, `which(y)` will be `integer(0)` and `-integer(0)` is still `integer(0)`, so you’ll get no values, instead of all values."

Can we come up with an example for this plugging in values for `x` and `y`
:::


```r
c(TRUE, FALSE)[-which(FALSE)]
```

```
## logical(0)
```

```r
c(TRUE, FALSE)[!FALSE]
```

```
## [1]  TRUE FALSE
```
