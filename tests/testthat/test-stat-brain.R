describe("StatBrain", {
  it("is a ggplot2 Stat ggproto with a compute_panel", {
    expect_s3_class(StatBrain, "Stat")
    expect_type(StatBrain$compute_panel, "closure")
  })
})

describe("aggregate_brain_values()", {
  keys <- c("region", "label", "hemi")

  it("reduces numeric columns per key with fun (default mean)", {
    d <- data.frame(region = c("a", "a", "b"), fill = c(1, 3, 10))
    agg <- aggregate_brain_values(
      d,
      "region",
      mean,
      keys,
      warn_collapse = FALSE
    )
    expect_identical(agg$fill[agg$region == "a"], 2)
    expect_identical(agg$fill[agg$region == "b"], 10)
  })

  it("honours a custom aggregating function", {
    d <- data.frame(region = c("a", "a"), fill = c(1, 3))
    expect_identical(
      aggregate_brain_values(
        d,
        "region",
        max,
        keys,
        warn_collapse = FALSE
      )$fill,
      3
    )
    expect_identical(
      aggregate_brain_values(
        d,
        "region",
        min,
        keys,
        warn_collapse = FALSE
      )$fill,
      1
    )
  })

  it("takes the first value of non-numeric columns", {
    d <- data.frame(
      region = c("a", "a"),
      grp = c("x", "y"),
      stringsAsFactors = FALSE
    )
    expect_identical(
      aggregate_brain_values(
        d,
        "region",
        mean,
        keys,
        warn_collapse = FALSE
      )$grp,
      "x"
    )
  })

  it("collapses to one row per key", {
    d <- data.frame(region = c("a", "a", "b", "b"), fill = 1:4)
    expect_identical(
      nrow(aggregate_brain_values(
        d,
        "region",
        mean,
        keys,
        warn_collapse = FALSE
      )),
      2L
    )
  })

  it("errors clearly when fun does not reduce to a single value", {
    d <- data.frame(region = c("a", "a"), fill = c(1, 3))
    expect_error(
      aggregate_brain_values(d, "region", range, keys, warn_collapse = FALSE),
      "single value"
    )
  })
})

describe("join_brain_values()", {
  poly <- ggseg.formats::as_polygon_atlas(dk())
  flat <- prepare_polygon_atlas(poly)

  it("keeps every atlas polygon and leaves unmatched regions NA", {
    reg <- sort(unique(ggseg.formats::atlas_regions(dk())))[1]
    d <- data.frame(region = reg, fill = 5)
    j <- join_brain_values(d, flat, mean)
    expect_identical(nrow(j), nrow(flat))
    expect_identical(
      unique(j$fill[j$region %in% reg & !is.na(j$region)]),
      5
    )
    expect_true(anyNA(j$fill))
  })

  it("joins by label when data carries label but not region", {
    lbl <- sort(unique(ggseg.formats::atlas_labels(dk())))[1]
    d <- data.frame(label = lbl, fill = 1.5)
    j <- join_brain_values(d, flat, mean)
    expect_identical(unique(j$fill[j$label %in% lbl]), 1.5)
  })

  it("returns the bare atlas when the data has no join keys", {
    d <- data.frame(other = 1)
    j <- join_brain_values(d, flat, mean)
    expect_identical(nrow(j), nrow(flat))
    expect_identical(j$group, j$.feature_id)
  })

  it("sets group to the polygon feature id", {
    d <- data.frame(
      region = sort(unique(ggseg.formats::atlas_regions(dk())))[1],
      fill = 1
    )
    j <- join_brain_values(d, flat, mean)
    expect_identical(j$group, j$.feature_id)
  })
})

