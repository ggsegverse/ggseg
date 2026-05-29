describe("position_brain_polygon()", {
  it("returns a position_brain_polygon_spec object", {
    spec <- position_brain_polygon()
    expect_s3_class(spec, "position_brain_polygon_spec")
    expect_equal(spec$position, "horizontal")
    expect_null(spec$nrow)
    expect_null(spec$ncol)
    expect_null(spec$views)
  })

  it("captures formula positions", {
    spec <- position_brain_polygon(hemi ~ view)
    expect_s3_class(spec, "position_brain_polygon_spec")
    expect_s3_class(spec$position, "formula")
  })

  it("default horizontal layout produces a single row of views", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    flat <- prepare_polygon_atlas(poly, position = position_brain_polygon())
    bbox <- attr(flat, "polygon_bbox")
    expect_true(!is.null(bbox))
    expect_gt(bbox["xmax"] - bbox["xmin"], bbox["ymax"] - bbox["ymin"])
  })

  it("vertical layout produces a single column of views", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    flat <- prepare_polygon_atlas(
      poly,
      position = position_brain_polygon("vertical")
    )
    bbox <- attr(flat, "polygon_bbox")
    expect_gt(bbox["ymax"] - bbox["ymin"], bbox["xmax"] - bbox["xmin"])
  })

  it("formula layout `hemi ~ view` produces a grid", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    flat <- prepare_polygon_atlas(
      poly,
      position = position_brain_polygon(hemi ~ view)
    )
    bbox <- attr(flat, "polygon_bbox")
    expect_true(!is.null(bbox))
    expect_true(all(is.finite(bbox)))
  })
})

describe("flat-coord helpers", {
  it("bbox_flat returns named numeric of length 4", {
    df <- data.frame(x = c(0, 1, 2), y = c(0, 1, 2))
    b <- bbox_flat(df)
    expect_named(b, c("xmin", "ymin", "xmax", "ymax"))
    expect_equal(unname(b), c(0, 0, 2, 2))
  })

  it("gather_flat shifts bbox to origin", {
    df <- data.frame(x = c(10, 12, 14), y = c(20, 22, 24))
    out <- gather_flat(df)
    expect_equal(min(out$x), 0)
    expect_equal(min(out$y), 0)
  })

  it("center_view_flat preserves width/height while shifting position", {
    df <- data.frame(x = c(0, 4), y = c(0, 2))
    out <- center_view_flat(df, c(10, 10), c(100, 100))
    expect_equal(diff(range(out$x)), 4)
    expect_equal(diff(range(out$y)), 2)
    expect_gt(min(out$x), 100)
  })
})

describe("geom_brain_polygon() with position", {
  it("renders with default horizontal position", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    p <- ggplot2::ggplot() + geom_brain_polygon(atlas = poly)
    g <- ggplot2::ggplot_build(p)
    expect_true(all(is.finite(range(g$data[[1]]$x))))
  })

  it("renders with formula position", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    p <- ggplot2::ggplot() +
      geom_brain_polygon(
        atlas = poly,
        position = position_brain_polygon(hemi ~ view)
      )
    g <- ggplot2::ggplot_build(p)
    expect_true(all(is.finite(range(g$data[[1]]$x))))
    expect_true(all(is.finite(range(g$data[[1]]$y))))
  })

  it("renders with grid (nrow/ncol) position", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    p <- ggplot2::ggplot() +
      geom_brain_polygon(
        atlas = poly,
        position = position_brain_polygon(nrow = 2)
      )
    g <- ggplot2::ggplot_build(p)
    expect_true(all(is.finite(range(g$data[[1]]$y))))
  })
})
