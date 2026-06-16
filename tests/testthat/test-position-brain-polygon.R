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

  it("stores zoom and zoom_pad in the spec", {
    spec <- position_brain_polygon(zoom = TRUE, zoom_pad = 0.1)
    expect_true(spec$zoom)
    expect_equal(spec$zoom_pad, 0.1)
  })

  it("defaults zoom off with 5% padding", {
    spec <- position_brain_polygon()
    expect_null(spec$zoom)
    expect_equal(spec$zoom_pad, 0.05)
  })
})

describe("clip_ring_to_box", {
  it("clips a ring that straddles the box to the box bounds", {
    sq <- clip_ring_to_box(c(0, 10, 10, 0), c(0, 0, 10, 10), c(2, 8, 2, 8))
    expect_equal(range(sq[, 1]), c(2, 8))
    expect_equal(range(sq[, 2]), c(2, 8))
  })

  it("leaves a fully-contained ring's extent unchanged", {
    tri <- clip_ring_to_box(c(3, 5, 4), c(3, 3, 5), c(0, 10, 0, 10))
    expect_equal(nrow(tri), 3)
  })

  it("drops a ring fully outside the box", {
    out <- clip_ring_to_box(c(20, 22, 21), c(20, 20, 22), c(0, 10, 0, 10))
    expect_equal(nrow(out), 0)
  })

  it("fills the box when the ring contains it", {
    big <- clip_ring_to_box(
      c(-5, 15, 15, -5),
      c(-5, -5, 15, 15),
      c(0, 10, 0, 10)
    )
    expect_equal(range(big[, 1]), c(0, 10))
    expect_equal(range(big[, 2]), c(0, 10))
  })
})

describe("clip_view_flat", {
  it("clips every ring in a flat view and preserves metadata columns", {
    df <- data.frame(
      x = c(0, 10, 10, 0, 100, 110, 110, 100),
      y = c(0, 0, 10, 10, 0, 0, 10, 10),
      .feature_id = c(1, 1, 1, 1, 2, 2, 2, 2),
      subgroup = 1L,
      region = c(rep("a", 4), rep("b", 4)),
      stringsAsFactors = FALSE
    )
    clipped <- clip_view_flat(df, c(-1, 11, -1, 11))
    expect_true(all(clipped$region == "a"))
    expect_setequal(unique(clipped$.feature_id), 1)
  })
})

describe("resolve_zoom_focus", {
  it("returns NULL when zoom is off", {
    expect_null(resolve_zoom_focus(NULL, NULL, aseg()))
    expect_null(resolve_zoom_focus(FALSE, NULL, aseg()))
  })

  it("returns explicit region names unchanged", {
    expect_equal(resolve_zoom_focus(c("x", "y"), NULL, aseg()), c("x", "y"))
  })

  it("uses regions present in data when zoom = TRUE", {
    atlas <- aseg()
    data <- data.frame(region = c("thalamus proper", "caudate"))
    expect_setequal(
      resolve_zoom_focus(TRUE, data, atlas),
      c("thalamus proper", "caudate")
    )
  })

  it("falls back to labelled atlas regions when zoom = TRUE and no data", {
    atlas <- aseg()
    labelled <- unique(atlas$core$region)
    labelled <- labelled[!is.na(labelled)]
    expect_setequal(resolve_zoom_focus(TRUE, NULL, atlas), labelled)
  })

  it("errors on an unsupported zoom value", {
    expect_error(resolve_zoom_focus(1L, NULL, aseg()), "must be")
  })
})

describe("zoom_views_flat", {
  it("warns and returns input unchanged when no focus regions are present", {
    df <- data.frame(
      x = c(0, 1, 1),
      y = c(0, 0, 1),
      .feature_id = 1L,
      subgroup = 1L,
      region = NA_character_
    )
    expect_warning(
      out <- zoom_views_flat(list(df), focus = "missing"),
      "No focus regions"
    )
    expect_identical(out, list(df))
  })
})
