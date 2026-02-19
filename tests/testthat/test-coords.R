describe("to_coords", {
  it("returns empty data frame for empty input", {
    result <- to_coords(list(), 1)
    expect_s3_class(result, "data.frame")
    expect_equal(nrow(result), 0)
    expect_named(result, c(".long", ".lat", ".subid", ".id", ".poly", ".order"))
  })

  it("converts geometry to coordinate data frame", {
    atlas_df <- as.data.frame(dk())
    geom <- atlas_df$geometry[[1]]
    result <- to_coords(geom, 1)
    expect_s3_class(result, "data.frame")
    expect_true(nrow(result) > 0)
    expect_named(result, c(".long", ".lat", ".subid", ".id", ".poly", ".order"))
  })
})

describe("coords2sf", {
  atlas_df <- as.data.frame(dk())
  coords <- sf2coords(atlas_df)
  geo <- unnest(coords, ggseg)

  it("works with coordinate data", {
    result <- coords2sf(geo)
    expect_s3_class(result, "sf")
  })

  it("respects vertex_size_limits minimum", {
    result <- coords2sf(geo, vertex_size_limits = c(100, NA))
    expect_s3_class(result, "sf")
  })

  it("respects vertex_size_limits maximum", {
    result <- coords2sf(geo, vertex_size_limits = c(NA, 5000))
    expect_s3_class(result, "sf")
  })

  it("respects both vertex_size_limits", {
    result <- coords2sf(geo, vertex_size_limits = c(5, 50000))
    expect_s3_class(result, "sf")
  })
})

describe("sf2coords", {
  it("converts sf data to coords format", {
    result <- sf2coords(dk()$data$sf)
    expect_true("ggseg" %in% names(result))
    expect_type(result$ggseg, "list")
    expect_true(length(result$ggseg) == nrow(dk()$data$sf))
  })

  it("removes geometry column", {
    result <- sf2coords(dk()$data$sf)
    expect_false("geometry" %in% names(result))
  })
})
