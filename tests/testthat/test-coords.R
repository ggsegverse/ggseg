describe("to_coords", {
  it("returns empty data frame for empty input", {
    result <- to_coords(list(), 1)
    expect_s3_class(result, "data.frame")
    expect_identical(nrow(result), 0L)
    expect_named(result, c(".long", ".lat", ".subid", ".id", ".poly", ".order"))
  })

  it("converts geometry to coordinate data frame", {
    skip_if_not_installed("sf")
    atlas_df <- as.data.frame(dk())
    geom <- atlas_df$geometry[[1]]
    result <- to_coords(geom, 1)
    expect_s3_class(result, "data.frame")
    expect_gt(nrow(result), 0)
    expect_named(result, c(".long", ".lat", ".subid", ".id", ".poly", ".order"))
  })
})

describe("sf2coords", {
  it("converts sf data to coords format", {
    skip_if_not_installed("sf")
    sf_data <- atlas_sf(dk())
    result <- sf2coords(sf_data)
    expect_true("ggseg" %in% names(result))
    expect_type(result$ggseg, "list")
    expect_length(result$ggseg, nrow(sf_data))
  })

  it("removes geometry column", {
    skip_if_not_installed("sf")
    result <- sf2coords(atlas_sf(dk()))
    expect_false("geometry" %in% names(result))
  })
})
