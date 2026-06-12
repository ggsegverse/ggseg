describe("gap", {
  it("returns midpoint of range", {
    expect_identical(gap(c(0, 10)), 5)
    expect_identical(gap(c(-5, 5)), 0)
    expect_identical(gap(c(3, 3)), 3)
  })
})

describe("coord_brain", {
  it("returns a fixed-aspect ggplot2 coord", {
    co <- coord_brain()
    expect_s3_class(co, "Coord")
    expect_equal(co$ratio, 1)
  })

  it("registers as a default coord so it can be overridden silently", {
    co <- coord_brain()
    expect_true(isTRUE(co$default))
  })

  it("does not clip by default", {
    expect_identical(coord_brain()$clip, "off")
  })

  it("honours a custom ratio and clip", {
    co <- coord_brain(ratio = 2, clip = "on")
    expect_equal(co$ratio, 2)
    expect_identical(co$clip, "on")
  })

  it("does not warn when a user coord is added after it", {
    p <- ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) +
      ggplot2::geom_point() +
      coord_brain() +
      ggplot2::coord_cartesian()
    expect_no_message(ggplot2::ggplot_build(p))
  })
})
