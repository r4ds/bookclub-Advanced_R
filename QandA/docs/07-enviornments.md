# Environments




## 7.2.3 Parents {-}

:::question
What's the relationship between base, empty enviornment, and global enviornment?
:::

The working environment is the environment whose names would currently mask names in any other environment. Note that in the book, the term current environment is used not working environment. At any given time there is an environment that is most immediately-visible i.e. its names will mask the same names in any other environment. This is the current environment. The identity of the current environment can change e.g. when entering a function. It is often the case that the current environment is the global environment i.e. typically when working interactively.

:::question
Are functions the only mechanism for changing the current environment? (I believe the answer is yes.)
:::

Consider the following from the book:

> The current environment, or `current_env()` is the environment in which code is currently executing. When you're experimenting interactively, that's usually the global environment, or `global_env()`. 

The use of the word "usually" in this sentence raises the possibility that there's an exception. That exception could possibly mean 

1. There's a way to change the environment in interactive mode without going into a function
2. You can experiment interactively within a function or 
3. Something I'm ignorant of. 

I know that you can step-through a function in the debug browser so maybe that's what he means?

But then the very next line in the text says:

> The global environment is sometimes called your "workspace", as it's where all interactive (i.e. outside of a function) computation takes place. 

It both i) defines interactive specifically to exclude the inside of a function and ii) makes a stronger claim, "all interactive computation" vs "usually".

If you put a breakpoint or `browser()` call inside a function, then you would be working interactively in a function environment.

:::question
Does hierarchy of environments have a computer science name (linked list?)?
:::

The hierarchy of environments is not a linked list, it is a directed graph.

:::question
Clarification: the global environment's parent is all the packages loaded within the environment, not the empty environment, right? How do we check this? `parent.env(global)`?
:::

Each package becomes a parent to the global environment. We can inspect local enviornments using `search_envs()`


```r
search_envs()
```

```
##  [[1]] $ <env: global>
##  [[2]] $ <env: package:openintro>
##  [[3]] $ <env: package:usdata>
##  [[4]] $ <env: package:cherryblossom>
##  [[5]] $ <env: package:airports>
##  [[6]] $ <env: package:rlang>
##  [[7]] $ <env: package:lobstr>
##  [[8]] $ <env: package:kableExtra>
##  [[9]] $ <env: package:forcats>
## [[10]] $ <env: package:stringr>
## [[11]] $ <env: package:dplyr>
## [[12]] $ <env: package:purrr>
## [[13]] $ <env: package:readr>
## [[14]] $ <env: package:tidyr>
## [[15]] $ <env: package:tibble>
## [[16]] $ <env: package:ggplot2>
## [[17]] $ <env: package:tidyverse>
## [[18]] $ <env: package:stats>
## [[19]] $ <env: package:graphics>
## [[20]] $ <env: package:grDevices>
## ... and 5 more environments
```

## 7.2.4 Super assignment {-}

:::question
Let's expand on the concept of super assignment
:::


```r
x <- 0
f <- function() {
  x <- 2
  x <<- 1
  x
}
f()
```

```
## [1] 2
```

```r
x
```

```
## [1] 1
```

Note that the assignment inside `f` is local, but super assignment "never creates a variable in the current environment" so it modifies the global `x` and not the local `x`. 

If you want to break your brain a bit, check out:


```r
x <- 0
f <- function() {
  x <- x
  x <<- x + 1
  x
}
f()
```

```
## [1] 0
```

```r
x
```

```
## [1] 1
```

```r
f()
```

```
## [1] 1
```

```r
x
```

```
## [1] 2
```

```r
f()
```

```
## [1] 2
```

```r
x
```

```
## [1] 3
```
## 7.2.5 Getting and setting {-}

:::question
"But you can’t use `[[` with numeric indices, and you can’t use `[`:"

It makes sense to me that you can't use numeric indexes because objects in an environment aren't ordered, but why can't you use `[`? _The solutions manual states: "The second option would return two objects at the same time. What data structure would they be contained inside?_
:::

`[` returns an object of the same type, if we were to apply this to environments we'd have an environment returning an environment.

## 7.2.6 Advanced bindings {-}

:::question
Hadley mentions delayed bindings are used when autoloading datasets with packages - can we find an example of this? How is this different from including `LazyData: true` in your description file?
:::

The `LazyData: true` entry in `DESCRIPTION` just informs that delayed binding should be used. `autoload` **does** use delayed bindings [from source code: `do.call("delayedAssign", list(name, newcall, .GlobalEnv, .AutoloadEnv))`] but lazydata that gets used by packages is ultimately implemented as an internal function. If you scan through `View(loadNamespace)`:


```r
if (file.exists(paste0(dbbase, ".rdb"))) 
      lazyLoad(dbbase, env)
    dbbase <- file.path(pkgpath, "data", "Rdata")
    if (file.exists(paste0(dbbase, ".rdb"))) 
      lazyLoad(dbbase, .getNamespaceInfo(env, "lazydata"))
```

