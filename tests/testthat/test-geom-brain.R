describe("geom_brain", {
  it("works with basic atlas", {
    p <- ggplot2::ggplot() +
      geom_brain(atlas = dk)
    expect_s3_class(p, "gg")
  })

  it("warns when deprecated side argument is used", {
    expect_warning(
      ggplot2::ggplot() +
        geom_brain(atlas = dk, side = "lateral"),
      "side.*deprecated"
    )
  })

  it("uses side value for view when view is NULL", {
    expect_warning(
      p <- ggplot2::ggplot() +
        geom_brain(atlas = dk, side = "lateral"),
      "side.*deprecated"
    )
    expect_s3_class(p, "gg")
  })

  it("filters by hemisphere", {
    p <- ggplot2::ggplot() +
      geom_brain(atlas = dk, hemi = "left")
    expect_s3_class(p, "gg")
  })

  it("filters by view", {
    p <- ggplot2::ggplot() +
      geom_brain(atlas = dk, view = "lateral")
    expect_s3_class(p, "gg")
  })

  it("works with position_brain", {
    p <- ggplot2::ggplot() +
      geom_brain(atlas = dk, position = position_brain(hemi ~ view))
    expect_s3_class(p, "gg")
  })

  it("works with aesthetic mapping", {
    p <- ggplot2::ggplot() +
      geom_brain(atlas = dk, mapping = ggplot2::aes(fill = region))
    expect_s3_class(p, "gg")
  })
})

describe("GeomBrain", {
  it("exists as ggproto object", {
    expect_s3_class(GeomBrain, "Geom")
  })

  it("has default aesthetics", {
    expect_true("default_aes" %in% names(GeomBrain))
  })

  it("has draw_panel method", {
    expect_true("draw_panel" %in% names(GeomBrain))
  })

  it("has draw_key method", {
    expect_true("draw_key" %in% names(GeomBrain))
  })
})
