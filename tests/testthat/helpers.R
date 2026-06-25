library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(tidyr, quietly = TRUE, warn.conflicts = FALSE)
library(ggplot2, quietly = TRUE, warn.conflicts = FALSE)
library(vdiffr, quietly = TRUE, warn.conflicts = FALSE)
library(ggseg.formats, quietly = TRUE, warn.conflicts = FALSE)
set.seed(1234)

# A cortical atlas with 3D vertices but no 2D geometry, built through the public
# ggseg.formats constructors. Used to exercise the "no 2D geometry" error paths
# without reaching into atlas internals.
atlas_without_2d_geometry <- function() {
  vertices <- data.frame(label = "lh_frontal")
  vertices$vertices <- list(1:3)
  ggseg_atlas(
    atlas = "empty",
    type = "cortical",
    core = data.frame(hemi = "left", region = "frontal", label = "lh_frontal"),
    data = ggseg_data_cortical(vertices = vertices)
  )
}