describe("stat_brain()", {
  it("produces the same layer output as geom_brain()", {
    regs <- sort(unique(ggseg.formats::atlas_regions(dk())))
    d <- data.frame(region = regs, value = seq_along(regs))
    g <- suppressMessages(ggplot2::ggplot_build(
      ggplot2::ggplot(d, ggplot2::aes(fill = value)) +
        geom_brain(atlas = dk()) +
        ggplot2::scale_fill_viridis_c()
    ))
    s <- suppressMessages(ggplot2::ggplot_build(
      ggplot2::ggplot(d, ggplot2::aes(fill = value)) +
        stat_brain(atlas = dk()) +
        ggplot2::scale_fill_viridis_c()
    ))
    expect_identical(g$data[[1]]$fill, s$data[[1]]$fill)
  })

  it("can pair StatBrain with a different geom", {
    p <- ggplot2::ggplot() +
      stat_brain(atlas = dk(), geom = "point")
    expect_gt(nrow(ggplot2::ggplot_build(p)$data[[1]]), 0)
  })
})

describe("geom_brain() aggregates multiple rows per region", {
  regs <- sort(unique(ggseg.formats::atlas_regions(dk())))[1:4]
  long <- do.call(
    rbind,
    lapply(1:3, function(i) {
      data.frame(region = regs, value = (1:4) * 10 + i)
    })
  )

  # Capture the aggregated fill before the fill scale maps it to colour.
  raw_fill <- function(fun) {
    captured <- new.env()
    Spy <- ggplot2::ggproto(
      "Spy",
      GeomBrain,
      setup_data = function(self, data, params) {
        captured$fill <- data$fill
        ggplot2::ggproto_parent(GeomBrain, self)$setup_data(data, params)
      }
    )
    p <- ggplot2::ggplot(long) +
      stat_brain(
        atlas = dk(),
        ggplot2::aes(fill = value),
        geom = Spy,
        fun = fun
      )
    invisible(ggplot2::ggplot_build(p))
    captured$fill
  }

  it("defaults to the mean of the rows", {
    # 12 is the mean of the region's three rows 11, 12 and 13
    expect_identical(min(raw_fill(mean), na.rm = TRUE), 12)
  })

  it("honours a custom fun", {
    expect_identical(min(raw_fill(max), na.rm = TRUE), 13)
    expect_identical(min(raw_fill(min), na.rm = TRUE), 11)
  })
})

describe("faceting without group_by (native via StatBrain)", {
  regs <- sort(unique(ggseg.formats::atlas_regions(dk())))
  faceted <- rbind(
    cbind(data.frame(region = regs, value = seq_along(regs)), cohort = "A"),
    cbind(data.frame(region = regs, value = rev(seq_along(regs))), cohort = "B")
  )
  build_faceted <- function(facet) {
    p <- ggplot2::ggplot(faceted) +
      geom_brain(atlas = dk(), ggplot2::aes(fill = value)) +
      facet +
      ggplot2::scale_fill_viridis_c()
    ggplot2::ggplot_build(p)$data[[1]]
  }

  it("draws the complete atlas in every facet_wrap panel", {
    d <- build_faceted(ggplot2::facet_wrap(~cohort))
    expect_setequal(as.character(unique(d$PANEL)), c("1", "2"))
    per <- as.integer(table(d$PANEL))
    expect_length(unique(per), 1) # equal rows per panel = full atlas in each
  })

  it("works with facet_grid too", {
    d <- build_faceted(ggplot2::facet_grid(rows = ggplot2::vars(cohort)))
    expect_length(unique(d$PANEL), 2)
  })

  it("gives each panel its own aggregated values", {
    d <- build_faceted(ggplot2::facet_wrap(~cohort))
    expect_false(identical(d$fill[d$PANEL == 1], d$fill[d$PANEL == 2]))
  })
})

