describe("geom_brain_sf (deprecated sf path)", {
  it("works with basic atlas", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    p <- ggplot() + geom_brain_sf(atlas = dk())
    expect_s3_class(p, "gg")
  })

  it("warns when deprecated side argument is used", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    expect_warning(
      ggplot() + geom_brain_sf(atlas = dk(), side = "lateral"),
      "side.*deprecated"
    )
  })

  it("uses side value for view when view is NULL", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    expect_warning(
      p <- ggplot() + geom_brain_sf(atlas = dk(), side = "lateral"),
      "side.*deprecated"
    )
    expect_s3_class(p, "gg")
  })

  it("filters by hemisphere", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    p <- ggplot() + geom_brain_sf(atlas = dk(), hemi = "left")
    expect_s3_class(p, "gg")
    built <- ggplot_build(p)
    expect_true(all(built$plot$layers[[1]]$geom_params$hemi == "left"))
  })

  it("filters by view", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    p <- ggplot() + geom_brain_sf(atlas = dk(), view = "lateral")
    expect_s3_class(p, "gg")
  })

  it("works with position_brain", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    p <- ggplot() +
      geom_brain_sf(atlas = dk(), position = position_brain_sf(hemi ~ view))
    expect_s3_class(p, "gg")
  })

  it("works with aesthetic mapping", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    p <- ggplot() + geom_brain_sf(atlas = dk(), mapping = aes(fill = region))
    expect_s3_class(p, "gg")
  })

  it("works with user data", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    some_data <- tibble(
      region = sort(unique(ggseg.formats::atlas_regions(dk())))[1:2],
      p = c(0.1, 0.5)
    )
    p <- ggplot(some_data) +
      geom_brain_sf(atlas = dk(), mapping = aes(fill = p))
    expect_s3_class(p, "gg")
    expect_message(
      built <- ggplot_build(p),
      "Merging"
    )
    expect_gt(nrow(built$data[[1]]), 0)
  })

  it("works with show.legend FALSE", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    p <- ggplot() + geom_brain_sf(atlas = dk(), show.legend = FALSE)
    expect_s3_class(p, "gg")
  })

  it("works with inherit.aes FALSE", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    some_data <- tibble(
      region = sort(unique(ggseg.formats::atlas_regions(dk())))[1],
      p = 0.3
    )
    p <- ggplot(some_data, aes(fill = p)) +
      geom_brain_sf(atlas = dk(), inherit.aes = FALSE)
    expect_message(
      built <- ggplot_build(p),
      "Merging"
    )
    expect_s3_class(p, "gg")
  })

  it("passes additional arguments to geom_sf", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    p <- ggplot() +
      geom_brain_sf(atlas = dk(), colour = "black", size = 0.5)
    expect_s3_class(p, "gg")
  })

  it("works with aseg atlas", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    p <- ggplot() + geom_brain_sf(atlas = aseg())
    expect_s3_class(p, "gg")
  })
})

describe("geom_brain faceting", {
  some_data <- tibble(
    region = rep(sort(unique(ggseg.formats::atlas_regions(dk())))[1:4], 2),
    p = seq(0.1, 0.8, by = 0.1),
    group = c(rep("A", 4), rep("B", 4))
  )

  it("facet_wrap works without group_by", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    p <- ggplot(some_data) +
      geom_brain_sf(atlas = dk(), mapping = aes(fill = p)) +
      facet_wrap(~group)
    expect_message(
      built <- ggplot_build(p),
      "Merging"
    )
    panels <- unique(built$data[[1]]$PANEL)
    expect_length(panels, 2)
  })

  it("each facet panel has complete atlas rows", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    p <- ggplot(some_data) +
      geom_brain_sf(atlas = dk(), mapping = aes(fill = p)) +
      facet_wrap(~group)
    expect_message(
      built <- ggplot_build(p),
      "Merging"
    )
    atlas_rows <- nrow(as.data.frame(dk()))
    rows_per_panel <- tapply(
      built$data[[1]]$PANEL,
      built$data[[1]]$PANEL,
      length
    )
    expect_true(all(rows_per_panel == atlas_rows))
  })

  it("explicit group_by still works with facet_wrap", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    p <- some_data |>
      group_by(group) |>
      ggplot() +
      geom_brain_sf(atlas = dk(), mapping = aes(fill = p)) +
      facet_wrap(~group)
    expect_message(
      built <- ggplot_build(p),
      "Merging"
    )
    panels <- unique(built$data[[1]]$PANEL)
    expect_length(panels, 2)
  })

  it("facet_grid works without group_by", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    p <- ggplot(some_data) +
      geom_brain_sf(atlas = dk(), mapping = aes(fill = p)) +
      facet_grid(rows = vars(group))
    expect_message(
      built <- ggplot_build(p),
      "Merging"
    )
    panels <- unique(built$data[[1]]$PANEL)
    expect_length(panels, 2)
  })

  it("ignores atlas columns in facet vars", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    data_with_hemi <- tibble(
      region = sort(unique(ggseg.formats::atlas_regions(dk())))[1:2],
      p = c(0.1, 0.5),
      hemi = c("left", "right")
    )
    p <- ggplot(data_with_hemi) +
      geom_brain_sf(atlas = dk(), mapping = aes(fill = p)) +
      facet_wrap(~hemi)
    expect_message(
      built <- ggplot_build(p),
      "Merging"
    )
    expect_s3_class(p, "gg")
  })
})

