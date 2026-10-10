describe("scale_brain", {
  it("returns a scale for fill by default", {
    lifecycle::expect_deprecated(scale <- scale_brain())
    expect_s3_class(scale, "Scale")
    expect_identical(scale$aesthetics, "fill")
  })

  it("returns a scale for colour", {
    lifecycle::expect_deprecated(scale <- scale_brain(aesthetics = "colour"))
    expect_s3_class(scale, "Scale")
    expect_identical(scale$aesthetics, "colour")
  })

  it("returns a scale for color (aliased to colour)", {
    lifecycle::expect_deprecated(scale <- scale_brain(aesthetics = "color"))
    expect_s3_class(scale, "Scale")
    expect_identical(scale$aesthetics, "colour")
  })

  it("uses custom na.value", {
    lifecycle::expect_deprecated(scale <- scale_brain(na.value = "red"))
    expect_identical(scale$na.value, "red")
  })

  it("accepts atlas name argument", {
    lifecycle::expect_deprecated(scale <- scale_brain(name = "dk"))
    expect_s3_class(scale, "Scale")
  })
})

describe("scale_colour_brain", {
  it("returns a colour scale", {
    lifecycle::expect_deprecated(scale <- scale_colour_brain())
    expect_s3_class(scale, "Scale")
    expect_identical(scale$aesthetics, "colour")
  })
})

describe("scale_color_brain", {
  it("returns a color scale (aliased to colour)", {
    lifecycle::expect_deprecated(scale <- scale_color_brain())
    expect_s3_class(scale, "Scale")
    expect_identical(scale$aesthetics, "colour")
  })
})

describe("scale_fill_brain", {
  it("returns a fill scale", {
    lifecycle::expect_deprecated(scale <- scale_fill_brain())
    expect_s3_class(scale, "Scale")
    expect_identical(scale$aesthetics, "fill")
  })
})

describe("scale_brain_manual", {
  pal <- c("region1" = "#FF0000", "region2" = "#00FF00")

  it("returns a scale for fill by default with custom palette", {
    scale <- scale_brain_manual(palette = pal)
    expect_s3_class(scale, "Scale")
    expect_identical(scale$aesthetics, "fill")
  })

  it("returns a scale for colour", {
    scale <- scale_brain_manual(palette = pal, aesthetics = "colour")
    expect_s3_class(scale, "Scale")
    expect_identical(scale$aesthetics, "colour")
  })

  it("returns a scale for color (aliased to colour)", {
    scale <- scale_brain_manual(palette = pal, aesthetics = "color")
    expect_s3_class(scale, "Scale")
    expect_identical(scale$aesthetics, "colour")
  })

  it("uses custom na.value", {
    scale <- scale_brain_manual(palette = pal, na.value = "blue")
    expect_identical(scale$na.value, "blue")
  })
})

describe("scale_colour_brain_manual", {
  it("returns a colour scale", {
    pal <- c("region1" = "#FF0000")
    scale <- scale_colour_brain_manual(palette = pal)
    expect_s3_class(scale, "Scale")
    expect_identical(scale$aesthetics, "colour")
  })
})

describe("scale_color_brain_manual", {
  it("returns a color scale (aliased to colour)", {
    pal <- c("region1" = "#FF0000")
    scale <- scale_color_brain_manual(palette = pal)
    expect_s3_class(scale, "Scale")
    expect_identical(scale$aesthetics, "colour")
  })
})

describe("scale_fill_brain_manual", {
  it("returns a fill scale", {
    pal <- c("region1" = "#FF0000")
    scale <- scale_fill_brain_manual(palette = pal)
    expect_s3_class(scale, "Scale")
    expect_identical(scale$aesthetics, "fill")
  })
})

describe("deprecated scale_brain2 variants", {
  pal <- c("region1" = "#FF0000", "region2" = "#00FF00")

  it("scale_brain2 warns and delegates", {
    lifecycle::expect_deprecated(scale_brain2(palette = pal))
  })

  it("scale_fill_brain2 warns and delegates", {
    lifecycle::expect_deprecated(scale_fill_brain2(palette = pal))
  })

  it("scale_colour_brain2 warns and delegates", {
    lifecycle::expect_deprecated(scale_colour_brain2(palette = pal))
  })

  it("scale_color_brain2 warns and delegates", {
    lifecycle::expect_deprecated(scale_color_brain2(palette = pal))
  })
})

describe("scale_continous_brain", {
  it("returns y scale by default", {
    skip_if_not_installed("sf")
    atlas <- unnest(sf2coords(as.data.frame(dk())), ggseg)
    scale <- scale_continous_brain(atlas = atlas)
    expect_s3_class(scale, "Scale")
  })

  it("returns x scale", {
    skip_if_not_installed("sf")
    atlas <- unnest(sf2coords(as.data.frame(dk())), ggseg)
    scale <- scale_continous_brain(atlas = atlas, aesthetics = "x")
    expect_s3_class(scale, "Scale")
  })
})

