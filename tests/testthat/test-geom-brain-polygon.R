describe("geom_brain_polygon()", {
  it("renders a polygon atlas without requiring sf in the data path", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    p <- ggplot2::ggplot() + geom_brain_polygon(atlas = poly)
    g <- muffle_breaking_warnings(ggplot2::ggplot_build(p))
    expect_gte(length(g$data), 1)
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
      ggplot2::ggplot_build(
        ggplot2::ggplot() + geom_brain_polygon(atlas = no_geom)
      ),
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
      ggplot2::ggplot_build(
        ggplot2::ggplot() + geom_brain_polygon(atlas = poly, view = "nope")
      ),
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
    expect_identical(p$coordinates$ratio, 1)
    expect_true(isTRUE(p$coordinates$default))
  })

  it("lets a user coord override the bundled one without warning", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    p <- ggplot2::ggplot() +
      geom_brain_polygon(atlas = poly) +
      ggplot2::coord_fixed(ratio = 2)
    expect_no_message(ggplot2::ggplot_build(p))
    expect_identical(p$coordinates$ratio, 2)
  })

  it("drops context regions when context = FALSE", {
    poly <- ggseg.formats::as_polygon_atlas(aseg())
    full <- prepare_polygon_atlas(poly)
    no_ctx <- prepare_polygon_atlas(poly, context = FALSE)
    expect_true(anyNA(full$region))
    expect_false(anyNA(no_ctx$region))
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
    expect_length(unique(flat$.feature_id), length(keys))
  })
})

describe("warn_unmatched_polygon_data() (ggseg#121)", {
  # The polygon join keeps every atlas polygon via a left join, so a data row
  # that matches no region (a typo, or the fully spelled-out `names` value used
  # where the short `region` key is expected) is silently dropped. The
  # setup_layer warning surfaces the mismatch. StatBrain does the join now; the
  # warning helper is exercised directly plus through a built plot.
  poly <- ggseg.formats::as_polygon_atlas(dk())
  a_region <- sort(unique(ggseg.formats::atlas_regions(dk())))[1]

  it("warns when a data region matches no atlas region", {
    flat <- prepare_polygon_atlas(poly)
    data <- data.frame(region = c(a_region, "notaregion"), p = c(0.9, 0.1))
    expect_warning(
      warn_unmatched_polygon_data(data, flat, "region"),
      "not merged"
    )
  })

  it("names the unmatched value in the message", {
    flat <- prepare_polygon_atlas(poly)
    data <- data.frame(region = c(a_region, "notaregion"), p = c(0.9, 0.1))
    w <- expect_warning(
      warn_unmatched_polygon_data(data, flat, "region"),
      "not merged"
    )
    expect_match(conditionMessage(w), "notaregion")
    expect_no_match(conditionMessage(w), a_region, fixed = TRUE)
  })

  it("stays silent when every data row matches", {
    flat <- prepare_polygon_atlas(poly)
    data <- data.frame(
      region = sort(unique(ggseg.formats::atlas_regions(dk())))[1:2],
      p = c(0.9, 0.1)
    )
    expect_no_warning(warn_unmatched_polygon_data(data, flat, "region"))
  })

  it("matches by label without warning", {
    flat <- prepare_polygon_atlas(poly)
    a_label <- sub(
      "^lh_",
      "",
      sort(unique(ggseg.formats::atlas_labels(dk())))[1]
    )
    data <- data.frame(
      label = paste0(c("lh_", "rh_"), a_label),
      p = c(0.9, 0.9)
    )
    expect_no_warning(warn_unmatched_polygon_data(data, flat, "label"))
  })

  it("surfaces the mismatch through a built plot", {
    data <- data.frame(region = c(a_region, "notaregion"), p = c(0.9, 0.1))
    p <- ggplot2::ggplot(data) +
      geom_brain(atlas = dk(), ggplot2::aes(fill = p))
    expect_warning(ggplot2::ggplot_build(p), "not merged")
  })
})

