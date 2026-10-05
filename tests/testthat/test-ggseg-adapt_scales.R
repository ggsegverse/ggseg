describe("adapt_scales", {
  dk_geo <- atlas_scale_coords(dk())
  aseg_geo <- atlas_scale_coords(aseg())

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

  it("converts atlas object to data.frame automatically", {
    result <- adapt_scales(dk())
    expect_type(result, "list")
    expect_true("y" %in% names(result))
    expect_true("x" %in% names(result))
  })

  it("converts subcortical atlas object automatically", {
    result <- adapt_scales(aseg(), aesthetics = "x")
    expect_type(result, "list")
    expect_true("breaks" %in% names(result))
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

  it("rejects anything that is not an atlas or a flattened data.frame", {
    expect_error(adapt_scales(list(1, 2)), "must be a")
  })
})


describe("atlas_scale_coords()", {
  it("derives coordinates without the sf path", {
    local_mocked_bindings(
      sf2coords = function(...) stop("the sf coordinate path was used")
    )
    result <- adapt_scales(dk(), position = "dispersed", aesthetics = "x")
    expect_length(result$breaks, 2L)
    expect_false(anyNA(result$breaks))
  })

  it("lets the exported axis scales work without the sf path", {
    local_mocked_bindings(
      sf2coords = function(...) stop("the sf coordinate path was used")
    )
    expect_s3_class(scale_x_brain(atlas = dk()), "ScaleContinuousPosition")
    expect_s3_class(scale_y_brain(atlas = aseg()), "ScaleContinuousPosition")
    expect_type(scale_labs_brain(atlas = tracula()), "list")
  })

  it("reproduces the sf-derived coordinates exactly", {
    skip_if_not_installed("sf")
    for (atlas in list(dk(), aseg(), tracula())) {
      sf_geo <- unnest(sf2coords(as.data.frame(atlas)), ggseg)
      for (position in c("dispersed", "stacked")) {
        for (aesthetics in c("x", "y", "labs")) {
          expect_identical(
            adapt_scales(atlas, position, aesthetics),
            adapt_scales(sf_geo, position, aesthetics)
          )
        }
      }
    }
  })

  it("carries the columns adapt_scales() groups by", {
    flat <- atlas_scale_coords(aseg())
    expect_true(all(c(".long", ".lat", "view", "type") %in% names(flat)))
    expect_identical(unique(flat$type), "subcortical")
  })
})
