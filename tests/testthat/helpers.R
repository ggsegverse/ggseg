attach_if_installed <- function(pkgs) {
  for (pkg in pkgs) {
    if (requireNamespace(pkg, quietly = TRUE)) {
      suppressPackageStartupMessages(
        library(pkg, character.only = TRUE, warn.conflicts = FALSE)
      )
    }
  }
}

# R CMD check's _R_CHECK_DEPENDS_ONLY_ mode makes Suggests unavailable, where an
# unconditional library() errors the whole suite instead of skipping the tests
# that need the package.
attach_if_installed(c("dplyr", "tidyr", "ggplot2", "vdiffr", "ggseg.formats"))
set.seed(1234)

# The released and development ggseg.formats atlas schemas differ in `region`
# values, polygon vertex count and coordinate frame, so no single snapshot set
# can satisfy both. The `names` column exists only in the re-keyed schema, where
# the spelled-out region names moved out of `region`, so it marks the schema.
atlas_schema_variant <- function(core = ggseg.formats::dk()$core) {
  if ("names" %in% names(core)) "schema-names" else "schema-legacy"
}

# ggseg's two breaking-change warnings (uncoloured atlas, collapsed rows) fire
# once per session from plumbing that many tests exercise incidentally. Tests
# that are not about them muffle exactly those two classes, so an unrelated
# warning still counts as noise.
muffle_breaking_warnings <- function(expr) {
  withCallingHandlers(
    expr,
    ggseg_uncoloured_atlas = function(w) rlang::cnd_muffle(w),
    ggseg_collapsed_rows = function(w) rlang::cnd_muffle(w)
  )
}

expect_brain_doppelganger <- function(title, fig) {
  testthat::skip_if_not_installed("vdiffr")
  muffle_breaking_warnings(
    vdiffr::expect_doppelganger(title, fig, variant = atlas_schema_variant())
  )
}

# A cortical atlas with 3D vertices but no 2D geometry, built through the public
# ggseg.formats constructors. Used to exercise the "no 2D geometry" error paths
# without reaching into atlas internals.
atlas_without_2d_geometry <- function() {
  vertices <- data.frame(label = "lh_frontal")
  vertices$vertices <- list(1:3)
  ggseg.formats::ggseg_atlas(
    atlas = "empty",
    type = "cortical",
    core = data.frame(hemi = "left", region = "frontal", label = "lh_frontal"),
    data = ggseg.formats::ggseg_data_cortical(vertices = vertices)
  )
}
