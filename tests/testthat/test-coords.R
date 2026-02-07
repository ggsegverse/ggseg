describe("to_coords", {
  it("returns empty data frame for empty input", {
    result <- ggseg:::to_coords(list(), 1)
    expect_s3_class(result, "data.frame")
    expect_equal(nrow(result), 0)
    expect_named(result, c(".long", ".lat", ".subid", ".id", ".poly", ".order"))
  })
})

describe("coords2sf", {
  it("works with basic ggseg atlas data", {
    expect_warning(
      atlas <- as_ggseg_atlas(dk),
      "deprecated"
    )
    atlas <- tidyr::unnest(atlas, ggseg)
    result <- ggseg:::coords2sf(atlas)
    expect_s3_class(result, "sf")
  })

  it("respects vertex_size_limits minimum", {
    expect_warning(
      atlas <- as_ggseg_atlas(dk),
      "deprecated"
    )
    atlas <- tidyr::unnest(atlas, ggseg)
    result <- ggseg:::coords2sf(atlas, vertex_size_limits = c(100, NA))
    expect_s3_class(result, "sf")
  })

  it("respects vertex_size_limits maximum", {
    expect_warning(
      atlas <- as_ggseg_atlas(dk),
      "deprecated"
    )
    atlas <- tidyr::unnest(atlas, ggseg)
    result <- ggseg:::coords2sf(atlas, vertex_size_limits = c(NA, 5000))
    expect_s3_class(result, "sf")
  })

  it("respects both vertex_size_limits", {
    expect_warning(
      atlas <- as_ggseg_atlas(dk),
      "deprecated"
    )
    atlas <- tidyr::unnest(atlas, ggseg)
    result <- ggseg:::coords2sf(atlas, vertex_size_limits = c(5, 50000))
    expect_s3_class(result, "sf")
  })
})

describe("sf2coords", {
  it("converts sf data to coords format", {
    result <- ggseg:::sf2coords(dk$data$sf)
    expect_true("ggseg" %in% names(result))
    expect_type(result$ggseg, "list")
  })
})
