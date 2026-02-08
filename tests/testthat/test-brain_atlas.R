describe("brain_atlas class", {
  it("dk is a brain_atlas", {
    expect_true(is_brain_atlas(dk))
    expect_s3_class(dk, "brain_atlas")
  })

  it("as_brain_atlas round-trips", {
    result <- as_brain_atlas(dk)
    expect_s3_class(result, "brain_atlas")
  })

  it("as.data.frame returns sf data", {
    df <- as.data.frame(dk)
    expect_true(inherits(df, "data.frame"))
    expect_true("geometry" %in% names(df))
    expect_true("region" %in% names(df))
    expect_true("hemi" %in% names(df))
    expect_true("view" %in% names(df))
  })

  it("print method works", {
    output <- capture.output(print(dk))
    expect_true(length(output) > 0)
  })

  it("brain_regions returns character vector", {
    regions <- brain_regions(dk)
    expect_type(regions, "character")
    expect_true(length(regions) > 0)
  })

  it("brain_labels returns character vector", {
    labels <- brain_labels(dk)
    expect_type(labels, "character")
    expect_true(length(labels) > 0)
  })

  it("brain_views returns character vector", {
    views <- brain_views(dk)
    expect_type(views, "character")
    expect_true(all(c("lateral", "medial") %in% views))
  })

  it("aseg atlas works", {
    expect_true(is_brain_atlas(aseg))
    df <- as.data.frame(aseg)
    expect_true(inherits(df, "data.frame"))
  })
})