describe("LayerBrainSf", {
  it("errors when no atlas is supplied", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    expect_error(
      ggplot_build(
        ggplot() +
          layer_brain_sf(
            geom = GeomBrainSf,
            stat = "sf",
            position = position_brain_sf(),
            params = list(na.rm = FALSE, atlas = NULL)
          ) +
          coord_sf()
      ),
      "No atlas supplied"
    )
  })

  it("errors when atlas has no data", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    empty_atlas <- atlas_without_2d_geometry()
    expect_error(
      ggplot_build(ggplot() + geom_brain_sf(atlas = empty_atlas)),
      "no data|no 2D geometry"
    )
  })

  it("errors on invalid hemisphere", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    expect_error(
      ggplot_build(ggplot() + geom_brain_sf(atlas = dk(), hemi = "top")),
      "Invalid hemisphere"
    )
  })

  it("errors on invalid view", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    expect_error(
      ggplot_build(ggplot() + geom_brain_sf(atlas = dk(), view = "top")),
      "Invalid view"
    )
  })

  it("warns on unmatched region data", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    bad_data <- tibble(
      region = "not a real region",
      p = 0.5
    )
    expect_warning(
      expect_message(
        ggplot_build(
          ggplot(bad_data) +
            geom_brain_sf(atlas = dk(), mapping = aes(fill = p))
        ),
        "Merging atlas and data"
      ),
      "not merged properly"
    )
  })

  it("renders atlas without user data (waiver)", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    p <- ggplot() + geom_brain_sf(atlas = dk())
    built <- ggplot_build(p)
    atlas_rows <- nrow(as.data.frame(dk()))
    expect_identical(nrow(built$data[[1]]), atlas_rows)
  })

  it("auto-maps geometry, hemi, view, type, fill, label", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    p <- ggplot() + geom_brain_sf(atlas = dk())
    built <- ggplot_build(p)
    expect_true("fill" %in% names(built$data[[1]]))
  })
})

describe("GeomBrainSf", {
  it("exists as ggproto object", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    expect_s3_class(GeomBrainSf, "Geom")
  })

  it("has default aesthetics", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    expect_true("default_aes" %in% names(GeomBrainSf))
    defaults <- GeomBrainSf$default_aes
    expect_true("linetype" %in% names(defaults))
    expect_true("stroke" %in% names(defaults))
  })

  it("has draw_panel method", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    expect_true("draw_panel" %in% names(GeomBrainSf))
  })

  it("has draw_key method", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    expect_true("draw_key" %in% names(GeomBrainSf))
  })
})

describe("brain_grob", {
  it("creates grob from transformed coord data", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    p <- ggplot() + geom_brain_sf(atlas = dk())
    built <- ggplot_build(p)
    gt <- ggplot_gtable(built)
    expect_s3_class(gt, "gtable")
  })
})


describe("geom_brain_sf() unmerged data", {
  it("warns once and drops the unmatched rows", {
    # The layer used to repeat brain_join()'s warning with a worse message,
    # via an emptiness test written as `length(!is.na(x)) > 0`.
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    dt <- data.frame(region = c("precentral", "not_a_region"), p = c(1, 2))
    p <- ggplot2::ggplot() +
      geom_brain_sf(atlas = dk(), data = dt, mapping = ggplot2::aes(fill = p))

    warns <- testthat::capture_warnings(
      suppressMessages(ggplot2::ggplot_build(p))
    )
    expect_length(grep("not merged", warns, fixed = TRUE), 1)
  })
})

