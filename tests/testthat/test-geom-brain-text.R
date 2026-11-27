# The label layer is the last one added. `layer_data()` rather than
# `get_layer_data()`: the latter arrived in ggplot2 4.0 and this package
# declares `ggplot2 (>= 3.3)`, so CI installing the newest ggplot2 would have
# hidden a floor the tests quietly broke.
label_layer_data <- function(plot) {
  ggplot2::layer_data(plot, i = length(plot$layers))
}


describe("brain_label_anchors()", {
  it("puts the anchor inside the region, not at its centroid", {
    # The whole reason this is not `mean(x), mean(y)`: a crescent region has
    # its centroid outside itself, which prints the name on a neighbour.
    # Measured on the bundled atlases, a centroid falls outside its own shape
    # for 9% of `dk` and 41% of `tracula` shapes.
    skip_if_not_installed("sf")

    for (name in c("dk", "aseg", "tracula")) {
      atlas <- getExportedValue("ggseg.formats", name)()
      shapes <- sf::st_geometry(suppressWarnings(
        ggseg.formats::atlas_sf(atlas)
      ))
      outside <- 0L

      for (i in seq_along(shapes)) {
        coords <- sf::st_coordinates(shapes[i])
        ring <- coords[
          coords[, "L2"] == coords[1, "L2"] &
            coords[, "L3"] == coords[1, "L3"],
          ,
          drop = FALSE
        ]
        xy <- scanline_anchor(ring[, "X"], ring[, "Y"])
        point <- sf::st_sfc(
          sf::st_point(c(xy[[1]], xy[[2]])),
          crs = sf::st_crs(shapes)
        )
        if (length(sf::st_intersects(point, shapes[i])[[1]]) == 0) {
          outside <- outside + 1L
        }
      }

      # A hand-drawn sliver can still defeat it; a tenth of the shapes cannot.
      expect_lt(outside / length(shapes), 0.1)
    }
  })

  it("names each region once per view", {
    anchors <- brain_label_anchors(ggseg.formats::dk())

    expect_identical(anyDuplicated(anchors[, c("label", "view")]), 0L)
    expect_setequal(
      unique(anchors$view),
      ggseg.formats::atlas_views(ggseg.formats::dk())
    )
  })

  it("names no context geometry", {
    # The backdrop is anatomy without a name; labelling it would write `NA`
    # across the medial wall.
    anchors <- brain_label_anchors(ggseg.formats::dk())
    core <- ggseg.formats::atlas_core(ggseg.formats::dk())

    expect_true(all(anchors$label %in% core$label))
  })

  it("follows the same filtering as geom_brain()", {
    anchors <- brain_label_anchors(
      ggseg.formats::dk(),
      hemi = "left",
      view = "lateral"
    )

    expect_identical(unique(anchors$hemi), "left")
    expect_identical(unique(anchors$view), "lateral")
  })
})


