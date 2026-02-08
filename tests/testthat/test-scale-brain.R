describe("scale_brain", {
  it("returns a scale for fill by default", {
    scale <- scale_brain()
    expect_s3_class(scale, "Scale")
    expect_equal(scale$aesthetics, "fill")
  })

  it("returns a scale for colour", {
    scale <- scale_brain(aesthetics = "colour")
    expect_s3_class(scale, "Scale")
    expect_equal(scale$aesthetics, "colour")
  })

  it("returns a scale for color (aliased to colour)", {
    scale <- scale_brain(aesthetics = "color")
    expect_s3_class(scale, "Scale")
    expect_equal(scale$aesthetics, "colour")
  })

  it("uses custom na.value", {
    scale <- scale_brain(na.value = "red")
    expect_equal(scale$na.value, "red")
  })

  it("accepts atlas name argument", {
    scale <- scale_brain(name = "dk")
    expect_s3_class(scale, "Scale")
  })
})

describe("scale_colour_brain", {
  it("returns a colour scale", {
    scale <- scale_colour_brain()
    expect_s3_class(scale, "Scale")
    expect_equal(scale$aesthetics, "colour")
  })
})

describe("scale_color_brain", {
  it("returns a color scale (aliased to colour)", {
    scale <- scale_color_brain()
    expect_s3_class(scale, "Scale")
    expect_equal(scale$aesthetics, "colour")
  })
})

describe("scale_fill_brain", {
  it("returns a fill scale", {
    scale <- scale_fill_brain()
    expect_s3_class(scale, "Scale")
    expect_equal(scale$aesthetics, "fill")
  })
})

describe("scale_brain2", {
  pal <- c("region1" = "#FF0000", "region2" = "#00FF00")

  it("returns a scale for fill by default with custom palette", {
    scale <- scale_brain2(palette = pal)
    expect_s3_class(scale, "Scale")
    expect_equal(scale$aesthetics, "fill")
  })

  it("returns a scale for colour", {
    scale <- scale_brain2(palette = pal, aesthetics = "colour")
    expect_s3_class(scale, "Scale")
    expect_equal(scale$aesthetics, "colour")
  })

  it("returns a scale for color (aliased to colour)", {
    scale <- scale_brain2(palette = pal, aesthetics = "color")
    expect_s3_class(scale, "Scale")
    expect_equal(scale$aesthetics, "colour")
  })

  it("uses custom na.value", {
    scale <- scale_brain2(palette = pal, na.value = "blue")
    expect_equal(scale$na.value, "blue")
  })
})

describe("scale_colour_brain2", {
  it("returns a colour scale", {
    pal <- c("region1" = "#FF0000")
    scale <- scale_colour_brain2(palette = pal)
    expect_s3_class(scale, "Scale")
    expect_equal(scale$aesthetics, "colour")
  })
})

describe("scale_color_brain2", {
  it("returns a color scale (aliased to colour)", {
    pal <- c("region1" = "#FF0000")
    scale <- scale_color_brain2(palette = pal)
    expect_s3_class(scale, "Scale")
    expect_equal(scale$aesthetics, "colour")
  })
})

describe("scale_fill_brain2", {
  it("returns a fill scale", {
    pal <- c("region1" = "#FF0000")
    scale <- scale_fill_brain2(palette = pal)
    expect_s3_class(scale, "Scale")
    expect_equal(scale$aesthetics, "fill")
  })
})

describe("scale_continous_brain", {
  dk_df <- as.data.frame(dk)
  dk_coords <- sf2coords(dk_df)
  atlas <- unnest(dk_coords, ggseg)

  it("returns y scale by default", {
    scale <- scale_continous_brain(atlas = atlas)
    expect_s3_class(scale, "Scale")
  })

  it("returns x scale", {
    scale <- scale_continous_brain(atlas = atlas, aesthetics = "x")
    expect_s3_class(scale, "Scale")
  })
})

describe("scale_x_brain", {
  it("returns x scale", {
    dk_df <- as.data.frame(dk)
    dk_coords <- sf2coords(dk_df)
    atlas <- unnest(dk_coords, ggseg)
    scale <- scale_x_brain(atlas = atlas)
    expect_s3_class(scale, "Scale")
  })
})

describe("scale_y_brain", {
  it("returns y scale", {
    dk_df <- as.data.frame(dk)
    dk_coords <- sf2coords(dk_df)
    atlas <- unnest(dk_coords, ggseg)
    scale <- scale_y_brain(atlas = atlas)
    expect_s3_class(scale, "Scale")
  })
})

describe("scale_labs_brain", {
  it("returns labs scale", {
    dk_df <- as.data.frame(dk)
    dk_coords <- sf2coords(dk_df)
    atlas <- unnest(dk_coords, ggseg)
    scale <- scale_labs_brain(atlas = atlas)
    expect_s3_class(scale, "gg")
  })
})
