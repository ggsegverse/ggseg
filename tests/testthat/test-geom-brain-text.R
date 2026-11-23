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

  it("labels no context geometry", {
    # The backdrop is anatomy without a name; labelling it would write `NA`
    # across the medial wall.
    anchors <- brain_label_anchors(ggseg.formats::dk())
    core <- ggseg.formats::atlas_core(ggseg.formats::dk())

    expect_true(all(anchors$label %in% core$label))
    expect_false(anyNA(anchors$.brain_label))
  })

  it("writes the display name, and falls back to the label", {
    atlas <- ggseg.formats::dk()
    display <- brain_label_anchors(atlas)

    expect_true(all(
      display$.brain_label %in% ggseg.formats::atlas_display(atlas)
    ))

    explicit <- brain_label_anchors(atlas, label = "label")
    expect_setequal(explicit$.brain_label, explicit$label)
  })

  it("rejects a column the atlas does not have", {
    expect_error(
      brain_label_anchors(ggseg.formats::dk(), label = "nope"),
      "must name a column"
    )
  })

  it("follows the same filtering as geom_brain()", {
    atlas <- ggseg.formats::dk()
    one <- brain_label_anchors(atlas, hemi = "left", view = "lateral")

    expect_identical(unique(one$hemi), "left")
    expect_identical(unique(one$view), "lateral")
  })
})


describe("geom_brain_text()", {
  it("adds one text row per labelled region", {
    atlas <- ggseg.formats::dk()
    anchors <- brain_label_anchors(atlas, hemi = "left", view = "lateral")

    built <- ggplot2::ggplot_build(
      ggplot2::ggplot() +
        geom_brain(atlas = atlas, hemi = "left", view = "lateral") +
        geom_brain_text(atlas = atlas, hemi = "left", view = "lateral")
    )

    expect_identical(nrow(built$data[[length(built$data)]]), nrow(anchors))
  })

  it("matches the pattern on label, as the atlas verbs do", {
    # `label` is the canonical matching key ecosystem-wide; `match_on` is the
    # documented way to ask for the region text instead.
    atlas <- ggseg.formats::dk()

    on_label <- brain_label_anchors(atlas, hemi = "left", pattern = "insula")
    on_region <- brain_label_anchors(
      atlas,
      hemi = "left",
      pattern = "superiorfrontal",
      match_on = "region"
    )

    expect_true(all(grepl("insula", on_label$label, ignore.case = TRUE)))
    expect_identical(unique(on_region$.brain_label), "superior frontal")
  })

  it("says what it matched against when nothing does", {
    expect_error(
      brain_label_anchors(ggseg.formats::dk(), pattern = "not a region"),
      "No region"
    )
  })

  it("draws a box for geom_brain_label()", {
    atlas <- ggseg.formats::dk()

    text <- geom_brain_text(atlas, view = "lateral")
    boxed <- geom_brain_label(atlas, view = "lateral")

    expect_s3_class(text$geom, "GeomText")
    expect_s3_class(boxed$geom, "GeomLabel")
  })
})
