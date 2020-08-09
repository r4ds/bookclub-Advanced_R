# Conditions



## 8.3 Ignoring conditions {-}

:::question
I can't quite think of a time where `try` is more appropriate than `tryCatch` - does anyone have an example?
:::

It seems that try is just a wrapper for `tryCatch` and you can use it whenever you'd use `try`

:::question
When would you actually use `suppressWarning`? Maybe when loading libraries? I created an example for `suppressMessages`, but does someone have a better, practical use case?
:::

As a function user, it's common to suppress warnings when loading in data and using `readr` and `dplyr` - but not so much as a function creator

## 8.4.2 Exiting handlers {-}

:::question

```r
tryCatch(
  message = function(cnd) "There",
  {
    message("Here")
    stop("This code is never run!")
  }
)
#> [1] "There"
```

> The protected code is evaluated in the environment of `tryCatch()`, but the handler code is not, because the handlers are functions.

Clarification question what is the "handler code" and "protected code"?
:::

The protected code is inside the `{}` and the handler code is `message = function(cnd) "There"`

:::question
In the tryCatch example where we have `finally` print "Thank God for Beer" I find it interesting that this is printed **before** the code inside the tryCatch. Can anyone explain why?
:::

From the help it's, "expression to be evaluated before returning or exiting." That means it's the final thing that happens inside the `tryCatch`, but it happens before the return (of NA or the string), so it happens first.

## 8.4.3 Calling handlers {-}

:::question
How would you define bubbling up?
:::

**Bubbling up:** By default, a condition will continue to propagate to parent handlers, all the way up to the default handler (or an exiting handler, if provided)

I would consider what is being described there "bubbling up".

:::question
Why is this message executed once per message in the function?


```r
withCallingHandlers(
  message = function(cnd) cat("Caught a message!\n"), 
  {
    message("Someone there?")
    message("Why, yes!")
  }
)
```

```
#> Caught a message!
#> Someone there?
#> Caught a message!
#> Why, yes!
```
:::


`withCallingHandlers` could be understood as: "for each {message}, do x"

The following prints the message once:


```r
withCallingHandlers(
  message = function(cnd) cat("Caught a message!\n"), 
  {
    warning("Someone there?")
    message("Why, yes!")
  }
)
```

```
## Warning in withCallingHandlers(message = function(cnd) cat("Caught a message!
## \n"), : Someone there?
```

```
## Caught a message!
```

```
## Why, yes!
```

and it comes in the warning message, so it's not really a "direct" print

:::TODO
Oh wait, the handler code is named `message`, so is it possible that the two message calls in the protected block are actually calling both `base::message` and the message - named handler?
:::

:::question
> The return value of a calling handler is ignored because the code continues to execute after the handler completes; where would the return value go? That means that calling handlers are only useful for their side-effects.

Can we come up with an example for this masking? I think seeing it will help me understand...
:::

This just means that you cannot capture the return value of your handler (but you sort of can)


```r
f <- function() {
  my_lovin <- NULL
  withCallingHandlers(
    message = function(cnd) {my_lovin <<- "not this time"},
    {
      never_ever_gunna_get_it = message("No, you're never gonna get it")
    }
  )
  my_lovin
}
f()
```

```
## No, you're never gonna get it
```

```
## [1] "not this time"
```

:::question
How does muffling differ from `suppressWarnings`?
:::

muffling allows for an over-ride/replacement of messages, while suppress just quiets everything:


```r
fn <- function() {
  inform("Beware!", "my_particular_msg")
  inform("On your guard!")
  "foobar"
}
```

Now we can use a new definition of `my_particular_msg` to replace "Beware"


```r
with_handlers(fn(),
  my_particular_msg = calling(function(cnd) {
    inform("Dealt with this particular message")
    cnd_muffle(cnd)
  })
)
```

```
## Dealt with this particular message
```

```
## On your guard!
```

```
## [1] "foobar"
```
whereas suppressMessages just returns foobar:


```r
suppressMessages(fn())
```

```
## [1] "foobar"
```

## 8.4.5.2 Exercises {-}

:::question
In the example 


