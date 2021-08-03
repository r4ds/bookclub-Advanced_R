# ADVR CH21 CODE
# 08/03/2021

#### Escaping-------

html <- function(x) structure(x, class = "advr_html")

print.advr_html <- function(x, ...) {
  out <- paste0("<HTML> ", x)
  cat(paste(strwrap(out), collapse = "\n"), "\n", sep = "")
}


html(c("hello cohort 5!", "blah"))


escape <- function(x) UseMethod("escape")

escape.character <- function(x) {
  x <- gsub("&", "&amp;", x)
  x <- gsub("<", "&lt;", x)
  x <- gsub(">", "&gt;", x)
  
  html(x)
}

escape.advr_html <- function(x) x

#### cheking ESCAPE works ------

escape("This is some text.")
#> <HTML> This is some text.
escape("x > 1 & y < 2")
#> <HTML> x &gt; 1 &amp; y &lt; 2

# Double escaping is not a problem
escape(escape("This is some text. 1 > 2"))
#> <HTML> This is some text. 1 &gt; 2

# And text we know is HTML doesn't get escaped.
escape(html("<hr />"))
#> <HTML> <hr />


# example of list2()

numeric <- function(...) {
  # browser()
  dots <- list2(...)
  num <- as.numeric(dots)
  set_names(num, names(dots))
}

x <- numeric(1, 2, 3)
names(x)

y <- numeric(a = 1, b = 2, c = 3)
names(y)

# !!! takes a list of expressions and inserts them at the location of the !!!
numeric(1, !!!y)

# we need the := operation because R’s grammar does not allow expressions as argument names
numeric(1, !!!y, !!"f":= 4)

#### PARTITION NAMED AND UNNAMED ELEMENTS -------

dots_partition <- function(...) {
  dots <- list2(...)
  
  if (is.null(names(dots))) {
    is_named <- rep(FALSE, length(dots))
  } else {
    is_named <- names(dots) != ""
  }
  
  list(
    # named args are like class, id
    named = dots[is_named],
    # unnamed are like texts
    unnamed = dots[!is_named]
  )
}

#### GENERALISE TAG FUNC-------

tag <- function(tag) {
  new_function(
    # not entirely sure what this line does
    # i think the ... are getting assigned to a missing named argument
    # the name is ... and the argument is missing
    exprs(... = ),
    expr({
      dots <- dots_partition(...)
      attribs <- html_attributes(dots$named)
      children <- map_chr(dots$unnamed, escape)
      
      html(paste0(
        # !! is included here so that it is evaluated otherwise you would have 
        # "paste0" in your returned tag
        # so eval the internal pastes first- open the tag with its attrs <>
        # then included any children
        # then close the tag
        !!paste0("<", tag), attribs, ">",
        paste(children, collapse = ""),
        !!paste0("</", tag, ">")
      ))
    }),
    # the last thing returned is the the env
    # making the environment of this function be global?
    caller_env()
  )
}
tag("b")

### VOID TAGS-------

void_tag <- function(tag) {
  new_function(
    exprs(... = ),
    expr({
      dots <- dots_partition(...)
      if (length(dots$unnamed) > 0) {
        abort(!!paste0("<", tag, "> must not have unnamed arguments"))
      }
      attribs <- html_attributes(dots$named)
      
      html(paste0(!!paste0("<", tag), attribs, " />"))
    }),
    caller_env()
  )
}

img <- void_tag("img")
img
#> function (...) 
#> {
#>     dots <- dots_partition(...)
#>     if (length(dots$unnamed) > 0) {
#>         abort("<img> must not have unnamed arguments")
#>     }
#>     attribs <- html_attributes(dots$named)
#>     html(paste0("<img", attribs, " />"))
#> }
img(src = "myimage.png", width = 100, height = 100)
#> <HTML> <img src='myimage.png' width='100' height='100' />