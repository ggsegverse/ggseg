test_that("Check that scales are working", {
  dk2 <- as_ggseg_atlas(dk)
  expect_equal(class(adapt_scales(unnest(dk2, ggseg))), "list")

  aseg2 <- as_ggseg_atlas(aseg)
  expect_equal(class(adapt_scales(unnest(aseg2, ggseg))), "list")
})
