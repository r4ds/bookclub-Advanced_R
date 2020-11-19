# Given this function, use `trace()` to add a `browser()` statement before the
# stop
fun <- function() {
  for (i in 1:10000) {
    if (i == 9876)
      stop("Ohno!")
  }
}
