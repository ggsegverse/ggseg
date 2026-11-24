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

  it("joins only on atlas keys, not every shared column", {
    skip_if_not_installed("sf")
    atlas <- as.data.frame(dk())
    skip_if_not("lobe" %in% names(atlas))
    # `lobe` is shared but is not a join key: treating it as one matched only
    # the regions whose lobe happened to agree, and dropped the rest.
    single <- data.frame(region = regs[1:3], lobe = "frontal", p = 1:3)
    result <- suppressMessages(brain_join(single, dk()))
    expect_identical(nrow(result), nrow(atlas))
    expect_identical(
      sum(!is.na(result$p)),
      sum(atlas$region %in% single$region)
    )
  })

  it("errors when data shares no join key with the atlas", {
    expect_error(
      brain_join(data.frame(lobe = "frontal", p = 1), dk()),
      "no columns in common"
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
