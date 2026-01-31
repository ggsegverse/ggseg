context("theme-brain")
test_that("Check that themes are working", {
  p <- ggseg(atlas = dk, show.legend = FALSE, mapping = aes(fill = region))

  expect_doppelganger("theme brain", p + theme_brain())

  expect_doppelganger("theme darkbrain", p + theme_darkbrain())

  expect_doppelganger(
    "theme custombrain",
    p + theme_custombrain(text.colour = "blue")
  )

  expect_doppelganger("theme brain2", p + theme_brain2())
})
