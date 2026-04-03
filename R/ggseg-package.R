#' ggseg: Visualise brain atlas data with ggplot2
#'
#' Provides a ggplot2 geom and position for visualising brain region data on
#' cortical, subcortical, and white matter tract atlases. Brain atlas
#' geometries are stored as simple features (sf), enabling seamless
#' integration with the ggplot2 ecosystem including faceting, custom scales,
#' and themes.
#'
#' The main entry point is [geom_brain()], which accepts a `ggseg_atlas`
#' object and optional user data. Use [position_brain()] to control the
#' layout of brain slices/views.
#'
#' @name ggseg
#' @docType package
#' @keywords internal
#' @importFrom ggplot2 aes alpha annotate coord_sf draw_key_polygon
#'   element_blank element_rect element_text Geom geom_sf ggproto labs
#'   layer scale_color_manual scale_colour_manual scale_fill_manual
#'   scale_x_continuous scale_y_continuous theme .pt
#' @importFrom ggplot2 GeomPolygon
#' @importFrom ggseg.formats atlas_palette dk aseg tracula
"_PACKAGE"

#' @export
ggseg.formats::dk

#' @export
ggseg.formats::aseg

#' @export
ggseg.formats::tracula

utils::globalVariables(c(
  ".id",
  ".lat",
  ".lat_sd",
  ".long",
  ".long_min",
  ".long_sd",
  ".subid",
  "hemi",
  "L2",
  "label",
  "view"
))
