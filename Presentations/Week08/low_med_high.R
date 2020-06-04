library(tibble)
library(rlang)
dummy1 <- tibble(
  a = 1:10,
  b = c( letters[1:3], letters[2:6], letters[4:5])
)

dummy1
#low level function
simple_mean <- function(x) {
  #detecting of a problem
  if(!is.numeric(x)){ #if x is not numeric
    #create condition
    rlang::abort(
      "categorical_column",  #class of condition
      message = "Not sure what to do with categorical column", #message to signal error
      x = x  #metadata
    )
  }
  cat("Returning from simple mean()\n")
  return(mean(x[which(!is.na(x))]))
}
#work out
simple_mean(dummy1$a)
simple_mean(dummy1$b) #takes you to debugger
#use restart to just get the length of categorical column
#restart in mod-level code
mean_count <- function(y){

  as_count <- withRestarts( #establish restart
    simple_mean(y) ,
    #create code that recovers from errors in restart categorical_column_restart
    #restart name describes its action
    categorical_column_restart = function(z) {
      plyr::count(z) #length(z)
    }
    #choosing this restart later in condition handler, will invoke it automatically
    #here you can define various restarts for other recoveries for
    #condition handler to choose from
  )
  cat("Returning from mean_count()\n")
  return(as_count)
}
mean_count(dummy1$a)
mean_count(dummy1$b) #takes you to debugger still
#condition handlers for invoking a restart
#condition handlers in high-level code

mean_or_count <- function(z){
  as_mean_or_count <- withCallingHandlers(
    #call mean or count function
    mean_count(z),

    #and if error occurs
    #function that invokes restart
    error = function(err){
      #and the error is a 'categorical column error'

      if (inherits(err, "categorical_column")){
        #if object err's class atrribute inherits from class of
        #condition "categorical_column"
        #invoke the restarts called categorical_column_restart
        invokeRestart("categorical_column_restart",
                      #finds restart and invoke it with parameter
                      err$x #argument to pass to restart
        )
      } else {
        #otherwise re-raise the error
        stop(err)
      }
    }
  )
  cat("Returning from mean_or_count()\n")
  return(as_mean_or_count)
}
mean_or_count(dummy1$a)
mean_or_count(dummy1$b)
