describe("geom_brain", {
  it("works with basic atlas", {
    p <- ggplot() + geom_brain(atlas = dk)
    expect_s3_class(p, "gg")
  })

  it("warns when deprecated side argument is used", {
    expect_warning(
      ggplot() + geom_brain(atlas = dk, side = "lateral"),
      "side.*deprecated"
    )
  })

  it("uses side value for view when view is NULL", {
    expect_warning(
      p <- ggplot() + geom_brain(atlas = dk, side = "lateral"),
      "side.*deprecated"
    )
    expect_s3_class(p, "gg")
  })

  it("filters by hemisphere", {
    p <- ggplot() + geom_brain(atlas = dk, hemi = "left")
    expect_s3_class(p, "gg")
    built <- ggplot_build(p)
    expect_true(all(built$plot$layers[[1]]$geom_params$hemi == "left"))
  })

  it("filters by view", {
    p <- ggplot() + geom_brain(atlas = dk, view = "lateral")
    expect_s3_class(p, "gg")
  })

  it("works with position_brain", {
    p <- ggplot() +
      geom_brain(atlas = dk, position = position_brain(hemi ~ view))
    expect_s3_class(p, "gg")
  })

  it("works with aesthetic mapping", {
    p <- ggplot() + geom_brain(atlas = dk, mapping = aes(fill = region))
    expect_s3_class(p, "gg")
  })

  it("works with user data", {
    some_data <- tibble(
      region = c("transverse temporal", "insula"),
      p = c(0.1, 0.5)
    )
    p <- ggplot(some_data) +
      geom_brain(atlas = dk, mapping = aes(fill = p))
    expect_s3_class(p, "gg")
    expect_message(
      built <- ggplot_build(p),
      "Merging"
    )
    expect_true(nrow(built$data[[1]]) > 0)
  })

  it("works with show.legend FALSE", {
    p <- ggplot() + geom_brain(atlas = dk, show.legend = FALSE)
    expect_s3_class(p, "gg")
  })

  it("works with inherit.aes FALSE", {
    some_data <- tibble(region = "insula", p = 0.3)
    p <- ggplot(some_data, aes(fill = p)) +
      geom_brain(atlas = dk, inherit.aes = FALSE)
    expect_message(
      built <- ggplot_build(p),
      "Merging"
    )
    expect_s3_class(p, "gg")
  })

  it("passes additional arguments to geom_sf", {
    p <- ggplot() +
      geom_brain(atlas = dk, colour = "black", size = 0.5)
    expect_s3_class(p, "gg")
  })

  it("works with aseg atlas", {
    p <- ggplot() + geom_brain(atlas = aseg)
    expect_s3_class(p, "gg")
  })
})

describe("geom_brain faceting", {
  some_data <- tibble(
    region = rep(
      c("transverse temporal", "insula", "precentral", "superior parietal"),
      2
    ),
    p = seq(0.1, 0.8, by = 0.1),
    group = c(rep("A", 4), rep("B", 4))
  )

  it("facet_wrap works without group_by", {
    p <- ggplot(some_data) +
      geom_brain(atlas = dk, mapping = aes(fill = p)) +
      facet_wrap(~group)
    expect_message(
      built <- ggplot_build(p),
      "Merging"
    )
    panels <- unique(built$data[[1]]$PANEL)
    expect_equal(length(panels), 2)
  })

  it("each facet panel has complete atlas rows", {
    p <- ggplot(some_data) +
      geom_brain(atlas = dk, mapping = aes(fill = p)) +
      facet_wrap(~group)
    expect_message(
      built <- ggplot_build(p),
      "Merging"
    )
    atlas_rows <- nrow(as.data.frame(dk))
    rows_per_panel <- tapply(
      built$data[[1]]$PANEL,
      built$data[[1]]$PANEL,
      length
    )
    expect_true(all(rows_per_panel == atlas_rows))
  })

  it("explicit group_by still works with facet_wrap", {
    p <- some_data |>
      group_by(group) |>
      ggplot() +
      geom_brain(atlas = dk, mapping = aes(fill = p)) +
      facet_wrap(~group)
    expect_message(
      built <- ggplot_build(p),
      "Merging"
    )
    panels <- unique(built$data[[1]]$PANEL)
    expect_equal(length(panels), 2)
  })

  it("facet_grid works without group_by", {
    p <- ggplot(some_data) +
      geom_brain(atlas = dk, mapping = aes(fill = p)) +
      facet_grid(rows = vars(group))
    expect_message(
      built <- ggplot_build(p),
      "Merging"
    )
    panels <- unique(built$data[[1]]$PANEL)
    expect_equal(length(panels), 2)
  })

  it("ignores atlas columns in facet vars", {
    data_with_hemi <- tibble(
      region = c("transverse temporal", "insula"),
      p = c(0.1, 0.5),
      hemi = c("left", "right")
    )
    p <- ggplot(data_with_hemi) +
      geom_brain(atlas = dk, mapping = aes(fill = p)) +
      facet_wrap(~hemi)
    expect_message(
      built <- ggplot_build(p),
      "Merging"
    )
    expect_s3_class(p, "gg")
  })
})

