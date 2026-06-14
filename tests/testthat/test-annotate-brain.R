describe("extract_position_params", {
  it("extracts from PositionBrain object", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    pos <- position_brain_sf(hemi ~ view, nrow = 2, ncol = 3, views = "lateral")
    params <- extract_position_params(pos)
    expect_identical(params$position, hemi ~ view)
    expect_identical(params$nrow, 2)
    expect_identical(params$ncol, 3)
    expect_identical(params$views, "lateral")
  })

  it("wraps raw string position", {
    params <- extract_position_params("horizontal")
    expect_identical(params$position, "horizontal")
    expect_null(params$nrow)
    expect_null(params$ncol)
    expect_null(params$views)
  })

  it("wraps raw formula position", {
    params <- extract_position_params(hemi ~ view)
    expect_identical(params$position, hemi ~ view)
    expect_null(params$nrow)
  })
})

describe("compute_label_positions", {
  it("produces hemi + view labels for cortical", {
    skip_if_not_installed("sf")
    repositioned <- reposition_brain(dk(), hemi ~ view)
    label_df <- compute_label_positions(repositioned)

    expect_s3_class(label_df, "data.frame")
    expect_named(label_df, c("x", "y", "label"))
    dk_df <- as.data.frame(dk())
    n_combos <- length(unique(paste(dk_df$hemi, dk_df$view)))
    expect_identical(nrow(label_df), n_combos)
    expect_true(all(
      c("left lateral", "left medial", "right lateral", "right medial") %in%
        label_df$label
    ))
  })

  it("produces view labels for subcortical", {
    skip_if_not_installed("sf")
    repositioned <- reposition_brain(aseg())
    label_df <- compute_label_positions(repositioned)

    expect_s3_class(label_df, "data.frame")
    views <- unique(as.data.frame(aseg())$view)
    expect_identical(nrow(label_df), length(views))
    expect_true(all(views %in% label_df$label))
  })

  it("produces view labels for tract", {
    skip_if_not_installed("sf")
    repositioned <- reposition_brain(tracula())
    label_df <- compute_label_positions(repositioned)

    views <- unique(as.data.frame(tracula())$view)
    expect_identical(nrow(label_df), length(views))
    expect_true(all(views %in% label_df$label))
  })
})

describe("annotate_brain dispatch", {
  it("returns a polygon-path layer by default", {
    layer <- annotate_brain(atlas = dk())
    expect_s3_class(layer, "LayerInstance")
  })

  it("pairs with geom_brain_polygon() by default", {
    p <- ggplot() +
      geom_brain_polygon(atlas = dk(), show.legend = FALSE) +
      annotate_brain(atlas = dk())
    expect_silent(ggplot2::ggplot_build(p))
  })

  it("routes to the sf path when given a position_brain_sf()", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    layer <- annotate_brain(atlas = dk(), position = position_brain_sf())
    expect_s3_class(layer, "LayerInstance")
  })
})

describe("annotate_brain (polygon path)", {
  it("returns an annotation layer", {
    layer <- annotate_brain(atlas = dk(), position = position_brain())
    expect_s3_class(layer, "LayerInstance")
  })

  it("builds a valid plot with cortical atlas", {
    p <- ggplot() +
      geom_brain(atlas = dk(), show.legend = FALSE) +
      annotate_brain(atlas = dk(), position = position_brain())
    expect_s3_class(p, "gg")
    expect_silent(ggplot2::ggplot_build(p))
  })

  it("builds a valid plot with subcortical atlas", {
    p <- ggplot() +
      geom_brain(atlas = aseg(), show.legend = FALSE) +
      annotate_brain(atlas = aseg(), position = position_brain())
    expect_s3_class(p, "gg")
    expect_silent(ggplot2::ggplot_build(p))
  })

  it("respects hemi filtering", {
    layer <- annotate_brain(
      atlas = dk(),
      hemi = "left",
      position = position_brain()
    )
    built <- ggplot() +
      geom_brain(atlas = dk(), hemi = "left", show.legend = FALSE) +
      layer
    bd <- ggplot2::ggplot_build(built)
    labels <- bd$data[[2]]$label
    expect_true(all(grepl("^left", labels)))
  })

  it("respects view filtering", {
    layer <- annotate_brain(
      atlas = dk(),
      view = "lateral",
      position = position_brain()
    )
    built <- ggplot() +
      geom_brain(atlas = dk(), view = "lateral", show.legend = FALSE) +
      layer
    bd <- ggplot2::ggplot_build(built)
    labels <- bd$data[[2]]$label
    expect_true(all(grepl("lateral$", labels)))
  })

  it("works with position formula", {
    p <- ggplot() +
      geom_brain(
        atlas = dk(),
        position = position_brain(hemi ~ view),
        show.legend = FALSE
      ) +
      annotate_brain(
        atlas = dk(),
        position = position_brain(hemi ~ view)
      )
    expect_silent(ggplot2::ggplot_build(p))
  })

  it("works with nrow/ncol for subcortical", {
    p <- ggplot() +
      geom_brain(
        atlas = aseg(),
        position = position_brain(nrow = 2),
        show.legend = FALSE
      ) +
      annotate_brain(
        atlas = aseg(),
        position = position_brain(nrow = 2)
      )
    expect_silent(ggplot2::ggplot_build(p))
  })

  it("passes styling arguments", {
    layer <- annotate_brain(
      atlas = dk(),
      position = position_brain(),
      size = 5,
      colour = "red",
      fontface = "bold"
    )
    expect_s3_class(layer, "LayerInstance")
  })
})

describe("annotate_brain visual", {
  it("dk default with labels", {
    expect_doppelganger(
      "dk default labels",
      ggplot() +
        geom_brain(atlas = dk(), show.legend = FALSE) +
        annotate_brain(atlas = dk(), position = position_brain())
    )
  })

  it("dk hemi ~ view with labels", {
    expect_doppelganger(
      "dk hemi view labels",
      ggplot() +
        geom_brain(
          atlas = dk(),
          position = position_brain(hemi ~ view),
          show.legend = FALSE
        ) +
        annotate_brain(
          atlas = dk(),
          position = position_brain(hemi ~ view)
        )
    )
  })

  it("aseg default with labels", {
    expect_doppelganger(
      "aseg default labels",
      ggplot() +
        geom_brain(atlas = aseg(), show.legend = FALSE) +
        annotate_brain(atlas = aseg(), position = position_brain())
    )
  })

  it("aseg nrow 2 with labels", {
    expect_doppelganger(
      "aseg nrow 2 labels",
      ggplot() +
        geom_brain(
          atlas = aseg(),
          position = position_brain(nrow = 2),
          show.legend = FALSE
        ) +
        annotate_brain(
          atlas = aseg(),
          position = position_brain(nrow = 2)
        )
    )
  })
})
