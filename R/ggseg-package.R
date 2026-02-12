#' ggseg: Visualise brain atlas data with ggplot2
#'
#' Provides a ggplot2 geom and position for visualising brain region data on
#' cortical, subcortical, and white matter tract atlases. Brain atlas
#' geometries are stored as simple features (sf), enabling seamless
#' integration with the ggplot2 ecosystem including faceting, custom scales,
#' and themes.
#'
#' The main entry point is [geom_brain()], which accepts a `brain_atlas`
#' object and optional user data. Use [position_brain()] to control the
#' layout of brain slices/views.
#'
#' @name ggseg
#' @docType package
#' @keywords internal
#' @import ggplot2
#' @import ggseg.formats
#' @importFrom utils data
"_PACKAGE"

utils::globalVariables(c(
  ".id",
  ".lat",
  ".lat_sd",
  ".long",
  ".long_min",
  ".long_sd",
  ".subid",
  "dk",
  "hemi",
  "L2",
  "label",
  "view"
))
