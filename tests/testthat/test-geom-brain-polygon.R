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
    regs <- unique(ggseg.formats::atlas_regions(poly))
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
    regs <- unique(ggseg.formats::atlas_regions(poly))
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

  # The backdrop and the parcels are two layers of one pair, so they must crop
  # to the SAME focus. Deriving the focus from the flag that says "this layer
  # has user data" gave the context layer the whole atlas while the regions
  # layer zoomed, so the grey silhouette no longer registered with the
  # parcellation (ggsegverse/ggseg#217). Data goes on `ggplot()` here, not on
  # the layer: with layer-level data the plot has no top-level data and the
  # context layer never had a focus to lose.
  it("crops the backdrop and the parcels to the same focus", {
    regs <- unique(ggseg.formats::atlas_regions(aseg()))
    regs <- regs[!is.na(regs)][1:3]
    user <- data.frame(region = regs, measure = seq_along(regs))

    context_span <- function(dat) {
      plot <- if (is.null(dat)) {
        ggplot2::ggplot()
      } else {
        ggplot2::ggplot(dat, ggplot2::aes(fill = measure))
      }
      built <- ggplot2::ggplot_build(
        plot +
          geom_brain(atlas = aseg(), position = position_brain(zoom = TRUE))
      )
      diff(range(built$data[[1]]$x))
    }

    # With no user data the backdrop legitimately focuses on every label, so
    # comparing against that is what distinguishes "focused on the user's three
    # regions" from "ignored the user's data". Comparing against `zoom = FALSE`
    # is NOT enough: the broken layout still narrows, just to the wrong focus.
    expect_lt(context_span(user), context_span(NULL))
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

  it("draws context behind structures whatever the stored order (ggseg#181)", {
    poly <- ggseg.formats::as_polygon_atlas(aseg())
    geom <- ggseg.formats::atlas_geom(poly)
    core_labels <- ggseg.formats::atlas_labels(poly)
    is_context <- !geom$label %in% core_labels
    # No setter reorders stored geometry, so the reordering goes via the
    # property.
    poly@data$geom <- geom[c(which(!is_context), which(is_context)), ]

    flat <- prepare_polygon_atlas(poly)
    context_rows <- which(!flat$label %in% core_labels)
    core_rows <- which(flat$label %in% core_labels)

    expect_gt(length(context_rows), 0)
    expect_lt(max(context_rows), min(core_rows))
  })

  it("keeps the medial wall when filtering on hemi (ggseg#210)", {
    # Contextual geometry holds no `core` row, so the join leaves its `hemi`
    # NA and `NA %in% "right"` is FALSE. Filtering before the hemisphere is
    # inferred dropped the medial wall, so `hemi = "right"` drew no backdrop
    # at all while `position_brain("right lateral")` drew one.
    core_labels <- ggseg.formats::atlas_labels(dk())
    flat <- prepare_polygon_atlas(dk(), hemi = "right")
    context <- unique(flat$label[!flat$label %in% core_labels])

    expect_length(context, 1)
    expect_match(context, "^rh[_.]")
    expect_false(anyNA(flat$hemi))
  })

  it("keeps the stored order within context and within structures", {
    poly <- ggseg.formats::as_polygon_atlas(aseg())
    core_labels <- ggseg.formats::atlas_labels(poly)
    stored <- unique(ggseg.formats::atlas_geom(poly)$label)
    flat <- prepare_polygon_atlas(poly)
    expect_identical(
      unique(flat$label[flat$label %in% core_labels]),
      stored[stored %in% core_labels]
    )
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
      "not merged",
      class = "ggseg_unmatched_data"
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

  it("stays silent on correct top-level data", {
    # The backdrop layer is built with `data = NULL`, which ggplot2 reads as
    # "inherit the plot's data". Joining that against context rows matched
    # nothing and reported every correct row as unmatched.
    data <- data.frame(
      region = sort(unique(ggseg.formats::atlas_regions(dk())))[1:4],
      p = seq(0.1, 0.4, by = 0.1)
    )
    p <- ggplot2::ggplot(data, ggplot2::aes(fill = p)) +
      geom_brain(atlas = dk())
    expect_no_warning(
      ggplot2::ggplot_build(p),
      class = "ggseg_unmatched_data"
    )
  })
})

describe("a `label` aesthetic is not mistaken for the join key", {
  # `label` is both a ggplot2 aesthetic and the atlas's canonical join key, so
  # deriving the keys a second time from the computed aesthetics joined on the
  # user's text and lost every value. The keys now travel under internal
  # aesthetic names (see key_aes()), so the two cannot collide at all.
  regs <- sort(unique(ggseg.formats::atlas_regions(dk())))[1:4]
  data <- data.frame(
    region = regs,
    v = seq_along(regs),
    txt = paste0("t", seq_along(regs))
  )
  fills <- function(p) brain_layer_data(p)$fill

  it("gives the same fills whether or not `label` is mapped", {
    expect_identical(
      fills(
        ggplot2::ggplot(data, ggplot2::aes(fill = v, label = txt)) +
          geom_brain(atlas = dk())
      ),
      fills(
        ggplot2::ggplot(data, ggplot2::aes(fill = v)) + geom_brain(atlas = dk())
      )
    )
  })

  it("gives the same fills with the mapping on the layer", {
    expect_identical(
      fills(
        ggplot2::ggplot(data) +
          geom_brain(atlas = dk(), ggplot2::aes(fill = v, label = txt))
      ),
      fills(
        ggplot2::ggplot(data, ggplot2::aes(fill = v)) + geom_brain(atlas = dk())
      )
    )
  })

  it("still colours the mapped regions", {
    f <- fills(
      ggplot2::ggplot(data, ggplot2::aes(fill = v, label = txt)) +
        geom_brain(atlas = dk())
    )
    expect_length(setdiff(unique(f), "grey50"), length(regs))
  })

  it("joins `label`-keyed data too, which the aesthetic used to overwrite", {
    # The ecosystem keys on `label`, so this is the standard case, not a
    # corner: the key column was replaced by the user's text before the stat
    # joined on it and every value was lost.
    lbls <- sort(unique(ggseg.formats::atlas_labels(dk())))[1:4]
    keyed <- data.frame(label = lbls, v = seq_along(lbls), txt = "t")
    f <- fills(
      ggplot2::ggplot(keyed, ggplot2::aes(fill = v, label = txt)) +
        geom_brain(atlas = dk())
    )
    expect_length(setdiff(unique(f), "grey50"), length(lbls))
  })

  it("gives label-keyed data the same fills with or without the aesthetic", {
    lbls <- sort(unique(ggseg.formats::atlas_labels(dk())))[1:4]
    keyed <- data.frame(label = lbls, v = seq_along(lbls), txt = "t")
    expect_identical(
      fills(
        ggplot2::ggplot(keyed, ggplot2::aes(fill = v, label = txt)) +
          geom_brain(atlas = dk())
      ),
      fills(
        ggplot2::ggplot(keyed, ggplot2::aes(fill = v)) +
          geom_brain(atlas = dk())
      )
    )
  })
})

describe("a facet column a mapping points elsewhere", {
  it("warns that the panels will follow the mapped values", {
    # Keys are safe now that they travel under internal names, but a facet
    # variable must keep its own name for ggplot2 to resolve the panels, so
    # this collision is still real.
    lbls <- sort(unique(ggseg.formats::atlas_labels(dk())))[1:4]
    keyed <- data.frame(label = lbls, v = seq_along(lbls), txt = "t")
    expect_warning(
      ggplot2::ggplot_build(
        ggplot2::ggplot(keyed, ggplot2::aes(fill = v, label = txt)) +
          geom_brain(atlas = dk()) +
          ggplot2::facet_wrap(~label)
      ),
      class = "ggseg_shadowed_facet_column"
    )
  })
})

describe("an emptied `data` still draws the atlas", {
  # A filter that matches nothing leaves a zero-row data.frame, which takes the
  # no-user-data branch; the atlas's own rows do not carry the user's columns,
  # so a mapping onto them failed to evaluate.
  it("renders rather than failing on the mapped column", {
    data <- data.frame(
      region = sort(unique(ggseg.formats::atlas_regions(dk())))[1:4],
      p = seq(0.1, 0.4, by = 0.1)
    )
    p <- ggplot2::ggplot() +
      geom_brain(
        data = data[data$p > 1, , drop = FALSE],
        atlas = dk(),
        ggplot2::aes(fill = p)
      )
    expect_no_error(built <- brain_layer_data(p))
    expect_gt(nrow(built), 0)
    # nothing matched, so every region takes the scale's NA colour
    expect_length(unique(built$fill), 1L)
  })
})

describe("geom_brain() inherits top-level data and aes (ggseg#158)", {
  # Regression test for ggsegverse/ggseg#158: data and aesthetics set in the
  # top-level ggplot() call were dropped by the eager polygon build, so fill
  # fell back to the region labels instead of the user's mapped values.
  fill_column <- function(p) {
    brain_regions_built(ggplot2::ggplot_build(p))$fill
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

  it("applies the atlas palette when no fill is mapped anywhere", {
    # The default is the atlas's own palette, keyed on `label`; `grey` is only
    # the na.value for rows the palette has no entry for (context regions).
    p <- ggplot2::ggplot() + geom_brain(atlas = dk())
    fills <- unique(fill_column(p))
    expect_gt(length(fills), 1)
    expect_true(all(
      setdiff(fills, "grey") %in% toupper(ggseg.formats::atlas_palette(dk()))
    ))
  })

  it("does not inject a discrete palette that fights a continuous fill", {
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
  built <- function(p) brain_regions_built(ggplot2::ggplot_build(p))

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
    joined <- join_brain_values(data, flat, mean, "region")
    feat <- joined[!duplicated(joined$.feature_id), c(".feature_id", "region")]
    in_data <- feat$region %in% data$region
    expect_lt(max(feat$.feature_id[!in_data]), min(feat$.feature_id[in_data]))
  })

  it("puts the last-arranged region on top", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    flat <- prepare_polygon_atlas(poly)
    top_region <- function(order_regs) {
      d <- data.frame(region = order_regs, v = seq_along(order_regs))
      j <- join_brain_values(d, flat, mean, "region")
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
      j <- join_brain_values(d, flat, mean, "region")
      j$region[j$.feature_id == max(j$.feature_id)][1]
    }
    two <- sort(unique(ggseg.formats::atlas_regions(dk())))[1:2]
    expect_identical(top_in(two), two[2])
    expect_identical(top_in(rev(two)), two[1])
  })

  it("layers overlapping outlines by data order", {
    skip_on_cran()
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
    brain_regions_built(muffle_breaking_warnings(ggplot2::ggplot_build(p)))
  }

  it("applies a layout string the same way as a position_brain() spec", {
    expect_identical(built("vertical"), built(position_brain("vertical")))
  })

  it("applies a layout formula the same way as a spec", {
    expect_identical(built(hemi ~ view), built(position_brain(hemi ~ view)))
  })

  it("lays a string out differently from the default layout", {
    expect_false(isTRUE(all.equal(
      range(built("vertical")$y),
      range(built(position_brain())$y)
    )))
  })

  it("keeps raw polygon coordinates for 'identity'", {
    raw <- prepare_polygon_atlas(dk())
    expect_identical(range(built("identity")$x), range(raw$x))
    expect_identical(range(built("identity")$y), range(raw$y))
  })

  it("errors on an invalid position instead of silently ignoring it", {
    expect_error(built("nonsense"), "position")
  })
})

describe("the context backdrop is a layer of its own (#182)", {
  it("adds a context layer under the regions when context = TRUE", {
    p <- ggplot2::ggplot() + geom_brain(atlas = ggseg.formats::aseg())
    rows <- unname(
      vapply(p$layers, function(l) l$brain_rows %||% NA_character_, "")
    )
    # the backdrop is first, so it draws underneath
    expect_identical(rows, c("context", "regions"))
  })

  it("adds no context layer when context = FALSE", {
    p <- ggplot2::ggplot() +
      geom_brain(atlas = ggseg.formats::aseg(), context = FALSE)
    rows <- unname(
      vapply(p$layers, function(l) l$brain_rows %||% NA_character_, "")
    )
    expect_identical(rows, "all")
  })

  it("keeps a mapped fill off the backdrop", {
    atlas <- ggseg.formats::aseg()
    p <- ggplot2::ggplot() +
      geom_brain(atlas = atlas, mapping = ggplot2::aes(fill = label))

    backdrop <- brain_layer_data(p, context = TRUE)
    regions <- brain_layer_data(p)

    expect_identical(unique(backdrop$fill), "grey")
    expect_gt(length(unique(regions$fill)), 10)
    expect_setequal(
      unique(backdrop$label),
      ggseg.formats::atlas_context(atlas)
    )
  })

  it("leaves the backdrop out of the fill scale, so it claims no key", {
    atlas <- ggseg.formats::aseg()
    p <- ggplot2::ggplot() +
      geom_brain(atlas = atlas, mapping = ggplot2::aes(fill = label))
    limits <- ggplot2::ggplot_build(p)$plot$scales$get_scales(
      "fill"
    )$get_limits()

    expect_false(anyNA(limits))
    expect_false(any(ggseg.formats::atlas_context(atlas) %in% limits))
    expect_setequal(limits, ggseg.formats::atlas_labels(atlas))
  })

  it("recolours the backdrop with context_fill", {
    p <- ggplot2::ggplot() +
      geom_brain(atlas = ggseg.formats::aseg(), context_fill = "white")
    expect_identical(unique(brain_layer_data(p, context = TRUE)$fill), "white")
  })

  it("lays both layers out on the same coordinates", {
    atlas <- ggseg.formats::aseg()
    p <- ggplot2::ggplot() + geom_brain(atlas = atlas)
    backdrop <- brain_layer_data(p, context = TRUE)
    regions <- brain_layer_data(p)
    # the regions sit inside the backdrop's extent: one shared layout
    expect_gte(min(regions$x), min(backdrop$x))
    expect_lte(max(regions$x), max(backdrop$x))
  })
})

describe("an atlas whose geometry carries core columns", {
  # ggsegDemoatlas ships `hemi` and `region` inside its geometry as well as in
  # `core`. Joining both suffixed the core's copy away as `region.y`, so the
  # flattened atlas had no `region` column at all: `context` stopped
  # filtering and user data keyed on region could not be joined.
  shadowing_atlas <- function() {
    atlas <- ggseg.formats::dk()
    geom <- ggseg.formats::atlas_geom(atlas)
    core <- ggseg.formats::atlas_core(atlas)
    geom$region <- core$region[match(geom$label, core$label)]
    geom$hemi <- core$hemi[match(geom$label, core$label)]
    ggseg.formats::set_atlas_geom(atlas, geom)
  }

  it("keeps one unsuffixed core column of each name", {
    flat <- prepare_polygon_atlas(shadowing_atlas())

    expect_true("region" %in% names(flat))
    expect_true("hemi" %in% names(flat))
    expect_false(any(grepl("[.][xy]$", names(flat))))
  })

  it("still joins user data keyed on region", {
    atlas <- shadowing_atlas()
    regions <- sort(unique(stats::na.omit(ggseg.formats::atlas_regions(atlas))))
    user <- data.frame(region = regions[1:3], value = 1:3)

    p <- ggplot2::ggplot() +
      geom_brain(atlas = atlas, data = user, ggplot2::aes(fill = value))

    expect_no_error(ggplot2::ggplot_build(p))
  })
})

describe("the brain is drawn whole", {
  # The invariant the package exists to keep: however few regions carry data,
  # every region of the atlas is still drawn, and the non-region anatomy (the
  # medial wall, subcortical backdrop) is still drawn behind it. A plot that
  # silently loses shapes reads as a brain with a hole in it, which is how
  # issue 210 was reported.
  shapes <- function(p) {
    built <- ggplot2::ggplot_build(p)
    vapply(built$data, function(d) length(unique(d$group)), integer(1))
  }

  it("draws the same shapes however many regions carry data", {
    atlas <- ggseg.formats::dk()
    regions <- sort(unique(stats::na.omit(ggseg.formats::atlas_regions(atlas))))

    bare <- shapes(ggplot2::ggplot() + geom_brain(atlas = atlas))
    one <- shapes(
      ggplot2::ggplot() +
        geom_brain(
          atlas = atlas,
          data = data.frame(region = regions[1], value = 1),
          ggplot2::aes(fill = value)
        )
    )
    several <- shapes(
      ggplot2::ggplot() +
        geom_brain(
          atlas = atlas,
          data = data.frame(region = regions[1:3], value = 1:3),
          ggplot2::aes(fill = value)
        )
    )

    expect_identical(one, bare)
    expect_identical(several, bare)
  })

  it("does not lose context geometry to a filter", {
    # Not every view has context -- `superior` has none, because looking down
    # on a brain there is no medial wall to see. The invariant is that a
    # filter never drops context the unfiltered plot has.
    #
    # Looping the bundled atlases is the point: #210 was fixed for `dk` by
    # inferring a hemisphere from an `lh_`/`rh_` label prefix, which `aseg`
    # and `tracula` do not have, so their whole-brain backdrop was still
    # being deleted while a dk-only test called it fixed.
    for (name in c("dk", "aseg", "tracula")) {
      atlas <- getExportedValue("ggseg.formats", name)()
      whole <- shapes(ggplot2::ggplot() + geom_brain(atlas = atlas))[[1]]

      sided <- vapply(
        c("left", "right"),
        function(h) {
          shapes(ggplot2::ggplot() + geom_brain(atlas = atlas, hemi = h))[[1]]
        },
        integer(1)
      )

      # Every context shape survives into at least one hemisphere: a backdrop
      # that spans both is kept twice, a sided one lands in its own.
      expect_gte(sum(sided), whole)
      expect_true(all(sided > 0))
    }
  })

  it("draws the medial wall when one hemisphere is asked for", {
    # The exact shape of ggsegverse/ggseg#210: `hemi = "right"` across both
    # views drew the regions but no backdrop, leaving a hole in the medial
    # view where the wall belongs.
    atlas <- ggseg.formats::dk()

    built <- ggplot2::ggplot_build(
      ggplot2::ggplot() +
        geom_brain(atlas = atlas, hemi = "right", view = c("lateral", "medial"))
    )

    expect_gt(nrow(built$data[[1]]), 0)
  })

  it("leaves no region unfilled", {
    atlas <- ggseg.formats::dk()
    regions <- sort(unique(stats::na.omit(ggseg.formats::atlas_regions(atlas))))

    built <- ggplot2::ggplot_build(
      ggplot2::ggplot() +
        geom_brain(
          atlas = atlas,
          data = data.frame(region = regions[1:3], value = 1:3),
          ggplot2::aes(fill = value)
        )
    )

    # A region with no value is grey, not invisible: an NA fill would punch a
    # hole in the outline exactly where a reader expects anatomy.
    for (layer in built$data) {
      expect_false(anyNA(layer$fill))
    }
  })
})