describe("geom_brain_text()", {
  drawn <- label_layer_data

  it("takes its atlas from the brain layer it follows", {
    # The point of the layer: the plot already says which atlas it draws, and
    # a label layer that disagreed with it would be drawing another brain.
    plot <- ggplot2::ggplot() +
      geom_brain(atlas = ggseg.formats::dk(), hemi = "left") +
      geom_brain_text()

    anchors <- brain_label_anchors(ggseg.formats::dk(), hemi = "left")

    expect_identical(nrow(drawn(plot)), nrow(anchors))
  })

  it("takes the hemisphere and view with it", {
    plot <- ggplot2::ggplot() +
      geom_brain(atlas = ggseg.formats::dk(), hemi = "left", view = "lateral") +
      geom_brain_text()

    expect_identical(
      nrow(drawn(plot)),
      nrow(brain_label_anchors(
        ggseg.formats::dk(),
        hemi = "left",
        view = "lateral"
      ))
    )
  })

  it("names only the regions in `data`", {
    # Subsetting is ggplot2's job, done by handing a layer less data.
    plot <- ggplot2::ggplot() +
      geom_brain(atlas = ggseg.formats::dk(), hemi = "left") +
      geom_brain_text(
        data = data.frame(label = c("lh_insula", "lh_precuneus"))
      )

    expect_true(all(drawn(plot)$label %in% c("insula", "precuneus")))
    expect_lt(nrow(drawn(plot)), 10)
  })

  it("accepts data keyed on region as well as label", {
    plot <- ggplot2::ggplot() +
      geom_brain(atlas = ggseg.formats::dk(), hemi = "left") +
      geom_brain_text(data = data.frame(region = "insula"))

    expect_gt(nrow(drawn(plot)), 0)
    expect_true(all(drawn(plot)$label == "insula"))
  })

  it("writes what the mapping says, from the user's own column", {
    plot <- ggplot2::ggplot() +
      geom_brain(atlas = ggseg.formats::dk(), hemi = "left") +
      geom_brain_text(
        data = data.frame(label = "lh_insula", note = "look here"),
        mapping = ggplot2::aes(label = .data$note)
      )

    expect_identical(unique(drawn(plot)$label), "look here")
  })

  it("writes the display name by default", {
    plot <- ggplot2::ggplot() +
      geom_brain(atlas = ggseg.formats::dk(), hemi = "left") +
      geom_brain_text(data = data.frame(label = "lh_superiorfrontal"))

    expect_identical(unique(drawn(plot)$label), "superior frontal")
  })

  it("says so when there is no atlas to label", {
    expect_error(
      ggplot2::ggplot_build(ggplot2::ggplot() + geom_brain_text()),
      "atlas"
    )
  })

  it("says so when `data` is keyed on nothing the atlas knows", {
    plot <- ggplot2::ggplot() +
      geom_brain(atlas = ggseg.formats::dk()) +
      geom_brain_text(data = data.frame(roi = "insula"))

    expect_error(ggplot2::ggplot_build(plot), "no column in common")
  })

  it("warns when `data` names nothing the atlas draws", {
    plot <- ggplot2::ggplot() +
      geom_brain(atlas = ggseg.formats::dk()) +
      geom_brain_text(data = data.frame(label = "not_a_label"))

    expect_warning(ggplot2::ggplot_build(plot), "No region to label")
  })

  it("draws a box for geom_brain_label()", {
    expect_s3_class(geom_brain_text()$geom, "GeomText")
    expect_s3_class(geom_brain_label()$geom, "GeomLabel")
  })
})


describe("nudge_label_anchors()", {
  anchors <- function(n = 2) {
    data.frame(
      label = head(c("a", "b", "c"), n),
      x = seq_len(n) * 10,
      y = seq_len(n) * 100
    )
  }

  it("records where the label came from before moving it", {
    # The recorded anchor is the whole mechanism: it is what the leader line
    # is drawn to and what the justification is derived from.
    moved <- nudge_label_anchors(anchors(), list(x = 5, y = -7))

    expect_identical(moved$x_orig, c(10, 20))
    expect_identical(moved$y_orig, c(100, 200))
    expect_identical(moved$x, c(15, 25))
    expect_identical(moved$y, c(93, 193))
  })

  it("leaves no trace at all when nothing is nudged", {
    # Absence of the column is what makes the connector disable itself, so an
    # un-nudged label must not merely have x_orig == x.
    untouched <- nudge_label_anchors(anchors(), list(x = 0, y = 0))

    expect_false(any(c("x_orig", "y_orig") %in% names(untouched)))
  })

  it("moves each label by its own amount", {
    moved <- nudge_label_anchors(anchors(), list(x = c(1, 2), y = c(0, 0)))

    expect_identical(moved$x, c(11, 22))
  })

  it("refuses a nudge that does not line up with the labels", {
    # Recycling three values over two labels would silently mislabel the plot.
    expect_error(
      nudge_label_anchors(anchors(), list(x = c(1, 2, 3), y = 0)),
      "one per label"
    )
  })
})


describe("justify_away_from_anchor()", {
  drawn <- function(dx, dy, hjust = NA, vjust = NA) {
    justify_away_from_anchor(
      data.frame(
        x = 10 + dx,
        y = 10 + dy,
        x_orig = 10,
        y_orig = 10,
        hjust = hjust,
        vjust = vjust
      ),
      nudged = TRUE
    )
  }

  it("turns the text away from the region it points at", {
    # A label nudged left reads as belonging to its region only if its right
    # edge is the end nearest the line.
    expect_identical(drawn(dx = -5, dy = 0)$hjust, 1)
    expect_identical(drawn(dx = 5, dy = 0)$hjust, 0)
    expect_identical(drawn(dx = 0, dy = -5)$vjust, 1)
    expect_identical(drawn(dx = 0, dy = 5)$vjust, 0)
  })

  it("centres a label that was not moved on that axis", {
    expect_identical(drawn(dx = 5, dy = 0)$vjust, 0.5)
  })

  it("keeps a justification the caller asked for", {
    expect_identical(drawn(dx = -5, dy = 0, hjust = 0)$hjust, 0)
  })

  it("centres everything when no label was nudged", {
    centred <- justify_away_from_anchor(
      data.frame(x = 1, y = 1, hjust = NA, vjust = NA),
      nudged = FALSE
    )

    expect_identical(centred$hjust, 0.5)
    expect_identical(centred$vjust, 0.5)
  })
})


