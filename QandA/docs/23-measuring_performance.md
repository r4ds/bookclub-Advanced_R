# Measuring performance {-}

## 23.1 Introduction {-}

:::question
Why do we have to create a tempfile here?

```
tmp <- tempfile()
Rprof(tmp, interval = 0.1)
f()
Rprof(NULL)
writeLines(readLines(tmp))
```
:::

:::TODO
:::


## 23.2 Profiling {-}

:::question
What is meant when saying a sampling profiler is "fundamentally stochastic"? Does he mean there's minor variability every time you run the function?
:::

It doesn't give you an exact picture of everything that's there, it only gives you samples every couple seconds


:::question
How does `utils::summaryRprof` and `proftools` differ from `profvis`? What are the pros and cons of each?
:::

:::TODO
:::

## 23.4.2 Exercises {-}

:::question
What is happening here? What does `torture = TRUE` do?
:::

:::TODO
:::

## 23.3 Microbenchmarking {-}

:::question
> a deep understanding of subatomic physics is not very helpful when baking.

...So when is it useful to microbenchmark?
:::

I have seen rcpp use it a lot. Maybe because the change is so profound between c++ and R... There is a Knuth quote at the top of Ch. 24 that gets at why microbenchmarking is useful: "Yet we should not pass up our opportunities in that critical 3%". It's for those very special situations where it can make a huge difference. [but 3% might be too high of an estimate ...probably 0.01% ]

:::question
> You’ll also often see multimodality because your computer is running something else in the background.

What is multimodality and why would running other stuff cause this?
:::

You're using computer resources for a few random iterations.

:::question
`profvis` doesn't work properly with 4.0.... why?
:::

:::TODO
:::

