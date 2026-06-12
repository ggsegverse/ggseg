#' Midpoint of a numeric range
#'
#' @param x Numeric vector.
#'
#' @return Single numeric value, the mean of `min(x)` and `max(x)`.
#' @keywords internal
#' @noRd
gap <- function(x) {
  (min(x) + max(x)) / 2
}


#' Fixed-aspect coordinate system for brain polygons
#'
#' A coordinate system for the sf-optional polygon renderer
#' [geom_brain_polygon()]. It fixes the aspect ratio (like
#' [ggplot2::coord_fixed()]) so brain shapes are not stretched by the
#' plotting window, mirroring the role [ggplot2::coord_sf()] plays for the
#' sf-backed [geom_brain()].
#'
#' `geom_brain_polygon()` adds `coord_brain()` for you, so you rarely need to
#' call it directly. Like `coord_sf(default = TRUE)`, it registers as a
#' *default* coordinate system: adding your own coord — or stacking several
#' `geom_brain_polygon()` layers — replaces it cleanly without ggplot2's
#' "Coordinate system already present" message.
#'
#' @param ratio Aspect ratio, expressed as `y / x`. Defaults to `1`, which
#'   keeps brain polygons undistorted.
#' @param clip Should drawing be clipped to the panel extent (`"on"`) or
#'   allowed to overflow (`"off"`)? Defaults to `"off"` so region outlines at
#'   the panel edge are not cut.
#' @param ... Additional arguments passed to [ggplot2::coord_fixed()].
#'
#' @return A ggplot2 coordinate system that registers as a default.
#' @export
#' @importFrom ggplot2 coord_fixed
#' @examples
#' library(ggplot2)
#' \dontrun{
#' poly <- ggseg.formats::as_polygon_atlas(dk())
#' # Equivalent to the default; shown explicitly:
#' ggplot() +
#'   geom_brain_polygon(atlas = poly) +
#'   coord_brain()
#' }
coord_brain <- function(ratio = 1, clip = "off", ...) {
  coord <- coord_fixed(ratio = ratio, clip = clip, ...)
  coord$default <- TRUE
  coord
}