describe("the label geoms", {
  it("declares the connector's arguments as its own parameters", {
    # ggplot2 filters a geom's parameters twice, and the second filter reads
    # `parameters(extra = FALSE)`. Declaring them only in `extra_params`
    # cleared the first filter -- so the "unknown parameter" warning stopped
    # -- while the second still dropped them, and the line drew default
    # padding in default black. This is that contract, stated once.
    for (geom in list(GeomBrainText, GeomBrainLabel)) {
      expect_true(all(connector_params %in% geom$parameters()))
      expect_true(all(connector_params %in% geom$parameters(extra = TRUE)))
    }
  })

  it("takes the connector's colour and width as aesthetics", {
    # Parameters would force every connector in a plot to look the same.
    # As aesthetics they can be mapped, so one label can be accented and the
    # rest left quiet.
    for (geom in list(GeomBrainText, GeomBrainLabel)) {
      expect_true(all(
        c("segment.colour", "segment.linewidth") %in% geom$aesthetics()
      ))
    }
  })

  it("keeps what it inherits from the geom it wraps", {
    expect_true("check_overlap" %in% GeomBrainText$parameters())
    expect_true("label.padding" %in% GeomBrainLabel$parameters())
  })
})


describe("segment_colour()", {
  it("falls back to the colour of the text it belongs to", {
    # What makes the aesthetic optional: say nothing about the connector and
    # it still matches its own label rather than turning up black.
    quiet <- data.frame(colour = c("red", "blue"), segment.colour = NA)

    expect_identical(segment_colour(quiet), c("red", "blue"))
  })

  it("uses its own colour where one is given", {
    mixed <- data.frame(
      colour = c("red", "blue"),
      segment.colour = c(NA, "grey50")
    )

    expect_identical(segment_colour(mixed), c("red", "grey50"))
  })
})


describe("makeContent.brain_leader()", {
  leader <- function(
    label_x,
    min_length = grid::unit(0.5, "lines"),
    padding = grid::unit(0.3, "lines")
  ) {
    grid::gTree(
      anchor_x = 0.1,
      anchor_y = 0.5,
      label_x = label_x,
      label_y = 0.5,
      box_padding = padding,
      point_padding = padding,
      min_length = min_length,
      colour = "black",
      linewidth = 0.4,
      cl = "brain_leader"
    )
  }

  # Millimetres do not exist without a device, and `convertX()` returns a
  # plausible wrong number rather than erroring when there is none.
  on_a_device <- function(code) {
    grDevices::pdf(NULL)
    on.exit(grDevices::dev.off(), add = TRUE)
    grid::grid.newpage()
    force(code)
  }

  it("insets both ends, so the line touches neither text nor region", {
    content <- on_a_device(grid::makeContent(leader(label_x = 0.9)))
    segment <- content$children[[1]]

    anchor_mm <- grid::convertX(grid::unit(0.1, "npc"), "mm", TRUE)
    label_mm <- grid::convertX(grid::unit(0.9, "npc"), "mm", TRUE)
    pad_mm <- grid::convertWidth(grid::unit(0.3, "lines"), "mm", TRUE)

    expect_equal(
      grid::convertX(segment$x0, "mm", TRUE),
      anchor_mm + pad_mm,
      tolerance = 1e-6
    )
    expect_equal(
      grid::convertX(segment$x1, "mm", TRUE),
      label_mm - pad_mm,
      tolerance = 1e-6
    )
  })

  it("draws nothing rather than a stub", {
    # A barely-nudged label sits on its own region; a 1mm line into it is
    # noise, which is why ggrepel has min.segment.length at all.
    content <- on_a_device(grid::makeContent(leader(label_x = 0.102)))

    expect_length(content$children, 0)
  })

  it("counts the padding against the minimum, not just the raw distance", {
    # A segment long enough before trimming can be nothing afterwards.
    short <- on_a_device(grid::makeContent(
      leader(label_x = 0.14, padding = grid::unit(2, "lines"))
    ))
    long <- on_a_device(grid::makeContent(
      leader(label_x = 0.14, padding = grid::unit(0, "lines"))
    ))

    expect_length(short$children, 0)
    expect_length(long$children, 1)
  })
})


