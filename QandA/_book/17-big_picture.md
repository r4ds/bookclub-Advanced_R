# 17 Big Picture



## 17.8 Quosures {-}

:::question
What is meant here by "data mask"
:::

:::TODO
:::

:::question
I love the idea of creating templates then shoving in code using `!!` can we create a template that inserts a filtering statement into our tidypipeline?


```r
# this is my template
iris %>%
  ggplot2::ggplot() +
  ggplot2::aes(x = Sepal.Length, y = Sepal.Width) + 
  ggplot2::geom_point()
# somehow insert this into the template at line 2
dplyr::filter(Sepal.Length > 4.5) %>%
# to create something prettier than 
if (x == 2) {
  iris %>%
    dplyr::filter(Sepal.Length > 4.5) %>%
    ggplot2::ggplot() +
    ggplot2::aes(x = Sepal.Length, y = Sepal.Width) + 
    ggplot2::geom_point()
} else {
  iris %>%
    ggplot2::ggplot() +
    ggplot2::aes(x = Sepal.Length, y = Sepal.Width) + 
    ggplot2::geom_point()
}
```
:::


```r
customizable_iris <- function(pipeline_insertion = NULL){
  dt <- rlang::expr(iris)
  pi <- rlang::enexpr(pipeline_insertion)
  if (!rlang::is_null(pi))
    dt <- rlang::expr(!!dt %>% !!pi)
  rlang::expr(
    !!dt %>%  
      ggplot2::ggplot() +
      ggplot2::aes(x = Sepal.Length, y = Sepal.Width) + 
      ggplot2::geom_point()
  )
}
(x <- customizable_iris(dplyr::filter(Sepal.Length > 5)))
```

```
## iris %>% dplyr::filter(Sepal.Length > 5) %>% ggplot2::ggplot() + 
##     ggplot2::aes(x = Sepal.Length, y = Sepal.Width) + ggplot2::geom_point()
```

```r
rlang::eval_bare(x)
```

![](17-big_picture_files/figure-latex/unnamed-chunk-3-1.pdf)<!-- --> 

Any valid r code can be converted into an expression or list of expressions, and expressions can be patched together using this unquoting (forcing) procedure. 

Probably best thoguht of in terms of the tree structure, by replacing one node with another expression:


```r
lobstr::ast(a + b)
```

```
## █─`+` 
## ├─a 
## └─b
```


```r
b <- rlang::expr(x + y)
lobstr::ast(!!b)
```

```
## █─`+` 
## ├─x 
## └─y
```

```r
lobstr::ast(a + !!b)
```

```
## █─`+` 
## ├─a 
## └─█─`+` 
##   ├─x 
##   └─y
```

so the forcing operation is kind of like performing surgery on the AST, where you cut out one node (the thing being forced) and replacing it with some other code.