and `lazyLoad` eventually calls `.Internal(makeLazy(vars, vals, expr, db, envir))` which leads you to https://github.com/wch/r-source/blob/726bce63825844715860d35fdf76539445529f52/src/main/builtin.c#L103
and ultimately the delayed binding is realized as a promise with `defineVar(name, mkPROMISE(expr0, eenv), aenv);`.


## 7.3 Recursing over environments {-}

:::question
How can we re-write `where` so that it returns all functions with the same name?
:::


```r
where2 <- function(in_name, env = caller_env()) {
  
  all_functions <- ""
  index <- 1

  while (!identical(env, empty_env())) {
    # if success
    if (env_has(env, in_name)) {
      all_functions[index] <- env_name(env)
      index <- index + 1
      #return()
    }
    # inspect parent
    env <- env_parent(env)
  }
  # base case - I'm missing this I think
  return(all_functions)
}

# load dplyr so you have two filters
library(dplyr)
where2("filter")
```

```
## [1] "package:dplyr" "package:stats"
```

We can also create a function that emulates `pryr`'s where:


```r
where3 <- function(name, env = parent.frame(), found = character()) {
  if (identical(env, emptyenv()))
    return(found)
  else if (exists(name, env, inherits = FALSE)) {
    Recall(name, parent.env(env), c(found, environmentName(env)))
  } else {
    Recall(name, parent.env(env), found)
  }
}
  
where3("filter")
```

```
## [1] "package:dplyr" "package:stats"
```


## 7.3.1.2 Exercises {-}

:::question
I understood the recursion in the prior example, but what is inherits doing here? Can we go through this line for line and discuss what is happening in this function?


```r
fget <- function(name, env = caller_env(), inherits = TRUE) {
  # Base case
  if (env_has(env, name)) {
    obj <- env_get(env, name)

    if (is.function(obj)) {
      return(obj)
    }
  }

  if (identical(env, emptyenv()) || !inherits) {
    stop("Could not find function called \"", name, "\"", call. = FALSE)
  }

  # Recursive Case
  fget(name, env_parent(env))
}
```


```r
# Test
mean <- 10
fget("mean", inherits = TRUE)
```

```
## function (x, ...) 
## UseMethod("mean")
## <bytecode: 0x7fa7e583f778>
## <environment: namespace:base>
```
:::

Inherits is an argument that stops the function from performing the recursive action of looking into the parent environment for the name. Inherits is acting like a valve. If false, and the name wasnt found in the current environment, then stop because the next expression searches the parent of env. In the case environment is the empty environment then stop because the empty environment doesnt have a parent.

## 7.4.2 Function enviornment {-}

:::question
I found this section a little confusing. Can we go over the second figure in the section? Where does `x` live?  `g` points to x but `x` is in the global enviornment? Can we come up with our own example for a function being bound to the global environment but accessing variables from its own enviornment? (I think this is what the second figure in the section is trying to display)


```r
y <- 1
e <- env()
e$g <- function() 1
e$g
```

```
## function() 1
```
:::

This can be seen in our `where2` example in the recursion section!

## 7.4.3 Namespaces {-}

:::question
"Every binding in the package environment is also found in the namespace environment; this ensures every function can use every other function in the package. But some bindings only occur in the namespace environment. These are known as internal or non-exported objects, which make it possible to hide internal implementation details from the user."

When you’re developing a package does the namespace environment just come with your package for free when you build it or you need to create both your package and its namespace env? 

How do you create functions that exist only in the namespace environment?
:::

When you are building the package, everything in the NAMESPACE file gets generated by `roxygen2`. Attaching a package puts the package in the search path of namespaces. So when you run `library(package)` or `require(package)` it creates the namespace environment. Package developers control what names are available by exporting to namespace (and otherwise you can call non-exported with `:::`).

For example let's say you want to extend `forcats` to use ordered factors to lump the tails.  In order to get it to work, we need to use some forcats helper functions. We could just copy the code for the functions and added them to our scripts, but for prototyping it's easy enough to just use `:::`


