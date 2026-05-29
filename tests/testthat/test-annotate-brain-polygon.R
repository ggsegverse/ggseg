describe("annotate_brain_polygon()", {
  it("returns a ggplot2 annotation layer", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    pos <- position_brain_polygon(hemi ~ view)
    ann <- annotate_brain_polygon(atlas = poly, position = pos)
    expect_s3_class(ann, "Layer")
  })

  it("renders with geom_brain_polygon to produce labelled views", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    pos <- position_brain_polygon(hemi ~ view)
    p <- ggplot2::ggplot() +
      geom_brain_polygon(atlas = poly, position = pos, show.legend = FALSE) +
      annotate_brain_polygon(atlas = poly, position = pos)
    g <- ggplot2::ggplot_build(p)
    expect_gte(length(g$data), 2L)
    expect_gt(nrow(g$data[[1]]), 0)
  })

  it("filters by hemi", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    pos <- position_brain_polygon(hemi ~ view)
    p <- ggplot2::ggplot() +
      geom_brain_polygon(
        atlas = poly,
        position = pos,
        hemi = "left",
        show.legend = FALSE
      ) +
      annotate_brain_polygon(atlas = poly, position = pos, hemi = "left")
    g <- ggplot2::ggplot_build(p)
    expect_true(all(g$data[[1]]$hemi == "left" | is.na(g$data[[1]]$hemi)))
  })

  it("works for subcortical aseg", {
    poly_aseg <- ggseg.formats::as_polygon_atlas(aseg())
    p <- ggplot2::ggplot() +
      geom_brain_polygon(atlas = poly_aseg, show.legend = FALSE) +
      annotate_brain_polygon(atlas = poly_aseg)
    expect_no_error(ggplot2::ggplot_build(p))
  })
})

describe("compute_label_positions_flat()", {
  it("produces one row per (hemi, view) for cortical atlases", {
    poly <- ggseg.formats::as_polygon_atlas(dk())
    flat <- prepare_polygon_atlas(
      poly,
      position = position_brain_polygon(hemi ~ view)
    )
    labels <- compute_label_positions_flat(flat)
    expect_true(all(c("x", "y", "label") %in% names(labels)))
    expect_gt(nrow(labels), 1)
  })

  it("produces one row per view for subcortical atlases", {
    poly_aseg <- ggseg.formats::as_polygon_atlas(aseg())
    flat <- prepare_polygon_atlas(poly_aseg)
    labels <- compute_label_positions_flat(flat)
    expect_equal(nrow(labels), length(unique(flat$view)))
  })
})
