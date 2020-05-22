expensive_function <- function(x,
                            # warning print the warning and send us to browser
                            warning = function(w) { print(paste('warning:', w ));  browser() },
                            # error print the error and send us to browser
                            error=function(e) { print(paste('e:',e )); browser()} ) {

    print(paste("big expensive step we don't want to repeat for x:",x))

    z <- x  # the "expensive operation"

    # second function on z that isn't expensive but could potentially error
      withRestarts(
        withRestarts(
                  withCallingHandlers(
                         {
                             print(paste("attempt cheap operation for z:",z))
                            return(log(z))
                         },
                      warning = warning,
                      error = error
                   ),
                 force_positive = function() {z <<- -z}
                 ),
             set_to_one = function() {z <<- 1}
        )
}


expensive_function(-2)
auto_expensive_function(-2)

auto_expensive_function = function(x) {
  expensive_function(x,
                     warning=function(w) {invokeRestart("force_positive")},
                     error=function(e) {invokeRestart("set_to_one")})
}
