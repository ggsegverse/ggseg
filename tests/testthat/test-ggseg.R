dt <- dplyr::tibble(
  region = c(
    "transverse temporal",
    "insula",
    "precentral",
    "superior parietal"
  ),
  p = c(.05, 1, .03, .07)
)

context("ggseg")
test_that("Check that ggseg is working", {
  expect_is(ggseg(), c("gg", "ggplot"))

  expect_doppelganger(
    "ggseg dk fill region",
    ggseg(dt, mapping = aes(fill = region))
  )

  expect_doppelganger("ggseg dk fill p", ggseg(dt, mapping = aes(fill = p)))

  expect_error(ggseg(dk), "given as '.data'")

  p <- expect_warning(
    ggseg(
      .data = dplyr::mutate(dt, region = gsub("pre", "pre ", region)),
      mapping = aes(fill = p)
    ),
    "Some data not merged properly"
  )

  expect_doppelganger("ggseg dk warning", p)

  expect_doppelganger(
    "ggseg dk left noscales",
    ggseg(hemisphere = "left", adapt_scales = FALSE)
  )
  expect_doppelganger(
    "ggseg dk left scales",
    ggseg(hemisphere = "left", adapt_scales = TRUE)
  )
  expect_doppelganger(
    "ggseg dk right scales",
    ggseg(hemisphere = "right", adapt_scales = TRUE)
  )
  expect_doppelganger(
    "ggseg dk lateral scales",
    ggseg(view = "lateral", adapt_scales = TRUE)
  )
  expect_doppelganger(
    "ggseg dk medial scales",
    ggseg(view = "medial", adapt_scales = TRUE)
  )
})

test_that("Check that plotting non ggseg_atlas-class tries conversion", {
  atlas <- unnest(as_ggseg_atlas(dk), ggseg)
  p <- ggseg(atlas = atlas)

  expect_doppelganger("ggseg dk atlas converted", p)
})

test_that("Check brain stacking", {
  expect_error(ggseg(position = "rr"), "should be one of")

  expect_doppelganger("ggseg dk stack", ggseg(position = "stack"))

  expect_doppelganger("ggseg dk stacked", ggseg(position = "stacked"))

  expect_doppelganger("ggseg dk disperse", ggseg(position = "disperse"))

  expect_doppelganger("ggseg dk dispersed", ggseg(position = "dispersed"))

  expect_doppelganger(
    "ggseg aseg stacked",
    ggseg(atlas = aseg, position = "stacked")
  )
})

test_that("ggseg works with character atlas name", {
  p <- ggseg(atlas = "dk")
  expect_s3_class(p, "gg")
})