describe("faceting on an atlas column subsets the atlas (not replicate)", {
  # Faceting on hemi/view should draw one slice per panel, the way the
  # pre-StatBrain renderer did -- not the whole brain in every panel.
  panel_rows <- function(p) {
    d <- ggplot2::ggplot_build(p)$data[[1]]
    as.integer(table(d$PANEL))
  }

  it("splits by hemisphere with facet_wrap(~hemi), no user data", {
    per <- panel_rows(
      ggplot2::ggplot() +
        geom_brain(atlas = dk(), show.legend = FALSE) +
        ggplot2::facet_wrap(~hemi)
    )
    full <- nrow(prepare_polygon_atlas(ggseg.formats::as_polygon_atlas(dk())))
    expect_length(per, 2)
    # each panel is one hemisphere: fewer rows than the full atlas
    expect_true(all(per < full))
    expect_identical(sum(per), full)
  })

  it("splits by view with facet_wrap(~view), no user data", {
    per <- panel_rows(
      ggplot2::ggplot() +
        geom_brain(atlas = dk(), show.legend = FALSE) +
        ggplot2::facet_wrap(~view)
    )
    full <- nrow(prepare_polygon_atlas(ggseg.formats::as_polygon_atlas(dk())))
    expect_gt(length(per), 1)
    expect_true(all(per < full))
  })

  it("splits by hemisphere with user data too", {
    regs <- sort(unique(ggseg.formats::atlas_regions(dk())))
    d <- data.frame(
      region = regs,
      hemi = ifelse(grepl("frontal", regs, fixed = TRUE), "left", "right"),
      v = 1
    )
    per <- panel_rows(
      ggplot2::ggplot(d, ggplot2::aes(fill = v)) +
        geom_brain(atlas = dk()) +
        ggplot2::facet_wrap(~hemi)
    )
    full <- nrow(prepare_polygon_atlas(ggseg.formats::as_polygon_atlas(dk())))
    expect_length(per, 2)
    expect_true(all(per < full))
  })

  it("facets on a non-standard atlas core column (e.g. lobe)", {
    # The atlas columns are derived from the flattened atlas, so any column the
    # core carries (dk() has `lobe`) can be faceted on, not just a fixed list.
    flat <- prepare_polygon_atlas(ggseg.formats::as_polygon_atlas(dk()))
    skip_if_not("lobe" %in% names(flat))
    per <- panel_rows(
      ggplot2::ggplot() +
        geom_brain(atlas = dk(), show.legend = FALSE) +
        ggplot2::facet_wrap(~lobe)
    )
    expect_gt(length(per), 1)
    expect_true(all(per < nrow(flat)))
  })
})

describe("geom_brain() with no data (atlas identity drives the stat)", {
  it("emits the full atlas rendered grey (no auto palette)", {
    d <- ggplot2::ggplot_build(
      ggplot2::ggplot() + geom_brain(atlas = dk())
    )$data[[1]]
    expect_gt(nrow(d), 0)
    expect_setequal(unique(d$fill), "grey")
  })

  it("maps aes(fill = region) to the atlas's own regions without user data", {
    # Regression: the atlas identity columns (region/label/hemi) must be
    # available for aesthetics even when no data is supplied.
    b <- ggplot2::ggplot_build(
      ggplot2::ggplot() +
        geom_brain(
          atlas = dk(),
          ggplot2::aes(fill = region),
          show.legend = FALSE
        )
    )
    d <- b$data[[1]]
    expect_gt(nrow(d), 0)
    # every non-context region gets a colour (not the single grey fallback)
    expect_gt(length(unique(d$fill)), 10)
  })

  it("maps aes(fill = label) to the atlas labels without user data", {
    expect_no_error(
      ggplot2::ggplot_build(
        ggplot2::ggplot() +
          geom_brain(
            atlas = dk(),
            ggplot2::aes(fill = label),
            show.legend = FALSE
          )
      )
    )
  })

  it("keeps the atlas draw order when there is no user data", {
    # No user data -> reorder is off, so feature ids stay in atlas order.
    d <- ggplot2::ggplot_build(
      ggplot2::ggplot() + geom_brain(atlas = dk())
    )$data[[1]]
    expect_identical(d$group, d$.feature_id)
  })
})