describe("scale_x_brain", {
  it("returns x scale", {
    skip_if_not_installed("sf")
    dk_df <- as.data.frame(dk())
    dk_coords <- sf2coords(dk_df)
    atlas <- unnest(dk_coords, ggseg)
    scale <- scale_x_brain(atlas = atlas)
    expect_s3_class(scale, "Scale")
  })
})

describe("scale_y_brain", {
  it("returns y scale", {
    skip_if_not_installed("sf")
    dk_df <- as.data.frame(dk())
    dk_coords <- sf2coords(dk_df)
    atlas <- unnest(dk_coords, ggseg)
    scale <- scale_y_brain(atlas = atlas)
    expect_s3_class(scale, "Scale")
  })
})

describe("scale_labs_brain", {
  it("returns labs scale", {
    skip_if_not_installed("sf")
    dk_df <- as.data.frame(dk())
    dk_coords <- sf2coords(dk_df)
    atlas <- unnest(dk_coords, ggseg)
    scale <- scale_labs_brain(atlas = atlas)
    expect_s3_class(scale, "gg")
  })
})

describe("scale_continous_brain", {
  it("resolves the y scale at its default aesthetics", {
    # `aesthetics = c("y", "x")` used to reach adapt_scales() unmatched, where
    # the vector turned the terminal `[[` into recursive indexing and silently
    # yielded NULL. The default must behave exactly like scale_y_brain().
    expect_identical(
      scale_continous_brain(dk(), position = "stacked")$breaks,
      scale_y_brain(position = "stacked")$breaks
    )
    expect_false(is.null(scale_continous_brain(dk(), "stacked")$breaks))
    expect_false(is.null(scale_continous_brain(dk(), "stacked")$labels))
  })

  it("matches scale_y_brain() for the dispersed default", {
    expect_identical(scale_continous_brain(dk())$breaks, scale_y_brain()$breaks)
    expect_true("y" %in% scale_continous_brain(dk())$aesthetics)
  })

  it("produces non-empty axis scales for a cerebellar atlas", {
    expect_false(is.null(scale_x_brain(atlas = suit())$breaks))
    expect_false(is.null(scale_labs_brain(atlas = suit())$x))
  })
})


describe("atlas_palette_by_name()", {
  it("rejects a name that is some other visible function", {
    # match.fun() resolved anything, so scale_brain("mean") failed inside
    # mean.default with no mention of atlases.
    expect_error(atlas_palette_by_name("mean"), "brain atlas function")
    expect_error(atlas_palette_by_name("mean"), "dk")
  })

  it("rejects a name that resolves to nothing", {
    expect_error(atlas_palette_by_name("no_such_atlas"), "brain atlas function")
    expect_error(atlas_palette_by_name(1L), "brain atlas function")
  })

  it("resolves a bundled atlas", {
    expect_type(atlas_palette_by_name("dk"), "character")
  })

  it("returns a label-keyed palette", {
    # `label` is the ecosystem's canonical key; the palette is keyed by it.
    pal <- atlas_palette_by_name("dk")
    expect_true(all(names(pal) %in% ggseg.formats::atlas_labels(dk())))
  })
})


describe("warn_palette_key_mismatch()", {
  it("warns when no mapped value is a palette key", {
    expect_warning(
      warn_palette_key_mismatch("bankssts", c(lh_bankssts = "red"), "fill"),
      class = "ggseg_palette_key_mismatch"
    )
  })

  it("names label as the mapping that works", {
    expect_warning(
      warn_palette_key_mismatch("bankssts", c(lh_bankssts = "red"), "fill"),
      "aes\\(fill = label\\)"
    )
  })

  it("is silent when a mapped value matches", {
    expect_no_warning(
      warn_palette_key_mismatch("lh_bankssts", c(lh_bankssts = "red"), "fill")
    )
    expect_no_warning(warn_palette_key_mismatch(NA, c(a = "red"), "fill"))
  })

  it("fires at build time for a region-mapped deprecated scale", {
    # aes(fill = region) with a label-keyed palette greyed the whole plot
    # with no signal at all.
    withr::local_options(lifecycle_verbosity = "quiet")
    p <- ggplot2::ggplot() +
      geom_brain(
        atlas = dk(),
        ggplot2::aes(fill = region),
        show.legend = FALSE
      ) +
      scale_fill_brain("dk")
    expect_warning(
      muffle_breaking_warnings(ggplot2::ggplot_build(p)),
      class = "ggseg_palette_key_mismatch"
    )
  })

  it("stays silent for a label-mapped deprecated scale", {
    withr::local_options(lifecycle_verbosity = "quiet")
    p <- ggplot2::ggplot() +
      geom_brain(
        atlas = dk(),
        ggplot2::aes(fill = label),
        show.legend = FALSE
      ) +
      scale_fill_brain("dk")
    built <- muffle_breaking_warnings(ggplot2::ggplot_build(p))
    expect_gt(length(unique(built$data[[1]]$fill)), 2)
  })
})