```r
show_condition <- function(code) {
  tryCatch(
    error = function(cnd) "error",
    warning = function(cnd) "warning",
    message = function(cnd) "message",
    {
      code
      NULL
    }
  )
}
```

The first three calls to `show_condition` make sense to me, and I even understand that the first time the code is evaluated inside a `tryCatch` it exists (that's why it returns `message`) but how are you supplying `3` arguments to a function that just takes on one argument, `code`? Is that what the `{}` are for?


```r
show_condition({
  10
  message("?")
  warning("?!")
})
```
:::

`{}` let us execute multiple lines of code!

## 8.4.5.3 Exercises {-}

:::question
I couldn't follow the manual's answer for what's happening here, can we come up with our own answer for what's happening here in words?
:::


```r
withCallingHandlers(
  message = function(cnd) message("b"),
  withCallingHandlers(
    message = function(cnd) message("a"),
    message("c")
  )
)
```

```
## b
```

```
## a
```

```
## b
```

```
## c
```

The first call to `withcallinghandlers` adds a condition handler for conditions with class "message" to the handler stack (not sure if its actually a stack?)  and then executes the second `withcallinghandlers` which adds another condition handler for conditions with class "message" to the handler stack (see above), and then executes the code `message("c")`.

What happens next is a chain reaction of handlers. The call `message("c")` is handled by the inner handler, which then calls `message("a")`, but `message("a")` is caught by the outer handler, and so it outputs `b` first.  

Then the inner handler resolves itself and outputs `a` and then that condition (having not been muffled) "bubbles up" to the outer handler, which calls `message("b")` again producing the second `b` and again since the message wasn't muffled, the original condition `message("c")` "bubbles up" to the top where it is evaluated producing the output `c`

:::question
Another exercise: Guess the output of these two functions:
:::


```r
i <- 1
withCallingHandlers(
  message = function(cnd) {message(paste0(i, ". b")); i <<- i+1},
  withCallingHandlers(
    message = function(cnd) {message(paste0(i, ". a")); i <<- i+1},
    {message(paste0(i, ". c"))}
  )
)
```

```
## 1. b
```

```
## 1. a
```

```
## 3. b
```

```
## 1. c
```


```r
i <- 1
withCallingHandlers(
  message = function(cnd) {i <<- i+1; message(paste0(i, ". b"))},
  withCallingHandlers(
    message = function(cnd) {i <<- i+1; message(paste0(i, ". a"))},
    {message(paste0(i, ". c"))}
  )
)
```

```
## 3. b
```

```
## 2. a
```

```
## 4. b
```

```
## 1. c
```


## 8.6.3 Resignal {-}

:::question
Can we go over what is happening here?


```r
warning2error <- function(expr) {
  withCallingHandlers(
    warning = function(cnd) abort(conditionMessage(cnd)),
    expr
  )
}

warning2error({
  x <- 2 ^ 4
  warn("Hello")
})
```

```
Error: Hello
```
:::

The function `warning2error` captures an expression which is evaluated by `withCallingHandlers` where you have defined a handler for warning conditions. The handler captures the condition cnd raised by warn which is `structure(list(message = "Hello"), class = c("warning", "condition")`

The function `conditionMessage` is an s3 generic which evaluates to `conditionMessage.condition` which simply accesses `cnd$message` this is then the input to abort which raises an error with the message `"Hello"`

## 8.6.4 Record {-}

:::question
Why are we using `cnd_muffle` here?


```r
catch_cnds <- function(expr) {
  conds <- list()
  add_cond <- function(cnd) {
    conds <<- append(conds, list(cnd))
    cnd_muffle(cnd)
  }
  
  withCallingHandlers(
    message = add_cond,
    warning = add_cond,
    expr
  )
  
  conds
}

catch_cnds({
  inform("a")
  warn("b")
  inform("c")
})
```
:::

If we remove `cnd_muffle` we see that `a`, `b`, and `c` are printed to the console prior to getting the `conds` output. 

:::question
Would it be possible in the second Record example to create a function that doesn't require us to put the `abort` statement at the end, just ignoring it? Or because `abort` is an exiting handler it needs to be last?
:::


```r
catch_cnds <- function(expr) {
  conds <- list()
  add_cond <- function(cnd) {
    conds <<- append(conds, list(cnd))
    cnd_muffle(cnd)
  }
  
  tryCatch(
    error = function(cnd) {
      conds <<- append(conds, list(cnd))
    },
    withCallingHandlers(
      message = add_cond,
      warning = add_cond,
      expr
    )
  )
  
  conds
}

catch_cnds({
  abort("a")
  inform("b")
  warn("c")
})
```

I'm not positive, but I don't think so without mucking around in the C code. You "can" using try instead of `tryCatch`, but I can't think of a way to have it let you try each line in your passed in expression for example

:::question
What is `signal` and what is it doing here?


```r
log <- function(message, level = c("info", "error", "fatal")) {
  # if we remove match.arg and just use level
  # the signal returns infoerrorfatal as a single string
  # we need match.arg to find the selected level
  # and it defaults to the first if none are selected
  level <- match.arg(level)
  signal(message, "log", level = level)
}
```
:::

Signal is a general function that calls abort, inform  or warn. It has the same signature as those functions except for the class argument that is necessary for signal but NULL by default for each of the others


```r
signal <- function(message, class, ..., .subclass) {
  if (!missing(.subclass)) {
    deprecate_subclass(.subclass)
  }
  message <- collapse_cnd_message(message)
  cnd <- cnd(class, ..., message = message)
  cnd_signal(cnd)
}
```

:::question
> If you create a condition object by hand, and signal it with signalCondition(), cnd_muffle() will not work. Instead you need to call it with a muffle restart defined, like this: `withRestarts(signalCondition(cond), muffle = function() NULL)`

Where does this code go given the prior example? 
:::

We would replace the code `cnd_muffle(cnd)`:


```r
ignore_log_levels <- function(expr, levels) {
  withCallingHandlers(
    log = function(cnd) {
      if (cnd$level %in% levels) {
        # cnd_muffle(cnd)
        withRestarts(signalCondition(cnd), muffle = function() NULL)
      }
    },
    expr
  )
}

record_log(ignore_log_levels(log("Hello"), "warning"))
```

```
[info] "Hello"
```


## 8.6.6.2 Exercises {-}

:::question
> Calling handlers are called in the context of the call that signaled the condition. Exiting handlers are called in the context of the call to tryCatch().

What exactly does this mean? tryCatch evaluates what we were calling the protected code first and calling handlers execute the handling code first? Can we make a simple example?
:::

- `tryCatch` is a project manager who oversees everything and then personally hands over the end product
- `withCallingHandlers` writes some procedures/guidelines and assumes everyone has enough information to get their jobs done

Comparing:


```r
f <- function() g()
g <- function() h()
h <- function() message("!")

withCallingHandlers(f(), message = function(cnd) {
  lobstr::cst()
  cnd_muffle(cnd)
})
```

```
##      █
##   1. ├─base::withCallingHandlers(...)
##   2. ├─global::f()
##   3. │ └─global::g()
##   4. │   └─global::h()
##   5. │     └─base::message("!")
##   6. │       ├─base::withRestarts(...)
##   7. │       │ └─base:::withOneRestart(expr, restarts[[1L]])
##   8. │       │   └─base:::doWithOneRestart(return(expr), restart)
##   9. │       └─base::signalCondition(cond)
##  10. └─(function (cnd) ...
##  11.   └─lobstr::cst()
```

`withCallingHandlers` is run to completion before `f` is called/put onto the stack. While `f` is in progress, `g` needs to be called so `g` is put on top of the stack, then `h` etc. Eventually they're all completed and taken off the stack (in reverse order). Then the handler `(function (cnd) ...` is called

While


```r
tryCatch(f(), message = function(cnd) lobstr::cst())
```

```
##     █
##  1. └─base::tryCatch(f(), message = function(cnd) lobstr::cst())
##  2.   └─base:::tryCatchList(expr, classes, parentenv, handlers)
##  3.     └─base:::tryCatchOne(expr, names, parentenv, handlers[[1L]])
##  4.       └─value[[3L]](cond)
##  5.         └─lobstr::cst()
```

`tryCatch` is still on the stack when the handler is called i.e. value, `tryCatchOne`, `tryCatchList` and `tryCatch` are all still in line to be completed


Calling handlers are called in the context of the call that signaled the condition, in this case,`f()`. So the message handler returns a value to the environment where `f()` is a meaningful call. Exiting handlers are called in the context of the call to `tryCatch()`. The exiting handler returns to an ongoing `tryCatch()` so it can do whatever it needs to do.

## 8.6.6.4 Exercises {-}

:::question
> There’s no way to break out of the function because we’re capturing the interrupt that you’d usually use!

What does this mean? You can't stop the function if you set an `interrupt` argument inside a `tryCatch`?
:::

That's exactly it - this was a warning not to use `inturrupt` in your functions!ß

## Slides {-}

:::question
What environment(s) these restarts are called within, or if that even applies or matters
:::

Note: for this example I set my Environment panel in Rstudio to "Manual Refresh Only" (the curly arrow menu) while running this to make sure it wasn't doing anything to confuse me.


```r
expensive_function <- function(x,
                               # warning print the warning and send us to browser
                               warning = function(w) { print(paste('warning:', w ));  browser() },
                               # error print the error and send us to browser
                               error=function(e) { print(paste('e:',e )); browser()} ) {
  print(paste("big expensive step we don't want to repeat for x:",x))
  z <- x  # the "expensive operation"
  print("Main function caller_env:")
  print(rlang::caller_env())
  print("Main function current_env:")
  print(rlang::current_env())
  print("Main function parent:")
  print(rlang::env_parent(rlang::current_env(), 1))
  repeat
  # second function on z that isn't expensive but could potentially error
  withRestarts(
    withRestarts(
      withCallingHandlers(
        {
          print("withCallingHandlers caller_env:")
          print(rlang::caller_env())
          print("withCallingHandlers current_env:")
          print(rlang::current_env())
          print("withCallingHandlers parent:")
          print(rlang::env_parent(rlang::current_env(), 1))
          print(paste("attempt cheap operation for z:",z))
          return(log(z))
        },
        warning = warning,
        error = error
      ),
      force_positive = function() {
        z <<- -z
        print("force_positive caller_env:")
        print(rlang::caller_env())
        print("force_positive current_env:")
        print(rlang::current_env())
        print("force_positive parent:")
        print(rlang::env_parent(rlang::current_env(), 1))
      }
    ),
    set_to_one = function() {z <<- 1}
  )
}
expensive_function(-1)
```

You can run it yourself (and then `invokeRestart("force_positive")`) to see the results, but to summarize:

- The `withCallingHandlers` part is executing in exactly the same environment as the function.
- The `force_positive` restart is executing in its own new environment. 
- The parent of that environment is the execution environment of the main function.

:::TODO
The `caller_env` for `force_positive`, though, is still a bit of a mystery. Some further poking found that its grandparent is the base package's namespace, but I don't grok why. Maybe because it's the `browser()` environment? Is that a thing?
:::

:::question
Are there any default restarts include in base R so that you could `invokeRestart("XXX")` or is the restart always user defined?
:::

From the warning documentation: 

> While a warning is being processed, a `muffleWarning` restart is available. If this restart is invoked with `invokeRestart`, then warning returns immediately.

We can also use the `computeRestarts` function which lists all available "default" restart functions:


```r
computeRestarts()
```

```
[[1]]
<restart: abort >
```

It seems `computeRestarts()` is able to find `abort` even without `{rlang}` attached! Which means it surely would be able to find some function from the base packages if one existed. But it does not, so that leads me to believe that they aren't any beyond `muffleWarning`. it seems, in general, you need to specify a function name for `invokeRestart()`

:::question
What environment(s) these restarts are called within, or if that even applies or matters
:::

Given this little example:


```r
# low level function
# if text isn't correct then abort with class malformed_text
is_correct <- function(text) {
  print('parent in low: '); print(env_parent())
  print('current in low: '); print(env_parent())
  if (text != "CORRECT") {
    msg <- paste0(text, " needs to be 'CORRECT'")
    abort(
      "malformed_text",
      message = msg,
      text = text
    )
  }
  return(text)
}
# medium level function
# apply low level function to all text in a list
# if it doesn't pass give it the restart skip_text
# which will change that entry to NA
replace_not_correct <- function(all_text) {
  # f <- function(x) { print(current_env()); is_correct(x) }
  lapply(all_text, function(text) {
    withRestarts(
      # f(text),
      { print('parent in mid: ') ; print(env_parent()); print('current in mid: '); print(current_env()); is_correct(text) },
      skip_text = function(e){ NA;  print('parent in mid skip: '); print(env_parent()); print('current in mid skip: '); print(current_env())}
    )
  })
}
# res <- replace_not_correct(list('A', 'B', 'C'))
# res <- replace_not_correct(list('CORRECT', 'A'))
# res
# high level function
# if you have an error of type malformed_text, 
# use the restart from the midlevel function
analyze_text <- function(all_text) {
  withCallingHandlers(
    malformed_text = function(e) invokeRestart("skip_text"),
    lapply(all_text, replace_not_correct)
  )
}
analyze_text(list("CORRECT", "NOT", "CORRECT"))
```

```
## [1] "parent in mid: "
## <environment: 0x7f9f84a14438>
## [1] "current in mid: "
## <environment: 0x7f9f84a102d0>
## [1] "parent in low: "
## <environment: R_GlobalEnv>
## [1] "current in low: "
## <environment: R_GlobalEnv>
## [1] "parent in mid: "
## <environment: 0x7f9f854c4d90>
## [1] "current in mid: "
## <environment: 0x7f9f8a2431f8>
## [1] "parent in low: "
## <environment: R_GlobalEnv>
## [1] "current in low: "
## <environment: R_GlobalEnv>
## [1] "parent in mid skip: "
## <environment: 0x7f9f8a2431f8>
## [1] "current in mid skip: "
## <environment: 0x7f9f8b1faf20>
## [1] "parent in mid: "
## <environment: 0x7f9f8b202240>
## [1] "current in mid: "
## <environment: 0x7f9f8b205938>
## [1] "parent in low: "
## <environment: R_GlobalEnv>
## [1] "current in low: "
## <environment: R_GlobalEnv>
```

```
## [[1]]
## [[1]][[1]]
## [1] "CORRECT"
## 
## 
## [[2]]
## [[2]][[1]]
## <environment: 0x7f9f8b1faf20>
## 
## 
## [[3]]
## [[3]][[1]]
## [1] "CORRECT"
```

So, the parent environment of the handler (is that the right term?) called skip_text in the mid-level function is the environment of the expr part of withRestarts (i.e. the first parameter), also in the mid-level function.

:::question
Are there any default restarts include in base R so that you could `invokeRestart("XXX")` or is the restart always user defined?
:::

From the warning documentation: 

> While a warning is being processed, a `muffleWarning` restart is available. If this restart is invoked with `invokeRestart`, then warning returns immediately.

We can also use the `computeRestarts` function which lists all available "default" restart functions:


```r
computeRestarts()
```

```
[[1]]
<restart: abort >
```

It seems `computeRestarts()` is able to find `abort` even without `{rlang}` attached! Which means it surely would be able to find some function from the base packages if one existed. But it does not, so that leads me to believe that they aren't any beyond `muffleWarning`. it seems, in general, you need to specify a function name for `invokeRestart()`

:::question
Let's revisit my example from the talk: can we build on this to use tidyeval so that the user can write `beer_states %>% beer_mean(state)` [I think we need to use `.data` and note how state is given as an object so we need to use tidyeval to suppress it's evaluation...]
:::


```r
beer_states <- readr::read_csv(
  'https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-31/beer_states.csv')

beer_mean <- function(.data, x) {
  
  column_name <- deparse(substitute(x))

  msg <- glue::glue("Can't calculate mean, {column_name} is not numeric")
  
  if (!is.numeric(.data[[column_name]])) {
    abort(
      message = msg,
      arg = column_name,
      data = .data
    )
  } else {
    mean(which(!is.na(.data[[column_name]])[.data[[column_name]]]))
  }
}

beer_states %>% beer_mean(barrels)
```

```
[1] 806.4551
```
