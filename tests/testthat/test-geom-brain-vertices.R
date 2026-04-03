describe("geom_brain_vertices", {
  it("renders without data", {
    p <- ggplot() +
      geom_brain_vertices(atlas = dk())
    expect_s3_class(p, "gg")
  })

  it("renders with region data", {
    some_data <- data.frame(
      region = c("transverse temporal", "insula", "precentral"),
      p = c(0.1, 0.2, 0.3)
    )
    p <- ggplot(some_data) +
      geom_brain_vertices(atlas = dk(), aes(fill = p))
    expect_s3_class(p, "gg")
    built <- ggplot_build(p)
    expect_true(nrow(built$data[[1]]) > 0)
  })

  it("produces one row per label per view plus background rows", {
    p <- ggplot() +
      geom_brain_vertices(atlas = dk())
    built <- ggplot_build(p)
    n_rows <- nrow(built$data[[1]])
    atlas_verts <- ggseg.formats::atlas_vertices(dk())
    n_labels <- nrow(atlas_verts)
    n_hemis <- length(unique(atlas_verts$hemi))
    expect_equal(n_rows, n_labels * 2L + n_hemis * 2L)
  })

  it("filters by hemisphere", {
    p <- ggplot() +
      geom_brain_vertices(atlas = dk(), hemi = "left")
    built <- ggplot_build(p)
    expect_true(all(built$data[[1]]$hemi == "left"))
  })

  it("filters by view", {
    p <- ggplot() +
      geom_brain_vertices(atlas = dk(), view = "lateral")
    built <- ggplot_build(p)
    expect_true(all(built$data[[1]]$view == "lateral"))
  })

  it("works with position_brain formula", {
    p <- ggplot() +
      geom_brain_vertices(
        atlas = dk(),
        position = position_brain(hemi ~ view)
      )
    expect_s3_class(p, "gg")
    built <- ggplot_build(p)
    expect_true(nrow(built$data[[1]]) > 0)
  })

  it("works alongside geom_brain", {
    p <- ggplot() +
      geom_brain(atlas = dk(), show.legend = FALSE) +
      geom_brain_vertices(atlas = dk(), inherit.aes = FALSE)
    expect_s3_class(p, "gg")
    built <- ggplot_build(p)
    expect_equal(length(built$data), 2)
  })
})

describe("LayerBrainVertices", {
  it("errors when no atlas is supplied", {
    expect_error(
      ggplot_build(
        ggplot() +
          layer_brain_vertices(
            geom = GeomBrainVertices,
            stat = "sf",
            position = position_brain(),
            params = list(
              na.rm = FALSE, atlas = NULL,
              surface = "inflated", brain_meshes = NULL
            )
          ) +
          coord_sf()
      ),
      "No atlas supplied"
    )
  })

  it("errors when atlas has no vertex data", {
    expect_error(
      ggplot_build(
        ggplot() +
          geom_brain_vertices(atlas = aseg())
      ),
      "vertex data"
    )
  })

  it("errors on invalid hemisphere", {
    expect_error(
      ggplot_build(
        ggplot() +
          geom_brain_vertices(atlas = dk(), hemi = "top")
      ),
      "Invalid hemisphere"
    )
  })

  it("errors on invalid view", {
    expect_error(
      ggplot_build(
        ggplot() +
          geom_brain_vertices(atlas = dk(), view = "top")
      ),
      "Invalid view"
    )
  })
})

describe("GeomBrainVertices", {
  it("exists as ggproto object", {
    expect_s3_class(GeomBrainVertices, "Geom")
  })

  it("inherits from GeomBrain", {
    expect_true(inherits(GeomBrainVertices, "GeomBrain"))
  })
})

describe("expand_atlas_vertices_to_sf", {
  it("returns sf data frame", {
    verts <- ggseg.formats::atlas_vertices(dk())
    result <- expand_atlas_vertices_to_sf(verts)
    expect_s3_class(result, "sf")
  })

  it("has expected columns", {
    verts <- ggseg.formats::atlas_vertices(dk())
    result <- expand_atlas_vertices_to_sf(verts)
    expect_true(all(c("label", "region", "hemi", "view", "type") %in% names(result)))
  })

  it("contains lateral and medial views", {
    verts <- ggseg.formats::atlas_vertices(dk())
    result <- expand_atlas_vertices_to_sf(verts)
    expect_setequal(unique(result$view), c("lateral", "medial"))
  })

  it("type is always cortical", {
    verts <- ggseg.formats::atlas_vertices(dk())
    result <- expand_atlas_vertices_to_sf(verts)
    expect_true(all(result$type == "cortical"))
  })
})

describe("geom_brain_vertices visual", {
  it("dk-vertices-default", {
    p <- ggplot() +
      geom_brain_vertices(atlas = dk()) +
      theme_brain()
    vdiffr::expect_doppelganger("dk-vertices-default", p)
  })

  it("dk-vertices-positioned", {
    p <- ggplot() +
      geom_brain_vertices(
        atlas = dk(),
        position = position_brain(hemi ~ view)
      ) +
      theme_brain()
    vdiffr::expect_doppelganger("dk-vertices-positioned", p)
  })

  it("dk-vertices-with-data", {
    some_data <- data.frame(
      region = c("transverse temporal", "insula", "precentral",
                 "superior parietal"),
      p = c(0.1, 0.2, 0.3, 0.4)
    )
    p <- ggplot(some_data) +
      geom_brain_vertices(atlas = dk(), aes(fill = p)) +
      scale_fill_viridis_c(na.value = "grey90") +
      theme_brain()
    vdiffr::expect_doppelganger("dk-vertices-with-data", p)
  })
})
