describe("brain_join", {
  regs <- sort(unique(ggseg.formats::atlas_regions(dk())))[1:4]
  some_data <- data.frame(
    region = rep(regs, 2),
    p = seq(0.1, 0.8, by = 0.1),
    grp = c(rep("G1", 4), rep("G2", 4)),
    stringsAsFactors = FALSE
  )

  it("joins ungrouped data to atlas", {
    skip_if_not_installed("sf")
    single <- some_data[some_data$grp == "G1", ]
    expect_message(
      result <- brain_join(single, dk()),
      "Merging"
    )
    expect_s3_class(result, "sf")
  })

  it("auto-detects join columns", {
    skip_if_not_installed("sf")
    single <- some_data[some_data$grp == "G1", ]
    expect_message(
      brain_join(single, dk()),
      "region"
    )
  })

  it("respects explicit by argument", {
    skip_if_not_installed("sf")
    single <- some_data[some_data$grp == "G1", ]
    result <- brain_join(single, dk(), by = "region")
    expect_s3_class(result, "sf")
  })

  it("joins grouped data producing one atlas per group", {
    skip_if_not_installed("sf")
    grouped <- group_by(some_data, grp)
    expect_message(
      result <- brain_join(grouped, dk()),
      "Merging"
    )
    expect_s3_class(result, "sf")
    expect_true("grp" %in% names(result))
    expect_identical(sort(unique(result$grp)), c("G1", "G2"))
    atlas_rows <- nrow(as.data.frame(dk()))
    rows_per_grp <- tapply(result$grp, result$grp, length)
    expect_true(all(rows_per_grp == atlas_rows))
  })

  it("warns when data has unmatched regions", {
    skip_if_not_installed("sf")
    bad_data <- data.frame(
      region = "not a real region",
      p = 0.5,
      stringsAsFactors = FALSE
    )
    expect_warning(
      expect_message(brain_join(bad_data, dk())),
      "not merged"
    )
  })

  it("returns tibble when atlas has no geometry", {
    skip_if_not_installed("sf")
    atlas_df <- as.data.frame(dk())
    atlas_df$geometry <- NULL
    single <- some_data[some_data$grp == "G1", ]
    expect_message(
      result <- brain_join(single, atlas_df),
      "Merging"
    )
    expect_s3_class(result, "tbl_df")
  })
})


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
