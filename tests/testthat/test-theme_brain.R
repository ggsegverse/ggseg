describe("theme_brain", {
  p <- ggplot() + geom_brain(atlas = dk, show.legend = FALSE)

  it("returns a ggplot theme", {
    expect_s3_class(theme_brain(), "theme")
  })

  it("applies to a plot", {
    result <- p + theme_brain()
    expect_s3_class(result, "gg")
  })

  it("accepts custom text size and family", {
    th <- theme_brain(text.size = 16, text.family = "sans")
    expect_s3_class(th, "theme")
  })

  it("has blank axis ticks", {
    th <- theme_brain()
    expect_s3_class(th$axis.ticks, "element_blank")
  })
})

describe("theme_darkbrain", {
  it("returns a ggplot theme", {
    expect_s3_class(theme_darkbrain(), "theme")
  })

  it("has black plot background", {
    th <- theme_darkbrain()
    expect_equal(th$plot.background$fill, "black")
  })

  it("accepts custom text size and family", {
    th <- theme_darkbrain(text.size = 8, text.family = "sans")
    expect_s3_class(th, "theme")
  })
})

describe("theme_custombrain", {
  it("returns a ggplot theme", {
    expect_s3_class(theme_custombrain(), "theme")
  })

  it("uses custom background colour", {
    th <- theme_custombrain(plot.background = "pink")
    expect_equal(th$plot.background$fill, "pink")
  })

  it("uses custom text colour", {
    th <- theme_custombrain(text.colour = "blue")
    expect_equal(th$text$colour, "blue")
  })

  it("accepts all custom parameters", {
    th <- theme_custombrain(
      plot.background = "grey90",
      text.colour = "red",
      text.size = 14,
      text.family = "serif"
    )
    expect_s3_class(th, "theme")
  })
})

describe("theme_brain2", {
  it("returns a ggplot theme", {
    expect_s3_class(theme_brain2(), "theme")
  })

  it("has blank axis text", {
    th <- theme_brain2()
    expect_s3_class(th$axis.text, "element_blank")
  })

  it("accepts custom parameters", {
    th <- theme_brain2(
      plot.background = "grey90",
      text.colour = "navy",
      text.size = 10,
      text.family = "serif"
    )
    expect_s3_class(th, "theme")
  })
})
