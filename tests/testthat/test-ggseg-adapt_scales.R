describe("adapt_scales", {
  dk_df <- as.data.frame(dk)
  dk_coords <- sf2coords(dk_df)
  dk_geo <- unnest(dk_coords, ggseg)

  aseg_df <- as.data.frame(aseg)
  aseg_coords <- sf2coords(aseg_df)
  aseg_geo <- unnest(aseg_coords, ggseg)

  it("returns labs scale for cortical atlas", {
    result <- adapt_scales(dk_geo)
    expect_type(result, "list")
    expect_true("y" %in% names(result))
    expect_true("x" %in% names(result))
  })

  it("returns x scale for cortical atlas dispersed", {
    result <- adapt_scales(dk_geo, position = "dispersed", aesthetics = "x")
    expect_type(result, "list")
    expect_true("breaks" %in% names(result))
    expect_true("labels" %in% names(result))
  })

  it("returns y scale for cortical atlas dispersed", {
    result <- adapt_scales(dk_geo, position = "dispersed", aesthetics = "y")
    expect_type(result, "list")
  })

  it("returns labs for cortical atlas stacked", {
    result <- adapt_scales(dk_geo, position = "stacked", aesthetics = "labs")
    expect_type(result, "list")
    expect_true("y" %in% names(result))
    expect_true("x" %in% names(result))
  })

  it("returns x scale for cortical atlas stacked", {
    result <- adapt_scales(dk_geo, position = "stacked", aesthetics = "x")
    expect_type(result, "list")
  })

  it("returns y scale for cortical atlas stacked", {
    result <- adapt_scales(dk_geo, position = "stacked", aesthetics = "y")
    expect_type(result, "list")
  })

  it("returns labs scale for subcortical atlas", {
    result <- adapt_scales(aseg_geo)
    expect_type(result, "list")
  })

  it("returns x scale for subcortical atlas dispersed", {
    result <- adapt_scales(aseg_geo, position = "dispersed", aesthetics = "x")
    expect_type(result, "list")
  })

  it("returns y scale for subcortical atlas stacked", {
    result <- adapt_scales(aseg_geo, position = "stacked", aesthetics = "y")
    expect_type(result, "list")
  })
})
