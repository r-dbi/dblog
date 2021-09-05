safe_deparse <- function(x, width = getOption("width")) {
  out <- deparse(x, width.cutoff = width, backtick = TRUE)
  same <- tryCatch(
    identical(x, parse(text = out)[[1]]),
    error = function(e) FALSE
  )
  if (same) {
    return(glue::as_glue(out))
  }

  # Workaround for weird names like "" and "\n":
  glue::as_glue(deparse(
    x, width.cutoff = width, backtick = TRUE,
    control = c("keepNA", "keepInteger", "showAttributes")
  ))
}

expect_deparse <- function(x) {
  if (is.call(x)) {
    testthat::expect_identical(parse(text = safe_deparse(x))[[1]], x)
  } else {
    testthat::expect_identical(eval(parse(text = safe_deparse(x))[[1]]), x)
  }
}
