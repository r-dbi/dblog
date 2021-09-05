test_that("output", {
  expect_snapshot({
    safe_deparse(list(foo = "bar"))
    safe_deparse(list("\n" = 1))
    safe_deparse(list("\\n" = 1))
    safe_deparse(rlang::set_names(list(1), ""))
  })
})
