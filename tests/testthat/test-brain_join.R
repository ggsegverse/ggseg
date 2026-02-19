describe("brain_join", {
  some_data <- data.frame(
    region = c(
      "transverse temporal",
      "insula",
      "precentral",
      "superior parietal",
      "transverse temporal",
      "insula",
      "precentral",
      "superior parietal"
    ),
    p = seq(0.1, 0.8, by = 0.1),
    grp = c(rep("G1", 4), rep("G2", 4)),
    stringsAsFactors = FALSE
  )

  it("joins ungrouped data to atlas", {
    single <- some_data[some_data$grp == "G1", ]
    expect_message(
      result <- brain_join(single, dk()),
      "Merging"
    )
    expect_s3_class(result, "sf")
  })

  it("auto-detects join columns", {
    single <- some_data[some_data$grp == "G1", ]
    expect_message(
      brain_join(single, dk()),
      "region"
    )
  })

  it("respects explicit by argument", {
    single <- some_data[some_data$grp == "G1", ]
    result <- brain_join(single, dk(), by = "region")
    expect_s3_class(result, "sf")
  })

  it("joins grouped data producing one atlas per group", {
    grouped <- group_by(some_data, grp)
    expect_message(
      result <- brain_join(grouped, dk()),
      "Merging"
    )
    expect_s3_class(result, "sf")
    expect_true("grp" %in% names(result))
    expect_equal(sort(unique(result$grp)), c("G1", "G2"))
    atlas_rows <- nrow(as.data.frame(dk()))
    rows_per_grp <- tapply(result$grp, result$grp, length)
    expect_true(all(rows_per_grp == atlas_rows))
  })

  it("warns when data has unmatched regions", {
    bad_data <- data.frame(
      region = c("not a real region"),
      p = 0.5,
      stringsAsFactors = FALSE
    )
    expect_warning(
      expect_message(brain_join(bad_data, dk())),
      "not merged"
    )
  })

  it("returns tibble when atlas has no geometry", {
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
