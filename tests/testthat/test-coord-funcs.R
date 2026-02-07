test_that("squish_position works", {
  expect_warning(
    geo <- as_ggseg_atlas(dk),
    "deprecated"
  )
  geo <- unnest(geo, ggseg)

  result <- squish_position(geo, "left")
  expect_s3_class(result, "data.frame")
})

test_that("stack_brain warns when type is unknown", {
  expect_warning(
    geo <- as_ggseg_atlas(dk),
    "deprecated"
  )
  geo <- unnest(geo, ggseg)
  geo$type <- "unknown"

  expect_warning(
    ggseg:::stack_brain(geo),
    "type.*not set"
  )
})
