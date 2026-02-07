test_that("brain atlas plots work", {
  set.seed(1234)
  expect_doppelganger("brain atlas dk plot", plot(dk))
  expect_doppelganger(
    "brain atlas dk plot noleg",
    plot(dk, show.legend = FALSE)
  )
  expect_doppelganger(
    "brain atlas dk plot position",
    plot(dk, position = position_brain(hemi ~ view))
  )
  #
  #   expect_doppelganger("brain atlas aseg plot",
  #                       plot(aseg))

  k <- dk
  k$data$sf <- NULL
  expect_error(plot(k), "cannot be plotted")
})
