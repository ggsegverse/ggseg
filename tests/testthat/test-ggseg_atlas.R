test_that("check that ggseg_atlas is correct", {
  tt <- data.frame(
    .long = double(),
    .lat = double(),
    .id = character(),
    hemi = character(),
    view = character()
  )

  expect_warning(
    expect_error(as_ggseg_atlas(tt)),
    "deprecated"
  )

  tt <- data.frame(
    .long = double(),
    .lat = double(),
    .id = character(),
    .subid = character(),
    region = character(),
    atlas = character(),
    type = character(),
    hemi = character(),
    view = character()
  )
  expect_warning(
    atlas <- as_ggseg_atlas(tt),
    "deprecated"
  )
  expected_names <- c("atlas", "type", "hemi", "view", "region", "ggseg")
  expect_equal(names(atlas), expected_names)
  expect_equal(typeof(atlas$ggseg), "list")

  expect_warning(
    result <- as_ggseg_atlas(dk),
    "deprecated"
  )
  expect_equal(dim(result), c(90, 10))
})

test_that("check that is_ggseg_atlas works", {
  expect_warning(
    dk2 <- as_ggseg_atlas(dk),
    "deprecated"
  )
  expect_warning(
    result <- is_ggseg_atlas(dk2),
    "deprecated"
  )
  expect_true(result)

  dt <- data.frame(
    .long = double(),
    .lat = double(),
    .id = character(),
    area = as.character(),
    hemi = character(),
    view = character()
  )

  expect_warning(
    result <- is_ggseg_atlas(dt),
    "deprecated"
  )
  expect_false(result)
})


test_that("check that as_ggseg_atlas works", {
  expect_warning(
    dk2 <- as_ggseg_atlas(dk),
    "deprecated"
  )
  expect_warning(
    result <- is_ggseg_atlas(dk2),
    "deprecated"
  )
  expect_true(result)

  expect_warning(
    expect_error(as_ggseg_atlas(list()), "Cannot make object of class"),
    "deprecated"
  )

  expect_warning(
    expect_error(as_ggseg_atlas(data.frame()), "Missing necessary columns"),
    "deprecated"
  )

  dt <- data.frame(
    .long = double(),
    .lat = double(),
    .id = character(),
    atlas = character(),
    region = character(),
    .subid = character(),
    type = character(),
    area = character(),
    hemi = character(),
    view = character()
  )
  expect_warning(
    k <- as_ggseg_atlas(dt),
    "deprecated"
  )
  expect_warning(
    result <- is_ggseg_atlas(k),
    "deprecated"
  )
  expect_true(result)

  expect_warning(
    k <- as_ggseg_atlas(dk),
    "deprecated"
  )
  expect_warning(
    k <- as_ggseg_atlas(k),
    "deprecated"
  )
  expect_true(inherits(k, "ggseg_atlas"))
})

test_that("brain-polygon", {
  expect_warning(
    ka <- as_ggseg_atlas(dk),
    "deprecated"
  )

  expect_true(inherits(
    ka$ggseg,
    "brain_polygon"
  ))
  expect_true(is_brain_polygon(ka$ggseg))

  ka <- as.list(ka$ggseg)
  expect_true(inherits(ka, "list"))

  expect_true(inherits(
    as_brain_polygon(ka),
    "brain_polygon"
  ))

  ka <- brain_polygon(ka)
  expect_true(inherits(ka, "brain_polygon"))

  expect_equal(
    capture.output(ka[1]),
    "< p:  1 - v: 10>"
  )
})


test_that("ggseg_atlas S3 methods work", {
  expect_warning(
    dk2 <- as_ggseg_atlas(dk),
    "deprecated"
  )

  expect_doppelganger("ggseg_atlas plot dk", plot(dk2))

  k <- capture.output(dk2)
  expect_equal(k[1], "# ggseg atlas")
})

test_that("as_ggseg_atlas.brain_atlas handles sf data directly", {
  atlas <- dk
  atlas_modified <- atlas
  atlas_modified$data <- atlas_modified$data$sf
  expect_warning(
    result <- as_ggseg_atlas(atlas_modified),
    "deprecated"
  )
  expect_warning(
    is_ggseg <- is_ggseg_atlas(result),
    "deprecated"
  )
  expect_true(is_ggseg)
})

test_that("as_ggseg_atlas.brain_atlas errors when no sf data", {
  atlas <- dk
  atlas_modified <- atlas
  atlas_modified$data <- NULL
  expect_warning(
    expect_error(as_ggseg_atlas(atlas_modified), "no 2D geometry"),
    "deprecated"
  )
})
