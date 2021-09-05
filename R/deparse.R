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
