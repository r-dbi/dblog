test_that("output", {
  # Can't use expect_snapshot() because it uses deparse() itself

  expect_deparse(list(foo = "bar"))
  expect_deparse(list("\n" = 1))
  expect_deparse(list("\\n" = 1))
  expect_deparse(quote(list("\n" = 1)))
  expect_deparse(quote(list("\\n" = 1)))
  expect_deparse(rlang::set_names(list(1), ""))
})
