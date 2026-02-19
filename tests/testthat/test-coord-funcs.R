describe("squish_position", {
  it("adjusts right hemisphere positions", {
    atlas_df <- as.data.frame(dk())
    coords <- sf2coords(atlas_df)
    geo <- unnest(coords, ggseg)
    result <- squish_position(geo, "left")
    expect_s3_class(result, "data.frame")
    expect_true(".long" %in% names(result))
  })
})

describe("stack_brain", {
  it("warns when type is unknown", {
    atlas_df <- as.data.frame(dk())
    coords <- sf2coords(atlas_df)
    geo <- unnest(coords, ggseg)
    geo$type <- "unknown"
    expect_warning(
      stack_brain(geo),
      "type.*not set"
    )
  })

  it("stacks cortical atlas", {
    atlas_df <- as.data.frame(dk())
    coords <- sf2coords(atlas_df)
    geo <- unnest(coords, ggseg)
    result <- stack_brain(geo)
    expect_s3_class(result, "data.frame")
  })

  it("stacks subcortical atlas", {
    atlas_df <- as.data.frame(aseg())
    coords <- sf2coords(atlas_df)
    geo <- unnest(coords, ggseg)
    result <- stack_brain(geo)
    expect_s3_class(result, "data.frame")
  })
})

describe("calc_stack", {
  it("returns summary with sd column", {
    atlas_df <- as.data.frame(dk())
    coords <- sf2coords(atlas_df)
    geo <- unnest(coords, ggseg)
    stack <- group_by(geo, hemi, view)
    result <- calc_stack(stack)
    expect_true("sd" %in% names(result))
    expect_true(".lat_max" %in% names(result))
  })
})
