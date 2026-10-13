describe("brain_join() without sf", {
  it("returns sf geometry built through the ggseg.formats seam", {
    # The atlas is polygon-backed, so as.data.frame() hands back an sf frame
    # built with sfheaders. dplyr cannot carry an sfc column without sf
    # ("All columns in a tibble must be vectors"), so the join runs on the
    # attribute table and the geometry is reattached afterwards.
    data <- data.frame(region = c("precentral", "postcentral"), v = 1:2)

    result <- suppressMessages(brain_join(data, ggseg.formats::dk()))

    expect_s3_class(result, "sf")
    expect_s3_class(result$geometry, "sfc")
    expect_identical(attr(result, "sf_column"), "geometry")
    expect_identical(nrow(result), length(result$geometry))
  })

  it("puts the geometry column last, as st_as_sf() did", {
    data <- data.frame(region = "precentral", v = 1L)

    result <- suppressMessages(brain_join(data, ggseg.formats::dk()))

    expect_identical(names(result)[length(names(result))], "geometry")
  })

  it("carries geometry through a grouped join, which repeats atlas rows", {
    data <- dplyr::group_by(
      data.frame(
        region = c("precentral", "precentral", "postcentral"),
        g = c("a", "b", "a"),
        v = 1:3
      ),
      g
    )

    result <- suppressMessages(brain_join(data, ggseg.formats::dk()))

    expect_s3_class(result$geometry, "sfc")
    expect_identical(nrow(result), length(result$geometry))
  })
})