describe("geom_brain() inherits top-level data and aes (ggseg#158)", {
  # Regression test for ggsegverse/ggseg#158: data and aesthetics set in the
  # top-level ggplot() call were dropped by the eager polygon build, so fill
  # fell back to the region labels instead of the user's mapped values.
  fill_column <- function(p) {
    ggplot2::ggplot_build(p)$data[[1]]$fill
  }

  labelled_values <- function() {
    data.frame(
      label = sort(unique(ggseg.formats::atlas_labels(dk()))),
      value = seq_along(sort(unique(ggseg.formats::atlas_labels(dk()))))
    )
  }

  it("uses a continuous fill mapped in ggplot(), not the region labels", {
    mex <- labelled_values()
    p <- ggplot2::ggplot(mex, ggplot2::aes(fill = value)) +
      geom_brain(atlas = dk()) +
      ggplot2::scale_fill_viridis_c()
    # The bug threw "Discrete value supplied to a continuous scale" at build.
    expect_no_error(fills <- fill_column(p))
    # A continuous scale resolves to many hex colours; unmatched context
    # regions keep the scale's grey na.value.
    expect_gt(length(unique(grep("^#", fills, value = TRUE))), 2)
    # Fill must not fall back to the region labels.
    expect_false(any(
      fills %in% sort(unique(ggseg.formats::atlas_labels(dk())))
    ))
  })

  it("matches the explicit geom-level data= workaround from the issue", {
    mex <- labelled_values()
    inherited <- ggplot2::ggplot(mex, ggplot2::aes(fill = value)) +
      geom_brain(atlas = dk()) +
      ggplot2::scale_fill_viridis_c()
    explicit <- ggplot2::ggplot() +
      geom_brain(data = mex, atlas = dk(), ggplot2::aes(fill = value)) +
      ggplot2::scale_fill_viridis_c()
    expect_identical(fill_column(inherited), fill_column(explicit))
  })

  it("renders grey (not the palette) when no fill is mapped anywhere", {
    # geom_brain() plots your data, so a bare atlas is grey; the palette is
    # opt-in via plot(atlas) or aes(fill = region) + scale_fill_brain().
    p <- ggplot2::ggplot() + geom_brain(atlas = dk())
    expect_setequal(unique(fill_column(p)), "grey")
  })

  it("no longer injects a discrete palette that fights a continuous fill", {
    # Regression: plot-level continuous fill with no user scale used to error
    # "Continuous value supplied to a discrete scale" from the injected palette.
    mex <- labelled_values()
    expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot(mex, ggplot2::aes(fill = value)) +
          geom_brain(atlas = dk())
      )
    )
  })

  it("replicates the atlas per facet for inherited grouped-by-facet data", {
    mex <- rbind(
      cbind(labelled_values(), cohort = "A"),
      cbind(labelled_values(), cohort = "B")
    )
    p <- suppressMessages(
      ggplot2::ggplot(mex, ggplot2::aes(fill = value)) +
        geom_brain(atlas = dk()) +
        ggplot2::facet_wrap(~cohort) +
        ggplot2::scale_fill_viridis_c()
    )
    g <- ggplot2::ggplot_build(p)
    expect_setequal(unique(g$data[[1]]$PANEL), factor(c(1, 2)))
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


describe("geom_brain() outline aesthetics (ggseg#160)", {
  # Regression test for ggsegverse/ggseg#160: the outline colour/linewidth were
  # injected as fixed geom params, which silently overrode a user's
  # aes(colour = ...) / aes(linewidth = ...) mapping. GeomBrain now
  # supplies them through default_aes, which yields to a mapping.
  built <- function(p) ggplot2::ggplot_build(p)$data[[1]]

  outline_data <- function() {
    data.frame(
      region = sort(unique(ggseg.formats::atlas_regions(dk())))[1:3],
      grp = c("a", "b", "c"),
      w = c(0.5, 1.5, 3)
    )
  }

  it("maps aes(colour) to region outlines instead of overriding it", {
    p <- ggplot2::ggplot(outline_data()) +
      geom_brain(atlas = dk(), ggplot2::aes(colour = grp))
    cols <- unique(built(p)$colour)
    expect_gt(length(cols), 1)
    expect_false(all(cols == "grey35"))
  })

  it("maps aes(linewidth) to region outlines instead of overriding it", {
    p <- ggplot2::ggplot(outline_data()) +
      geom_brain(atlas = dk(), ggplot2::aes(linewidth = w))
    expect_gt(length(unique(built(p)$linewidth)), 1)
  })

  it("uses the grey35 / 0.2 defaults when neither mapped nor set", {
    g <- built(ggplot2::ggplot() + geom_brain(atlas = dk()))
    expect_setequal(unique(g$colour), "grey35")
    expect_setequal(unique(g$linewidth), 0.2)
  })

  it("still lets a fixed colour param override the mapping", {
    p <- ggplot2::ggplot(outline_data()) +
      geom_brain(atlas = dk(), ggplot2::aes(colour = grp), colour = "red")
    expect_setequal(unique(built(p)$colour), "red")
  })
})


describe("geom_brain() protects atlas-controlled aesthetics", {
  # x/y/group/subgroup are derived from the atlas geometry. A user mapping for
  # them would corrupt the polygons (e.g. aes(group = region) collapses the
  # per-feature ring grouping), so geom_brain() ignores and warns.
  n_groups <- function(p) {
    length(unique(ggplot2::ggplot_build(p)$data[[1]]$group))
  }

  it("warns and ignores a user-mapped group aesthetic", {
    d <- data.frame(
      region = sort(unique(ggseg.formats::atlas_regions(dk())))[1:2],
      v = c(1, 2)
    )
    baseline <- n_groups(
      ggplot2::ggplot(d) + geom_brain(atlas = dk(), ggplot2::aes(fill = v))
    )
    expect_warning(
      p <- ggplot2::ggplot(d) +
        geom_brain(atlas = dk(), ggplot2::aes(fill = v, group = region)),
      "Ignoring"
    )
    expect_identical(n_groups(p), baseline)
  })

  it("warns listing every reserved aesthetic the user supplied", {
    expect_warning(
      geom_brain(atlas = dk(), ggplot2::aes(x = 1, subgroup = 1)),
      "subgroup"
    )
  })
})


describe("draw order follows the data row order (ggseg#162)", {
  # Regression test for ggsegverse/ggseg#162: GeomPolygon paints features in
  # ascending .feature_id order, so the renderer must let the data row order set
  # that id -- later rows draw on top -- rather than forcing alphabetical order.
  # Users then control overlapping-outline layering with dplyr::arrange().

  it("assigns feature ids in atlas appearance order, not alphabetically", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    flat <- prepare_polygon_atlas(poly)
    key <- paste(flat$label, flat$view, flat$.group, sep = "@@")
    first_ids <- flat$.feature_id[!duplicated(key)]
    expect_identical(first_ids, seq_along(first_ids))
  })

  it("orders feature ids by first appearance in the user data", {
    flat <- data.frame(
      label = c("a", "a", "b", "b", "c", "c"),
      view = "lateral",
      .group = 1L,
      region = c("ra", "ra", "rb", "rb", "rc", "rc"),
      stringsAsFactors = FALSE
    )
    # rb is absent from the data -> a context region, must stay underneath.
    data <- data.frame(region = c("rc", "ra"), stringsAsFactors = FALSE)
    ordered <- order_features_by_data(flat, data, by = "region")
    ids <- unique(ordered[c("region", ".feature_id")])
    expect_identical(ids$region[order(ids$.feature_id)], c("rb", "rc", "ra"))
  })

  it("draws atlas context regions beneath the user's regions", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    flat <- prepare_polygon_atlas(poly)
    data <- data.frame(
      region = sort(unique(ggseg.formats::atlas_regions(dk())))[1:2],
      v = 1:2
    )
    joined <- join_brain_values(data, flat, mean)
    feat <- joined[!duplicated(joined$.feature_id), c(".feature_id", "region")]
    in_data <- feat$region %in% data$region
    expect_lt(max(feat$.feature_id[!in_data]), min(feat$.feature_id[in_data]))
  })

  it("puts the last-arranged region on top", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    flat <- prepare_polygon_atlas(poly)
    top_region <- function(order_regs) {
      d <- data.frame(region = order_regs, v = seq_along(order_regs))
      j <- join_brain_values(d, flat, mean)
      j$region[j$.feature_id == max(j$.feature_id)][1]
    }
    regs <- sort(unique(ggseg.formats::atlas_regions(dk())))[1:4]
    expect_identical(top_region(regs), regs[4])
    expect_identical(top_region(rev(regs)), regs[1])
  })

  it("orders each facet panel by its own data order", {
    # StatBrain runs per panel, so each panel is joined against just its own
    # rows -- join_brain_values() is called once per panel's data.
    poly <- ggseg.formats::as_polygon_atlas(dk())
    flat <- prepare_polygon_atlas(poly)
    top_in <- function(panel_regs) {
      d <- data.frame(region = panel_regs, v = seq_along(panel_regs))
      j <- join_brain_values(d, flat, mean)
      j$region[j$.feature_id == max(j$.feature_id)][1]
    }
    two <- sort(unique(ggseg.formats::atlas_regions(dk())))[1:2]
    expect_identical(top_in(two), two[2])
    expect_identical(top_in(rev(two)), two[1])
  })

  it("layers overlapping outlines by data order", {
    testthat::skip_on_cran()
    # Mirrors ggseg#162: fill by a statistic, outline by a threshold factor.
    # The factor levels are fixed, so each region keeps its colour and only the
    # row order differs between the two plots -- isolating the draw order.
    # Regions are resolved from the rendered view itself so every row matches a
    # polygon under either ggseg.formats schema.
    regs <- utils::head(
      unique(stats::na.omit(
        prepare_polygon_atlas(dk(), hemi = "left", view = "lateral")$region
      )),
      3
    )
    make <- function(order_regs) {
      d <- data.frame(
        region = order_regs,
        stat = match(order_regs, regs),
        thr = factor(order_regs, levels = regs)
      )
      # No legend/titles: text rendering is font-dependent and differs across
      # platforms, which would make the snapshot fail on CI. The overlapping
      # outlines alone carry the draw-order signal.
      ggplot2::ggplot(d) +
        geom_brain(
          atlas = dk(),
          ggplot2::aes(fill = stat, colour = thr),
          hemi = "left",
          view = "lateral",
          linewidth = 3,
          show.legend = FALSE
        ) +
        ggplot2::theme_void()
    }
    expect_brain_doppelganger("draw-order-forward", make(regs))
    expect_brain_doppelganger("draw-order-reversed", make(rev(regs)))
  })
})

describe("geom_brain() position coercion", {
  built <- function(position) {
    p <- ggplot2::ggplot() + geom_brain(atlas = dk(), position = position)
    muffle_breaking_warnings(ggplot2::ggplot_build(p))$data[[1]]
  }

  it("applies a layout string the same way as a position_brain() spec", {
    expect_equal(built("vertical"), built(position_brain("vertical")))
  })

  it("applies a layout formula the same way as a spec", {
    expect_equal(built(hemi ~ view), built(position_brain(hemi ~ view)))
  })

  it("lays a string out differently from the default layout", {
    expect_false(isTRUE(all.equal(
      range(built("vertical")$y),
      range(built(position_brain())$y)
    )))
  })

  it("keeps raw polygon coordinates for 'identity'", {
    raw <- prepare_polygon_atlas(dk())
    expect_equal(range(built("identity")$x), range(raw$x))
    expect_equal(range(built("identity")$y), range(raw$y))
  })

  it("errors on an invalid position instead of silently ignoring it", {
    expect_error(built("nonsense"), "position")
  })
})