describe("geom_brain_text(nudge_x=, nudge_y=)", {
  nudged_plot <- function(
    ...,
    data = data.frame(label = c("lh_insula", "lh_temporalpole"))
  ) {
    ggplot2::ggplot() +
      geom_brain(
        atlas = ggseg.formats::dk(),
        hemi = "left",
        view = "lateral"
      ) +
      geom_brain_text(data = data, ...)
  }

  it("carries the recorded anchor through to the geom", {
    # ggplot2 drops any column the mapping does not claim, so the anchor only
    # survives because `default_label_mapping()` maps it.
    drawn <- label_layer_data(
      nudged_plot(nudge_x = c(0, -40), nudge_y = c(0, -30))
    )

    expect_true(all(c("x_orig", "y_orig") %in% names(drawn)))
    expect_identical(drawn$x - drawn$x_orig, c(0, -40))
  })

  it("moves each label by the nudge written beside it", {
    # `merge()` returns rows in key order, so a nudge vector written against
    # the caller's own row order landed on the wrong labels: a region asked to
    # move up moved down instead, silently and only visibly in the render.
    drawn <- label_layer_data(
      ggplot2::ggplot() +
        geom_brain(
          atlas = ggseg.formats::dk(),
          hemi = "left",
          view = "lateral"
        ) +
        geom_brain_text(
          data = data.frame(label = c("lh_superiorfrontal", "lh_insula")),
          nudge_x = c(0, 0),
          nudge_y = c(60, -60)
        )
    )
    moved <- stats::setNames(drawn$y - drawn$y_orig, drawn$label)

    expect_identical(moved[["superior frontal"]], 60)
    expect_identical(moved[["insula"]], -60)
  })

  it("moves a region the same way in every view it is drawn in", {
    # One row written by the caller is one nudge, however many anchors that
    # row turns into.
    drawn <- label_layer_data(
      ggplot2::ggplot() +
        geom_brain(atlas = ggseg.formats::dk(), hemi = "left") +
        geom_brain_text(
          data = data.frame(label = "lh_insula"),
          nudge_x = 25
        )
    )

    expect_gt(nrow(drawn), 1)
    expect_identical(unique(drawn$x - drawn$x_orig), 25)
  })

  it("adds no anchor column when nothing is nudged", {
    drawn <- label_layer_data(nudged_plot())

    expect_false("x_orig" %in% names(drawn))
  })

  it("renders a nudged label with its leader line", {
    expect_brain_doppelganger(
      "nudged label with leader line",
      nudged_plot(nudge_x = c(0, -40), nudge_y = c(0, -30), size = 3)
    )
  })

  it("accents one connector differently from another", {
    # The reason these are aesthetics and not parameters.
    expect_brain_doppelganger(
      "accented connectors",
      nudged_plot(
        data = data.frame(
          label = c("lh_insula", "lh_temporalpole"),
          accent = c("firebrick", "grey60"),
          weight = c(1.5, 0.4)
        ),
        mapping = ggplot2::aes(
          segment.colour = .data$accent,
          segment.linewidth = .data$weight
        ),
        nudge_x = c(-45, -40),
        nudge_y = c(-45, -30),
        size = 3
      )
    )
  })

  it("renders the connector the way it was asked to", {
    # The end-to-end half of the parameters contract. A styled connector is
    # the only evidence that does not depend on ggplot2's internal shape:
    # when these arguments were silently dropped, two plots differing only in
    # `segment.colour` and `segment.linewidth` rendered byte-identically.
    expect_brain_doppelganger(
      "styled leader line",
      nudged_plot(
        nudge_x = c(0, -40),
        nudge_y = c(0, -30),
        size = 3,
        segment.colour = "red",
        segment.linewidth = 1.4,
        box.padding = grid::unit(1, "lines")
      )
    )
  })
})

describe("a region-keyed label respects the hemisphere", {
  # `dk` names its parcels anatomically, so `region` is shared between the
  # sides and `hemi` is the only thing that separates them. Keying on
  # `region` alone drew a left-only row's text on the right hemisphere too --
  # a left/right error, not a cosmetic one.
  it("labels only the hemisphere the data names", {
    anchors <- brain_label_anchors(dk())
    region <- anchors$region[!is.na(anchors$hemi)][1]
    user_data <- data.frame(region = region, hemi = "left")

    named <- select_labelled_regions(anchors, user_data)

    expect_setequal(named$hemi, "left")
    expect_gt(nrow(named), 0)
  })

  it("labels both hemispheres when the data names neither", {
    anchors <- brain_label_anchors(dk())
    region <- anchors$region[!is.na(anchors$hemi)][1]

    named <- select_labelled_regions(anchors, data.frame(region = region))

    expect_setequal(named$hemi, c("left", "right"))
  })
})
