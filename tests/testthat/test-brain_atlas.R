test_that("as_brain-atlas", {
  expect_equal(
    class(as_brain_atlas(dk)),
    "brain_atlas"
  )
  expect_true(is_brain_atlas(dk))

  ka <- as_ggseg_atlas(dk)
  expect_s3_class(ka, "ggseg_atlas")
  ks <- as_brain_atlas(ka)
  expect_s3_class(ks, "brain_atlas")
})

test_that("brain-atlas changes", {
  df <- as.data.frame(dk)
  expect_true(inherits(df, "data.frame"))

  expect_true(inherits(
    as_ggseg_atlas(dk),
    "ggseg_atlas"
  ))
})
