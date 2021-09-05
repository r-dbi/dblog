# output

    Code
      safe_deparse(list(foo = "bar"))
    Output
      structure(list("bar"), .Names = "foo")
    Code
      safe_deparse(list(`
      ` = 1))
    Output
      structure(list(1), .Names = "\n")
    Code
      safe_deparse(list(`\n` = 1))
    Output
      structure(list(1), .Names = "\n")
    Code
      safe_deparse(rlang::set_names(list(1), ""))
    Output
      structure(list(1), .Names = "")

