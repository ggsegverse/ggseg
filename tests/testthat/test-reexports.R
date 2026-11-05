describe("re-exported ggseg.formats accessors (ggseg#183)", {
  accessors <- c(
    "atlas_regions",
    "atlas_labels",
    "atlas_hemi",
    "atlas_display",
    "atlas_type",
    "atlas_views",
    "atlas_context",
    "atlas_undrawn",
    "atlas_region_semantics",
    "atlas_palette",
    "atlas_plot_palette",
    "atlas_geom",
    "atlas_geometry_type",
    "atlas_sf",
    "atlas_polygons",
    "atlas_vertices",
    "atlas_centerlines",
    "atlas_meshes",
    "atlas_provenance",
    "legacy_region_map"
  )

  it("are reachable after library(ggseg) alone", {
    expect_in(accessors, getNamespaceExports("ggseg"))
  })

  it("are the ggseg.formats functions, not copies", {
    for (name in accessors) {
      expect_identical(
        getExportedValue("ggseg", name),
        getExportedValue("ggseg.formats", name),
        label = name
      )
    }
  })

  it("leave the atlas-editing verbs to ggseg.extra", {
    expect_false(any(
      c("atlas_region_remove", "atlas_view_keep", "ggseg_atlas") %in%
        getNamespaceExports("ggseg")
    ))
  })
})
