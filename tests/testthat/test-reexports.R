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
    "atlas_views_empty",
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
    "is_atlas_sf",
    "is_atlas_polygon",
    "legacy_region_map"
  )

  # Accessors deliberately left behind, each with the reason. A name here is
  # a decision on record; a name in neither vector is an oversight, which is
  # what the partition test below turns into a failure.
  not_reexported <- c(
    brain_labels = "deprecated in ggseg.formats",
    brain_regions = "deprecated in ggseg.formats",
    brain_views = "deprecated in ggseg.formats"
  )

  # ggseg.formats groups its read-only accessors with `@family atlas
  # accessors`, which roxygen writes into every topic as a \concept. Reading
  # the set from there rather than restating it is the point: a new accessor
  # in ggseg.formats then lands in neither vector above and fails, instead of
  # being quietly missing from ggseg for a release. That is not hypothetical
  # -- `is_atlas_sf()` and `is_atlas_polygon()` were missing exactly this way.
  formats_accessors <- function() {
    rd_parts <- function(rd, what) {
      tags <- vapply(
        rd,
        function(x) {
          tag <- attr(x, "Rd_tag")
          if (is.null(tag)) "" else tag
        },
        character(1)
      )
      unlist(lapply(
        rd[tags == what],
        function(x) trimws(paste(unlist(x), collapse = ""))
      ))
    }
    db <- tools::Rd_db("ggseg.formats")
    family <- Filter(
      function(rd) "atlas accessors" %in% rd_parts(rd, "\\concept"),
      db
    )
    aliases <- sort(unique(unlist(lapply(family, rd_parts, "\\alias"))))
    intersect(aliases, getNamespaceExports("ggseg.formats"))
  }

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

  it("accounts for every accessor ggseg.formats exports", {
    # Re-export it, or record why not. Neither is an oversight.
    expect_identical(
      setdiff(formats_accessors(), c(accessors, names(not_reexported))),
      character()
    )
  })

  it("really withholds the accessors it says it withholds", {
    expect_false(any(names(not_reexported) %in% getNamespaceExports("ggseg")))
  })
})
