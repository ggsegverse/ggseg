describe("plot.brain_atlas", {
  it("plots dk atlas", {
    set.seed(1234)
    expect_doppelganger("brain atlas dk plot", plot(dk))
  })

  it("plots dk atlas without legend", {
    set.seed(1234)
    expect_doppelganger(
      "brain atlas dk plot noleg",
      plot(dk, show.legend = FALSE)
    )
  })

  it("plots aseg atlas", {
    set.seed(1234)
    expect_doppelganger("brain atlas aseg plot", plot(aseg))
  })

  it("plots tracula atlas", {
    set.seed(1234)
    expect_doppelganger("brain atlas tracula plot", plot(tracula))
  })

  it("errors when atlas has no geometry", {
    k <- dk
    k$data$sf <- NULL
    expect_error(plot(k), "cannot be plotted")
  })

  it("returns a ggplot object", {
    p <- plot(dk)
    expect_s3_class(p, "gg")
  })

  it("includes atlas name in title", {
    p <- plot(dk)
    expect_true(grepl("dk", p$labels$title))
  })

  it("applies palette when available", {
    p <- plot(dk)
    has_fill_scale <- any(vapply(
      p$scales$scales,
      function(s) "fill" %in% s$aesthetics,
      logical(1)
    ))
    expect_true(has_fill_scale)
  })
})

describe("position_brain visual", {
  it("dk default horizontal", {
    expect_doppelganger(
      "dk default horizontal",
      ggplot() + geom_brain(atlas = dk, show.legend = FALSE)
    )
  })

  it("dk hemi ~ view", {
    expect_doppelganger(
      "dk hemi ~ view",
      ggplot() +
        geom_brain(
          atlas = dk,
          position = position_brain(hemi ~ view),
          show.legend = FALSE
        )
    )
  })

  it("dk view ~ hemi", {
    expect_doppelganger(
      "dk view ~ hemi",
      ggplot() +
        geom_brain(
          atlas = dk,
          position = position_brain(view ~ hemi),
          show.legend = FALSE
        )
    )
  })

  it("dk hemi + view ~ .", {
    expect_doppelganger(
      "dk rows hemi+view",
      ggplot() +
        geom_brain(
          atlas = dk,
          position = position_brain(hemi + view ~ .),
          show.legend = FALSE
        )
    )
  })

  it("dk . ~ hemi + view", {
    expect_doppelganger(
      "dk cols hemi+view",
      ggplot() +
        geom_brain(
          atlas = dk,
          position = position_brain(. ~ hemi + view),
          show.legend = FALSE
        )
    )
  })

  it("dk vertical", {
    expect_doppelganger(
      "dk vertical",
      ggplot() +
        geom_brain(
          atlas = dk,
          position = position_brain("vertical"),
          show.legend = FALSE
        )
    )
  })

  it("dk character view order", {
    expect_doppelganger(
      "dk custom view order",
      ggplot() +
        geom_brain(
          atlas = dk,
          position = position_brain(c(
            "right lateral", "right medial",
            "left lateral", "left medial"
          )),
          show.legend = FALSE
        )
    )
  })

  it("aseg default horizontal", {
    expect_doppelganger(
      "aseg default horizontal",
      ggplot() + geom_brain(atlas = aseg, show.legend = FALSE)
    )
  })

  it("aseg vertical", {
    expect_doppelganger(
      "aseg vertical",
      ggplot() +
        geom_brain(
          atlas = aseg,
          position = position_brain("vertical"),
          show.legend = FALSE
        )
    )
  })

  it("aseg nrow 2", {
    expect_doppelganger(
      "aseg nrow 2",
      ggplot() +
        geom_brain(
          atlas = aseg,
          position = position_brain(nrow = 2),
          show.legend = FALSE
        )
    )
  })

  it("aseg ncol 3", {
    expect_doppelganger(
      "aseg ncol 3",
      ggplot() +
        geom_brain(
          atlas = aseg,
          position = position_brain(ncol = 3),
          show.legend = FALSE
        )
    )
  })

  it("aseg type ~ .", {
    expect_doppelganger(
      "aseg type rows",
      ggplot() +
        geom_brain(
          atlas = aseg,
          position = position_brain(type ~ .),
          show.legend = FALSE
        )
    )
  })

  it("tracula default horizontal", {
    expect_doppelganger(
      "tracula default horizontal",
      ggplot() + geom_brain(atlas = tracula, show.legend = FALSE)
    )
  })

  it("tracula vertical", {
    expect_doppelganger(
      "tracula vertical",
      ggplot() +
        geom_brain(
          atlas = tracula,
          position = position_brain("vertical"),
          show.legend = FALSE
        )
    )
  })

  it("tracula nrow 2", {
    expect_doppelganger(
      "tracula nrow 2",
      ggplot() +
        geom_brain(
          atlas = tracula,
          position = position_brain(nrow = 2),
          show.legend = FALSE
        )
    )
  })

  it("tracula ncol 3", {
    expect_doppelganger(
      "tracula ncol 3",
      ggplot() +
        geom_brain(
          atlas = tracula,
          position = position_brain(ncol = 3),
          show.legend = FALSE
        )
    )
  })

  it("tracula type ~ .", {
    expect_doppelganger(
      "tracula type rows",
      ggplot() +
        geom_brain(
          atlas = tracula,
          position = position_brain(type ~ .),
          show.legend = FALSE
        )
    )
  })
})