describe("LayerBrain", {
  it("errors when no atlas is supplied", {
    expect_error(
      ggplot_build(
        ggplot() +
          layer_brain(
            geom = GeomBrain,
            stat = "sf",
            position = position_brain(),
            params = list(na.rm = FALSE, atlas = NULL)
          ) +
          coord_sf()
      ),
      "No atlas supplied"
    )
  })

  it("errors when atlas has no data", {
    empty_atlas <- dk
    empty_atlas$data$sf <- empty_atlas$data$sf[0, ]
    expect_error(
      ggplot_build(ggplot() + geom_brain(atlas = empty_atlas)),
      "no data|no 2D geometry"
    )
  })

  it("errors on invalid hemisphere", {
    expect_error(
      ggplot_build(ggplot() + geom_brain(atlas = dk, hemi = "top")),
      "Invalid hemisphere"
    )
  })

  it("errors on invalid view", {
    expect_error(
      ggplot_build(ggplot() + geom_brain(atlas = dk, view = "top")),
      "Invalid view"
    )
  })

  it("warns on unmatched region data", {
    bad_data <- tibble(
      region = c("not a real region"),
      p = 0.5
    )
    expect_warning(
      expect_warning(
        ggplot_build(
          ggplot(bad_data) + geom_brain(atlas = dk, mapping = aes(fill = p))
        ),
        "not merged properly"
      ),
      "not merged"
    )
  })

  it("renders atlas without user data (waiver)", {
    p <- ggplot() + geom_brain(atlas = dk)
    built <- ggplot_build(p)
    atlas_rows <- nrow(as.data.frame(dk))
    expect_equal(nrow(built$data[[1]]), atlas_rows)
  })

  it("auto-maps geometry, hemi, view, type, fill, label", {
    p <- ggplot() + geom_brain(atlas = dk)
    built <- ggplot_build(p)
    expect_true("fill" %in% names(built$data[[1]]))
  })
})

describe("GeomBrain", {
  it("exists as ggproto object", {
    expect_s3_class(GeomBrain, "Geom")
  })

  it("has default aesthetics", {
    expect_true("default_aes" %in% names(GeomBrain))
    defaults <- GeomBrain$default_aes
    expect_true("linetype" %in% names(defaults))
    expect_true("stroke" %in% names(defaults))
  })

  it("has draw_panel method", {
    expect_true("draw_panel" %in% names(GeomBrain))
  })

  it("has draw_key method", {
    expect_true("draw_key" %in% names(GeomBrain))
  })
})

describe("brain_grob", {
  it("creates grob from transformed coord data", {
    p <- ggplot() + geom_brain(atlas = dk)
    built <- ggplot_build(p)
    gt <- ggplot_gtable(built)
    expect_s3_class(gt, "gtable")
  })
})
