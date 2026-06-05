describe("geom_brain_polygon()", {
  it("renders a polygon atlas without requiring sf in the data path", {
    skip_if_not_installed("vdiffr")
    poly <- ggseg.formats::as_polygon_atlas(dk())
    p <- ggplot2::ggplot() + geom_brain_polygon(atlas = poly)
    g <- ggplot2::ggplot_build(p)
    expect_true(length(g$data) >= 1)
    expect_gt(nrow(g$data[[1]]), 0)
  })

  it("renders an sf-backed atlas via on-the-fly polygon conversion", {
    sf_atlas <- ggseg.formats::as_sf_atlas(dk())
    p <- ggplot2::ggplot() + geom_brain_polygon(atlas = sf_atlas)
    g <- ggplot2::ggplot_build(p)
    expect_gt(nrow(g$data[[1]]), 0)
  })

  it("errors when the atlas has no 2D geometry", {
    no_geom <- dk()
    no_geom$data$geom <- NULL
    no_geom$data$sf <- NULL
    no_geom$data$polygons <- NULL
    expect_error(
      ggplot2::ggplot() + geom_brain_polygon(atlas = no_geom),
      "no 2D geometry"
    )
  })

  it("filters by view", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    p <- ggplot2::ggplot() +
      geom_brain_polygon(atlas = poly, view = "lateral")
    g <- ggplot2::ggplot_build(p)
    expect_true(all(g$data[[1]]$view == "lateral" | is.na(g$data[[1]]$view)))
  })

  it("rejects invalid views with a clear error", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    expect_error(
      ggplot2::ggplot() + geom_brain_polygon(atlas = poly, view = "nope"),
      "Invalid view"
    )
  })

  it("filters by hemi", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    p <- ggplot2::ggplot() +
      geom_brain_polygon(atlas = poly, hemi = "left")
    g <- ggplot2::ggplot_build(p)
    hemis <- unique(g$data[[1]]$hemi)
    expect_true(all(hemis %in% c("left", NA)))
  })

  it("joins user data on region", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    regs <- unique(poly$core$region)
    regs <- regs[!is.na(regs)]
    user <- data.frame(
      region = regs,
      measure = seq_along(regs) / length(regs)
    )
    p <- ggplot2::ggplot() +
      geom_brain_polygon(
        data = user,
        atlas = poly,
        ggplot2::aes(fill = measure)
      )
    g <- ggplot2::ggplot_build(p)
    expect_true(
      "measure" %in% names(g$data[[1]]) || "fill" %in% names(g$data[[1]])
    )
  })

  it("works on subcortical aseg via the polygon path", {
    poly_aseg <- ggseg.formats::as_polygon_atlas(aseg())
    p <- ggplot2::ggplot() + geom_brain_polygon(atlas = poly_aseg)
    g <- ggplot2::ggplot_build(p)
    expect_gt(nrow(g$data[[1]]), 0)
  })
})

describe("prepare_polygon_atlas()", {
  it("flattens to row-per-point with the expected columns", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    flat <- prepare_polygon_atlas(poly)
    expect_true(all(
      c("label", "view", "x", "y", "group", "subgroup", ".feature_id") %in%
        names(flat)
    ))
    expect_gt(nrow(flat), nrow(ggseg.formats::atlas_polygons(poly)))
  })

  it("assigns one .feature_id per (label, view, group)", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    flat <- prepare_polygon_atlas(poly)
    keys <- unique(paste(flat$label, flat$view, flat$group, sep = "@@"))
    expect_equal(length(unique(flat$.feature_id)), length(keys))
  })
})
