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

    expect_false(any(duplicated(anchors[, c("label", "view")])))
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
  drawn <- function(plot) {
    built <- ggplot2::ggplot_build(plot)
    built$data[[length(built$data)]]
  }

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
