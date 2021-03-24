# as used in shinyobjects

x <- expr(output <- reactive(1 + 1))

lobstr::ast(!!x)


update_expressions <- function(x) {
  code_as_call <- as.call(x)
  get_symbol <- code_as_call[[2]]
  
  get_identity <- code_as_call[[3]]
  get_fn      <- get_identity[[1]]
  get_formals <- get_identity[[2]]

  if (get_fn == as.symbol("reactiveValues")) {
    code_as_call[[3]][[1]] <- as.symbol("list")
    return(as.expression(code_as_call))
  }
  
  if (get_fn == as.symbol("reactive")) {
    new_expr <- expr(!!get_symbol <- function() { !!get_formals })
    return(new_expr)
  }

  return(x)
}

# debugonce(update_expressions)
update_expressions(
  expr(output <- reactiveValues(1,1))
)

update_expressions(
  expr(output <- reactive(plot(1,1)))
)

update_expressions(
  expr(output <- reactive(1 + 1))
)
