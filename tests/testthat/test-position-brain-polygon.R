describe("position_brain_polygon()", {
  it("returns a position_brain_polygon_spec object", {
    spec <- position_brain_polygon()
    expect_s3_class(spec, "position_brain_polygon_spec")
    expect_identical(spec$position, "horizontal")
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
    expect_false(is.null(bbox))
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
    expect_false(is.null(bbox))
    expect_true(all(is.finite(bbox)))
  })
})

describe("flat-coord helpers", {
  it("bbox_flat returns named numeric of length 4", {
    df <- data.frame(x = c(0, 1, 2), y = c(0, 1, 2))
    b <- bbox_flat(df)
    expect_named(b, c("xmin", "ymin", "xmax", "ymax"))
    expect_identical(unname(b), c(0, 0, 2, 2))
  })
})

describe("geom_brain_polygon() with position", {
  it("renders with default horizontal position", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    p <- ggplot2::ggplot() + geom_brain_polygon(atlas = poly)
    g <- muffle_breaking_warnings(ggplot2::ggplot_build(p))
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
    expect_identical(range(sq[, 1]), c(2, 8))
    expect_identical(range(sq[, 2]), c(2, 8))
  })

  it("leaves a fully-contained ring's extent unchanged", {
    tri <- clip_ring_to_box(c(3, 5, 4), c(3, 3, 5), c(0, 10, 0, 10))
    expect_identical(nrow(tri), 3L)
  })

  it("drops a ring fully outside the box", {
    out <- clip_ring_to_box(c(20, 22, 21), c(20, 20, 22), c(0, 10, 0, 10))
    expect_identical(nrow(out), 0L)
  })

  it("fills the box when the ring contains it", {
    big <- clip_ring_to_box(
      c(-5, 15, 15, -5),
      c(-5, -5, 15, 15),
      c(0, 10, 0, 10)
    )
    expect_identical(range(big[, 1]), c(0, 10))
    expect_identical(range(big[, 2]), c(0, 10))
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
    focus <- c("thalamus", "putamen")
    expect_identical(resolve_zoom_focus(focus, NULL, aseg()), focus)
  })

  it("returns explicit labels unchanged, without warning", {
    focus <- ggseg.formats::atlas_labels(aseg())[1:2]
    expect_identical(resolve_zoom_focus(focus, NULL, aseg()), focus)
  })

  it("prefers labels in data when zoom = TRUE", {
    atlas <- aseg()
    labs <- ggseg.formats::atlas_labels(atlas)[1:2]
    data <- data.frame(label = labs, region = c("thalamus proper", "caudate"))
    expect_setequal(resolve_zoom_focus(TRUE, data, atlas), labs)
  })

  it("uses regions present in data when zoom = TRUE and there is no label", {
    atlas <- aseg()
    data <- data.frame(region = c("thalamus proper", "caudate"))
    expect_setequal(
      resolve_zoom_focus(TRUE, data, atlas),
      c("thalamus proper", "caudate")
    )
  })

  it("falls back to the atlas labels when zoom = TRUE and no data", {
    atlas <- aseg()
    labelled <- unique(ggseg.formats::atlas_labels(atlas))
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

describe("as_polygon_position", {
  it("passes a polygon position spec through unchanged", {
    spec <- position_brain_polygon("vertical")
    expect_identical(as_polygon_position(spec), spec)
  })

  it("keeps NULL as the no-layout marker", {
    expect_null(as_polygon_position(NULL))
  })

  it("coerces a layout string", {
    out <- as_polygon_position("vertical")
    expect_true(is_polygon_position(out))
    expect_identical(out$position, "vertical")
  })

  it("coerces a layout formula", {
    out <- as_polygon_position(hemi ~ view)
    expect_true(is_polygon_position(out))
    expect_identical(out$position, hemi ~ view)
  })

  it("treats 'identity' as the opt-out from any layout", {
    expect_null(as_polygon_position("identity"))
  })

  it("errors on an unsupported position value", {
    expect_error(as_polygon_position(1L), "must be a")
    expect_error(as_polygon_position("nonsense"), "must be a")
    expect_error(as_polygon_position(c("vertical", "horizontal")), "must be a")
    expect_error(
      as_polygon_position(ggplot2::position_identity()),
      "must be a"
    )
  })
})


describe("warn_unmatched_focus()", {
  it("names focus regions the atlas does not have", {
    expect_warning(
      resolve_zoom_focus("Thalamus Proper", NULL, aseg()),
      class = "ggseg_unmatched_focus"
    )
  })

  it("suggests the closest real region", {
    expect_warning(
      resolve_zoom_focus("Thalamus Proper", NULL, aseg()),
      "thalamus"
    )
  })

  it("is silent when every focus region matches", {
    expect_no_warning(resolve_zoom_focus("thalamus", NULL, aseg()))
  })
})

describe("in_focus()", {
  it("matches a focus key against label or region", {
    df <- data.frame(
      label = c("lh_a", "lh_b", NA),
      region = c("a", "b", NA)
    )
    expect_identical(in_focus(df, "lh_a"), c(TRUE, FALSE, FALSE))
    expect_identical(in_focus(df, "b"), c(FALSE, TRUE, FALSE))
    expect_identical(in_focus(df, c("lh_a", "b")), c(TRUE, TRUE, FALSE))
    expect_identical(in_focus(df, "nope"), c(FALSE, FALSE, FALSE))
  })

  it("works when only one of the two columns is present", {
    expect_true(in_focus(data.frame(label = "lh_a"), "lh_a"))
    expect_true(in_focus(data.frame(region = "a"), "a"))
    expect_false(in_focus(data.frame(label = "lh_a"), "a"))
  })
})

describe("zoom focus by label end to end", {
  it("crops to a label-named focus", {
    focus <- ggseg.formats::atlas_labels(dk())[1]
    zoomed <- prepare_polygon_atlas(
      dk(),
      position = position_brain_polygon(zoom = focus),
      focus = focus
    )
    full <- prepare_polygon_atlas(dk())
    expect_lt(diff(range(zoomed$x)), diff(range(full$x)))
  })
})
