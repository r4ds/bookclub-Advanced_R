# Trade-Offs

:::question
Can we make a class using `S3`, `S4`, and `R6` so we can easily directly compare the three, and their generics and methods?
:::

### Using our example from the S4 Chapter:


```r
setClass("Person", 
  slots = c(
    name = "character", 
    age = "numeric"
  )
)

setGeneric("age", function(x) standardGeneric("age"))
setGeneric("age<-", function(x, value) standardGeneric("age<-"))

setMethod("age", "Person", function(x) x@age)
setMethod("age<-", "Person", function(x, value) {
  x@age <- value
  x
})

john <- new("Person", name = "John Smith", age = 12)
age(john)
```

```
[1] 12
```

A generic is a function that will dispatch differently based on the class it is applied to. Above we apply the `age` generic to `Person` using `setMethod` but we could create an `age` method that behaves differently for another class, like dogs (which will add 7 to the supplied age)


```r
setClass("Person", slots = c(name = "character",age = "numeric"))

setGeneric("age", function(x) standardGeneric("age"))
setGeneric("age<-", function(x, value) standardGeneric("age<-"))

setMethod("age", "Person", function(x) x@age)
setMethod("age<-", "Person", function(x, value) {
  x@age <- value
  x
})

setClass("Dog", slots = c(name = "character",  age = "numeric"))

# You want the age generic to automatically return 7x the slot in human years
setMethod("age", "Dog", function(x) {x@age*7} ) 
setMethod("age<-", "Dog", function(x, value) {
  x@age <- value
  x
})


spot <- new("Dog", name = "Spot Smith", age = 12)
age(spot)
```

### We can do this with S3: {-}


```r
johnny <- structure(
  list(name = "Johnny Smith",
       age = 12),
  class = "s3_human")

stripe <- structure(
  list(name = "Stripe Smith",
       age = 12),
  class = "s3_dog")

s3_age <- function(x){UseMethod("s3_age")}
s3_age.s3_dog <- function(x){x$age*7}
s3_age.s3_human <- function(x){x$age}

s3_age(johnny)
```

```
## [1] 12
```


```r
s3_age(stripe)
```

```
## [1] 84
```

#### And R6 {-}


```r
Person <- R6Class("Person", list(
  name = NULL,
  age = NULL,
  initialize = function(name, age = NA) {
    stopifnot(is.character(name), length(name) == 1)
    stopifnot(is.numeric(age), length(age) == 1)
    self$name <- name
    self$age <- age
  }
))

john <- Person$new(name = "John Smith", age = 12)
john$age
```

```
[1] 12
```


```r
Dog <- R6Class(
  "Dog",
  inherit = Person,
  public = list(
  initialize = function(name, age = NA) {
    super$initialize(name,age)
    self$age <- age * 7
  }
))
spot <- Dog$new(name = "Spot Smith", age = 12) 
spot$age
```
```
[1] 84
```

