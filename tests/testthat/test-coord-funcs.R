test_that("squish_position works", {
  geo <- as_ggseg_atlas(dk)
  geo <- unnest(geo, ggseg)

  squish_position(geo, "left")
})
