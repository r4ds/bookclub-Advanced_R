# Debugging

## 22.3 Lazy evaluation {-}

:::question
`rlang::last_trace()` in the example doesn't show anything informative, really. What is this function and when is it helpful?
:::

:::TODO
:::

## 22.4.1 broswer {-}

:::question
Can we create a video or gif using `browser`?
:::

:::TODO
:::

## 22.4.2.1 Breakpoints {-}

:::question
> There are a few unusual situations in which breakpoints will not work

What are these fringe situations?
:::

:::TODO
:::

:::question
Can we create a video or gif using `breakpoints`?
:::

:::TODO
:::


## 22.4.2.2 `recover`

:::question
Can we create a video or gif using `recover`?
:::

:::TODO
:::

## 22.4.2.3 debug {-}

:::question
Can we create a video or gif using `debug`?
:::

:::TODO
:::

:::question
Can we create a video or gif using `utils::setBreakpoint`?
:::

:::TODO
:::

## 22.5 Non-interactive debugging {-}

:::question
> Sometimes `callr::r(f, list(1, 2))` can be useful;
 
What is this? When is it useful?
:::
 
:::TODO
:::
 
## 22.5.1 `dump.frames` {-}
 
:::question
Can we run this chunk, maybe also making a gif?

```r
 # In batch R process ----
dump_and_quit <- function() {
  # Save debugging info to file last.dump.rda
  dump.frames(to.file = TRUE)
  # Quit R with error status
  q(status = 1)
}
options(error = dump_and_quit)

# In a later interactive session ----
load("last.dump.rda")
debugger()
```
:::
 
:::TODO
:::