```r
fct_lump_ordered <- function(f, n, prop, q, w = NULL,
                             other_level_low = "Other Low",
                             other_level_high = "Other High",
                             ties.method = c("min", "average", "first", "last", "random", "max")) {
  f <- check_ordered(f)
  w <- forcats:::check_weights(w, length(f))
  ties.method <- match.arg(ties.method)
  levels <- levels(f)
  if (is.null(w)) {
    count <- as.vector(table(f))
    total <- length(f)
  } else {
    count <- as.vector(tapply(w, f, FUN = sum))
    total <- sum(w)
  }
  if (all(missing(n), missing(prop), missing(q))) {
    lump <- forcats:::in_smallest(count)
    lump <- lump_range(!lump)
    new_levels <- ifelse(lump == -1L,other_level_low, ifelse(lump == 1L, other_level_high, levels))
  } else if (!missing(n) ) {
    if (n < 0) {
      rank <- rank(count, ties = ties.method)
      n <- -n
    } else {
      rank <- rank(-count, ties = ties.method)
    }
    if (sum(rank > n) <= 1) {
      return(f)
    }
    lump <- lump_range(rank <= n)
    new_levels <- ifelse(lump == -1L, other_level_low, ifelse(lump == 1L, other_level_high, levels))
  } else if (!missing(prop)) {
    prop_n <- count/total
    if(prop < 0) {
      lump <- lump_range(prop_n <= -prop)
      new_levels <- ifelse(lump == -1L, other_level_low, ifelse(lump == 1L, other_level_high, levels))
    } else {
      if (sum(prop_n <= prop) <= 1) {
        return(f)
      }
      lump <- lump_range(prop_n >= prop)
      new_levels <- ifelse(lump == -1L, other_level_low, ifelse(lump == 1L, other_level_high, levels))
    }
  } else if (!missing(q)) {
    cdf <- cumsum(count)/sum(count)
    lump <- lump_range(cdf >= q[1] & cdf <= q[2])
    new_levels <- ifelse(lump == -1L, other_level_low, ifelse(lump == 1L, other_level_high, levels))
  }
  if (other_level_low %in% new_levels && other_level_high %in% new_levels) {
    f <- forcats::lvls_revalue(f, new_levels)
    forcats::fct_relevel(f, other_level_low)
    forcats::fct_relevel(f, other_level_high, after = Inf)
  } else if (other_level_low %in% new_levels) {
    f <- forcats::lvls_revalue(f, new_levels)
    forcats::fct_relevel(f, other_level_low)
  } else if (other_level_high %in% new_levels) {
    f <- forcats::lvls_revalue(f, new_levels)
    forcats::fct_relevel(f, other_level_high, after = Inf)
  }
  else {
    f
  }
```

:::question
How do conflicted packages identify duplicate function names and print them out
:::

We can use `conflict_scout`!


```r
conflicted::conflict_scout
```

```
## function (pkgs = NULL) 
## {
##     pkgs <- pkgs %||% pkgs_attached()
##     objs <- lapply(pkgs, pkg_ls)
##     names(objs) <- pkgs
##     index <- invert(objs)
##     potential <- Filter(function(x) length(x) > 1, index)
##     unique <- Map(unique_obj, names(potential), potential)
##     conflicts <- Filter(function(x) length(x) > 1, unique)
##     conflicts <- map2(names(conflicts), conflicts, superset_principle)
##     conflicts <- map2(names(conflicts), conflicts, drop_moved)
##     for (fun in ls(prefs)) {
##         if (!has_name(conflicts, fun)) 
##             next
##         conflicts[[fun]] <- prefs_resolve(fun, conflicts[[fun]])
##     }
##     conflicts <- compact(conflicts)
##     new_conflict_report(conflicts)
## }
## <bytecode: 0x7fa7e8e27a18>
## <environment: namespace:conflicted>
```


## 7.5 Call stacks {-}

:::question
What exactly is a frame?
:::

A frame is a singular step within the CST - in thr following example, `f`, `g`, and `h` are each frames


```r
f <- function(x) {
  g(x = 2)
}
g <- function(x) {
  h(x = 3)
}
h <- function(x) {
  stop()
}
```

## 7.6 Data Structures {-}

:::question
Can we discuss what's happening in this function? Since it's similar to the `setwd` function from last week could we build on this function to include `on.exit()`?


```r
my_env <- new.env(parent = emptyenv())
my_env$a <- 1

get_a <- function() {
  my_env$a
}

set_a <- function(value) {
  old <- my_env$a
  my_env$a <- value
  invisible(old)
}
```
:::

We can use those two functions like we did getting and setting the work directory inside another function - using the old value within `on.exit` to reset `my_env$a` outside of the function: Hadley suggests returning invisible old so that you don't need to explicitly call `get_a`, you can just assign the output of `set_a`


```r
set_a <- function(value) {
  old <- my_env$a
  my_env$a <- value
  invisible(old)
}

do_thing_where_env_a_is_value(value, code) {
  myoldenv <- set_a(value) # sets a to the NEW value and returns the OLD value for storage
  on.exit(set_a(myoldenv), add=TRUE)
  force(code)
} 
```

:::question
The bullet point mentions hashmaps but I'm still really unclear on what that is. What are hash tables and are they related?
:::

They are sort of like fast look-up tables! It may be impossible to show with a small example. To demonstrate that the lookup is fast you'd need to store a lot of stuff in it first. You'd also probably need an alternative implementation of a lookup table to compare it to. We could probably implement a hash table relatively easily* using environments. Demonstrating that using environments is a good way to do it seems difficult.

* looking at a data structures textbook (Cormen, Lieserson & Rivest), a hash table is expected to provide users with fast functions for insert, search, and delete.
