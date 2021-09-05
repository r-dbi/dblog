if (require(testthat)) {
  library(dblog)
  test_check("dblog")
} else {
  message("testthat not available.")
}
