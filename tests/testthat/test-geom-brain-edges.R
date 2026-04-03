describe("geom_brain_edges", {
  it("works with basic atlas and edge_group", {
    p <- ggplot() +
      geom_brain_edges(atlas = dk(), edge_group = "lobe")
    expect_s3_class(p, "gg")
  })

  it("works as overlay on geom_brain", {
    p <- ggplot() +
      geom_brain(atlas = dk(), aes(fill = region), show.legend = FALSE) +
      geom_brain_edges(atlas = dk(), edge_group = "lobe")
    expect_s3_class(p, "gg")
    built <- ggplot_build(p)
    expect_equal(length(built$data), 2)
  })

  it("works with position_brain", {
    pos <- position_brain(hemi ~ view)
    p <- ggplot() +
      geom_brain(atlas = dk(), position = pos, show.legend = FALSE) +
      geom_brain_edges(atlas = dk(), edge_group = "lobe", position = pos)
    expect_s3_class(p, "gg")
  })

  it("auto-maps colour to edge_group", {
    p <- ggplot() +
      geom_brain_edges(atlas = dk(), edge_group = "lobe")
    built <- ggplot_build(p)
    expect_true("colour" %in% names(built$data[[1]]))
  })

  it("respects fixed colour override", {
    p <- ggplot() +
      geom_brain_edges(atlas = dk(), edge_group = "lobe", colour = "red")
    built <- ggplot_build(p)
    expect_true(all(built$data[[1]]$colour == "red"))
  })

  it("respects colour aesthetic mapping", {
    p <- ggplot() +
      geom_brain_edges(
        atlas = dk(), edge_group = "lobe",
        mapping = aes(colour = lobe)
      )
    built <- ggplot_build(p)
    n_colours <- length(unique(built$data[[1]]$colour))
    expect_true(n_colours > 1)
  })

  it("fills are NA by default", {
    p <- ggplot() +
      geom_brain_edges(atlas = dk(), edge_group = "lobe", colour = "black")
    built <- ggplot_build(p)
    expect_true(all(is.na(built$data[[1]]$fill)))
  })

  it("filters by hemisphere", {
    p <- ggplot() +
      geom_brain_edges(atlas = dk(), edge_group = "lobe", hemi = "left")
    built <- ggplot_build(p)
    expect_true(all(built$data[[1]]$hemi == "left"))
  })

  it("filters by view", {
    p <- ggplot() +
      geom_brain_edges(atlas = dk(), edge_group = "lobe", view = "lateral")
    built <- ggplot_build(p)
    expect_true(all(built$data[[1]]$view == "lateral"))
  })

  it("accepts custom buffer distance", {
    p <- ggplot() +
      geom_brain_edges(atlas = dk(), edge_group = "lobe", buffer = 1)
    expect_s3_class(p, "gg")
    built <- ggplot_build(p)
    expect_true(nrow(built$data[[1]]) > 0)
  })

  it("reduces row count via dissolve", {
    atlas_rows <- nrow(as.data.frame(dk()))
    p <- ggplot() +
      geom_brain_edges(atlas = dk(), edge_group = "lobe")
    built <- ggplot_build(p)
    expect_true(nrow(built$data[[1]]) < atlas_rows)
  })
})

describe("LayerBrainEdges", {
  it("errors when no atlas is supplied", {
    expect_error(
      ggplot_build(
        ggplot() +
          layer_brain_edges(
            geom = GeomBrainEdges,
            stat = "sf",
            position = position_brain(),
            params = list(
              na.rm = FALSE, atlas = NULL,
              edge_group = "lobe", buffer = NULL
            )
          ) +
          coord_sf()
      ),
      "No atlas supplied"
    )
  })

  it("errors when edge_group column not in atlas", {
    expect_error(
      ggplot_build(
        ggplot() +
          geom_brain_edges(atlas = dk(), edge_group = "nonexistent")
      ),
      "not found in atlas"
    )
  })

  it("errors when edge_group is not a string", {
    expect_error(
      ggplot_build(
        ggplot() +
          geom_brain_edges(atlas = dk(), edge_group = 42)
      ),
      "single column name"
    )
  })

  it("errors on invalid hemisphere", {
    expect_error(
      ggplot_build(
        ggplot() +
          geom_brain_edges(atlas = dk(), edge_group = "lobe", hemi = "top")
      ),
      "Invalid hemisphere"
    )
  })

  it("errors on invalid view", {
    expect_error(
      ggplot_build(
        ggplot() +
          geom_brain_edges(atlas = dk(), edge_group = "lobe", view = "top")
      ),
      "Invalid view"
    )
  })
})

describe("GeomBrainEdges", {
  it("exists as ggproto object", {
    expect_s3_class(GeomBrainEdges, "Geom")
  })

  it("inherits from GeomBrain", {
    expect_true(inherits(GeomBrainEdges, "GeomBrain"))
  })

  it("has outline-friendly defaults", {
    defaults <- GeomBrainEdges$default_aes
    expect_true(is.na(defaults$fill))
    expect_equal(defaults$colour, "black")
  })
})

describe("geom_brain_edges visual", {
  it("dk-lobe-edges", {
    p <- ggplot() +
      geom_brain(atlas = dk(), aes(fill = region), show.legend = FALSE) +
      geom_brain_edges(atlas = dk(), edge_group = "lobe", colour = "black") +
      theme_brain()
    vdiffr::expect_doppelganger("dk-lobe-edges", p)
  })

  it("dk-lobe-edges-coloured", {
    p <- ggplot() +
      geom_brain(atlas = dk(), show.legend = FALSE) +
      geom_brain_edges(atlas = dk(), edge_group = "lobe") +
      theme_brain()
    vdiffr::expect_doppelganger("dk-lobe-edges-coloured", p)
  })

  it("dk-lobe-edges-positioned", {
    pos <- position_brain(hemi ~ view)
    p <- ggplot() +
      geom_brain(atlas = dk(), show.legend = FALSE, position = pos) +
      geom_brain_edges(
        atlas = dk(), edge_group = "lobe",
        colour = "black", position = pos
      ) +
      theme_brain()
    vdiffr::expect_doppelganger("dk-lobe-edges-positioned", p)
  })
})
