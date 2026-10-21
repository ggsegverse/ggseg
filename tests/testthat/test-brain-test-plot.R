describe("brain_test_plot()", {
  it("returns a ggplot object", {
    p <- brain_test_plot(dk())
    expect_s3_class(p, "ggplot")
  })

  it("draws no legend, so snapshots stay text-free", {
    gt <- ggplot2::ggplotGrob(brain_test_plot(dk()))
    guide_boxes <- gt$grobs[grepl("guide-box", gt$layout$name, fixed = TRUE)]
    expect_true(all(vapply(
      guide_boxes,
      inherits,
      logical(1),
      what = "zeroGrob"
    )))
  })

  it("applies the atlas palette when present", {
    p <- brain_test_plot(dk())
    expect_false(is.null(p$scales$get_scales("fill")))
  })

  it("omits the manual fill scale when the atlas has no palette", {
    atlas <- dk()
    atlas$palette <- NULL
    p <- brain_test_plot(atlas)
    expect_null(p$scales$get_scales("fill"))
  })

  it("errors on a non-atlas input", {
    expect_error(brain_test_plot(1), "ggseg_atlas")
  })

  it("says why an atlas with a stale core is rejected", {
    atlas <- dk()
    atlas$core$hemi[1] <- "vermis"

    expect_error(
      brain_test_plot(atlas),
      class = "ggseg.formats_invalid_atlas"
    )
    expect_error(brain_test_plot(atlas), "vermis")
  })

  it("lays out slice-based atlases by view without a hemi warning", {
    expect_no_warning(ggplot2::ggplot_build(brain_test_plot(aseg())))
  })

  it("keeps the slice-based layout that hemi ~ view resolves to", {
    by_view <- ggplot2::layer_data(brain_test_plot(aseg()))
    by_hemi_and_view <- suppressWarnings(ggplot2::layer_data(
      brain_test_plot(aseg(), position = position_brain(hemi ~ view))
    ))

    expect_identical(by_view, by_hemi_and_view)
  })
})
