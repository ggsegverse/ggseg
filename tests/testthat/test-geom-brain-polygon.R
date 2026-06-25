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
    skip_if_not_installed("sf")
    sf_atlas <- ggseg.formats::as_sf_atlas(dk())
    p <- ggplot2::ggplot() + geom_brain_polygon(atlas = sf_atlas)
    g <- ggplot2::ggplot_build(p)
    expect_gt(nrow(g$data[[1]]), 0)
  })

  it("errors when the atlas has no 2D geometry", {
    no_geom <- atlas_without_2d_geometry()
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

  it("bundles a fixed-aspect default coord so shapes are not stretched", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    p <- ggplot2::ggplot() + geom_brain_polygon(atlas = poly)
    expect_equal(p$coordinates$ratio, 1)
    expect_true(isTRUE(p$coordinates$default))
  })

  it("lets a user coord override the bundled one without warning", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    p <- ggplot2::ggplot() +
      geom_brain_polygon(atlas = poly) +
      ggplot2::coord_fixed(ratio = 2)
    expect_no_message(ggplot2::ggplot_build(p))
    expect_equal(p$coordinates$ratio, 2)
  })

  it("drops context regions when context = FALSE", {
    poly <- ggseg.formats::as_polygon_atlas(aseg())
    full <- prepare_polygon_atlas(poly)
    no_ctx <- prepare_polygon_atlas(poly, context = FALSE)
    expect_true(any(is.na(full$region)))
    expect_false(any(is.na(no_ctx$region)))
    expect_lt(nrow(no_ctx), nrow(full))
  })

  it("context = FALSE re-gathers views into a tighter extent", {
    poly <- ggseg.formats::as_polygon_atlas(aseg())
    rng <- function(p) {
      diff(range(ggplot2::ggplot_build(p)$data[[1]]$x))
    }
    p_full <- ggplot2::ggplot() + geom_brain_polygon(atlas = poly)
    p_ctx <- ggplot2::ggplot() +
      geom_brain_polygon(atlas = poly, context = FALSE)
    expect_lt(rng(p_ctx), rng(p_full))
  })

  it("zoom = TRUE crops each view onto the focus regions", {
    poly <- ggseg.formats::as_polygon_atlas(aseg())
    p_full <- ggplot2::ggplot() + geom_brain_polygon(atlas = poly)
    p_zoom <- ggplot2::ggplot() +
      geom_brain_polygon(
        atlas = poly,
        position = position_brain_polygon(zoom = TRUE)
      )
    span <- function(p) diff(range(ggplot2::ggplot_build(p)$data[[1]]$x))
    expect_lt(span(p_zoom), span(p_full))
  })

  it("zoom = TRUE focuses on regions present in user data", {
    poly <- ggseg.formats::as_polygon_atlas(aseg())
    regs <- unique(poly$core$region)
    regs <- regs[!is.na(regs)][1:2]
    user <- data.frame(region = regs, measure = c(1, 2))
    p <- ggplot2::ggplot() +
      geom_brain_polygon(
        data = user,
        atlas = poly,
        ggplot2::aes(fill = measure),
        position = position_brain_polygon(zoom = TRUE)
      )
    expect_gt(nrow(ggplot2::ggplot_build(p)$data[[1]]), 0)
  })
})

describe("prepare_polygon_atlas()", {
  it("flattens to row-per-point with the expected columns", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    flat <- prepare_polygon_atlas(poly)
    expect_true(all(
      c("label", "view", "x", "y", ".group", "subgroup", ".feature_id") %in%
        names(flat)
    ))
    expect_gt(nrow(flat), nrow(ggseg.formats::atlas_polygons(poly)))
  })

  it("renames the polygon-ring group to .group to avoid user collision", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    flat <- prepare_polygon_atlas(poly)
    expect_false("group" %in% names(flat))
    expect_true(".group" %in% names(flat))
  })

  it("assigns one .feature_id per (label, view, .group)", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    flat <- prepare_polygon_atlas(poly)
    keys <- unique(paste(flat$label, flat$view, flat$.group, sep = "@@"))
    expect_equal(length(unique(flat$.feature_id)), length(keys))
  })
})

describe("brain_join_polygon() faceting", {
  it("replicates the full atlas per group for grouped data", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    flat <- prepare_polygon_atlas(poly)
    data <- dplyr::group_by(
      data.frame(
        region = c("insula", "precentral"),
        p = c(0.1, 0.2),
        group = c("A", "B"),
        stringsAsFactors = FALSE
      ),
      group
    )
    joined <- brain_join_polygon(data, flat)

    expect_setequal(unique(joined$group), c("A", "B"))
    a <- joined[joined$group == "A", ]
    b <- joined[joined$group == "B", ]
    expect_equal(nrow(a), nrow(flat))
    expect_equal(nrow(b), nrow(flat))
    expect_true(any(!is.na(a$p)))
    expect_true(any(is.na(a$p)))
  })

  it("joins by label when data carries label but not region", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    flat <- prepare_polygon_atlas(poly)
    lbl <- ggseg.formats::atlas_labels(dk())[1]
    data <- data.frame(label = lbl, val = 1.5, stringsAsFactors = FALSE)
    joined <- brain_join_polygon(data, flat)
    expect_true("val" %in% names(joined))
    expect_equal(unique(joined$val[joined$label %in% lbl]), 1.5)
  })

  it("keeps a user column named group without colliding", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    flat <- prepare_polygon_atlas(poly)
    data <- data.frame(
      region = "insula",
      group = "cohort1",
      stringsAsFactors = FALSE
    )
    joined <- brain_join_polygon(data, flat)
    expect_true("group" %in% names(joined))
    expect_equal(unique(joined$group[joined$region %in% "insula"]), "cohort1")
  })
})

describe("geom_brain() backwards-compatibility with sf atlases", {
  # The polygon flip kept geom_brain() working on atlas objects that pre-date
  # the polygon representation: it decomposes their sf geometry on the fly.
  # These lock that in so a later refactor can't silently break it.
  it("renders a legacy ggseg_atlas object", {
    skip_if_not_installed("sf")
    legacy <- ggseg.formats::as_ggseg_atlas(dk())
    expect_s3_class(legacy, "ggseg_atlas")
    p <- ggplot2::ggplot() + geom_brain(atlas = legacy, show.legend = FALSE)
    g <- ggplot2::ggplot_build(p)
    expect_gt(nrow(g$data[[1]]), 0)
  })

  it("renders an sf-only atlas (no polygon representation)", {
    skip_if_not_installed("sf")
    sf_only <- ggseg.formats::as_sf_atlas(dk())
    expect_true(ggseg.formats::is_atlas_sf(sf_only))
    expect_false(ggseg.formats::is_atlas_polygon(sf_only))
    p <- ggplot2::ggplot() + geom_brain(atlas = sf_only, show.legend = FALSE)
    g <- ggplot2::ggplot_build(p)
    expect_gt(nrow(g$data[[1]]), 0)
  })
})