describe("default atlas fill", {
  it("colours a bare geom_brain() with the atlas palette, keyed on label", {
    built <- ggplot_build(ggplot() + geom_brain(atlas = dk()))
    fills <- unique(built$data[[1]]$fill)
    palette <- ggseg.formats::atlas_palette(dk())

    expect_false(all(fills == "grey"))
    expect_true(all(setdiff(fills, "grey") %in% toupper(palette)))
    # ggplot2's hue ramp would be as many distinct colours as there are
    # labels; the dk palette shares a colour between hemispheres.
    expect_lt(length(fills), length(palette))
  })

  it("maps fill to label, not region", {
    built <- ggplot_build(ggplot() + geom_brain(atlas = dk()))
    mapping <- built$plot$layers[[1]]$computed_mapping
    expect_identical(
      rlang::as_label(mapping$fill),
      "ggplot2::after_stat(label)"
    )
  })

  it("colours by label even when data carries no label column", {
    dt <- data.frame(
      region = sort(unique(ggseg.formats::atlas_regions(dk())))[1:3],
      w = c(0.5, 1.5, 3)
    )
    built <- ggplot_build(
      ggplot(dt) + geom_brain(atlas = dk(), mapping = aes(linewidth = w))
    )
    fills <- unique(built$data[[1]]$fill)
    expect_gt(length(fills), 1)
    expect_true(all(
      setdiff(fills, "grey") %in%
        toupper(
          ggseg.formats::atlas_palette(dk())
        )
    ))
  })

  it("leaves an explicit layer fill mapping alone", {
    built <- ggplot_build(
      ggplot() + geom_brain(atlas = dk(), mapping = aes(fill = region))
    )
    mapping <- built$plot$layers[[1]]$computed_mapping
    expect_identical(rlang::as_label(mapping$fill), "region")
    expect_false(any(
      built$data[[1]]$fill %in%
        ggseg.formats::atlas_palette(
          dk()
        )
    ))
  })

  it("leaves a top-level fill mapping alone", {
    dt <- data.frame(
      label = ggseg.formats::atlas_labels(dk())[1:3],
      value = c(1, 2, 3)
    )
    built <- ggplot_build(
      ggplot(dt, aes(fill = value)) + geom_brain(atlas = dk(), data = dt)
    )
    mapping <- built$plot$layers[[1]]$computed_mapping
    expect_identical(rlang::as_label(mapping$fill), "value")
    expect_s3_class(built$plot$scales$get_scales("fill"), "ScaleContinuous")
  })

  it("leaves a fixed fill parameter alone", {
    built <- ggplot_build(ggplot() + geom_brain(atlas = dk(), fill = "red"))
    expect_null(built$plot$layers[[1]]$computed_mapping$fill)
    expect_true(all(built$data[[1]]$fill == "red"))
  })

  it("does not fill by label when the user maps colour", {
    built <- ggplot_build(
      ggplot() + geom_brain(atlas = dk(), mapping = aes(colour = region))
    )
    expect_null(built$plot$layers[[1]]$computed_mapping$fill)
    expect_true(all(built$data[[1]]$fill == "grey"))
  })

  it("leaves an explicit scale_fill_*() in charge", {
    built <- ggplot_build(
      ggplot() +
        geom_brain(atlas = dk(), mapping = aes(fill = label)) +
        scale_fill_manual(values = c(lh_bankssts = "red"), na.value = "white")
    )
    expect_true("white" %in% built$data[[1]]$fill)
  })

  it("installs no scale, so no fill mapping, for a palette-less atlas", {
    atlas <- atlas_without_2d_geometry()
    expect_null(ggseg.formats::atlas_palette(atlas))
    expect_false(add_atlas_fill_scale(ggplot(), atlas))
  })

  it("asks for the default only when neither fill nor colour is supplied", {
    expect_true(needs_default_atlas_fill(aes(), list()))
    expect_false(needs_default_atlas_fill(aes(fill = region), list()))
    expect_false(needs_default_atlas_fill(aes(colour = region), list()))
    expect_false(needs_default_atlas_fill(aes(), list(fill = "red")))
    expect_false(needs_default_atlas_fill(aes(), list(colour = "red")))
    expect_true(needs_default_atlas_fill(aes(alpha = region), list()))
  })
})
