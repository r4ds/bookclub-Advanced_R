# ----------------------------
# Function to get formals 
# from the user provided function
# function by: Jon Harmon
# ----------------------------

library(magrittr)

get_all_formals <- function(func) {
  # If the function is passed in as a function, get its name.
  func <- rlang::as_name(rlang::enquo(func))
  if (sloop::is_s3_generic(func)) {
    known_methods <- sloop::s3_methods_generic(func) %>% 
      purrr::pmap_chr(~paste(..1, ..2, sep = "."))
    all_formals <- purrr::map(known_methods, sloop::s3_get_method) %>% 
      purrr::map(formalArgs) %>% 
      unlist() %>% 
      unique()
    all_formals
  } else {
    formalArgs(func)
  }
}
get_all_formals("mean")
get_all_formals(mean)

input <- list()
input$mean <- "mean"
get_all_formals(!!input$mean)
