#' Plot brain parcellations
#'
#' \code{ggseg} plots and returns a ggplot object of plotted
#' aparc regions. Is superseded by the new \code{\link{geom_brain}}.
#' @author Athanasia Mo Mowinckel and Didac Vidal-Piñeiro
#'
#' @param .data A .data.frame to use for plot aesthetics. Should include a
#' column called "region" corresponding to aparc regions.
#'
#' @param atlas Either a string with the name of atlas to use,
#' or a .data.frame containing atlas information (i.e. pre-loaded atlas).
#' @param ... other options sent to geom_polygon for plotting, including
#' mapping aes (cannot include x, y, and group aesthetics).
#' @param hemisphere String to choose hemisphere to plot.
#'   Any of c("left","right")[default].
#' @param view String to choose view of the .data.
#'   Any of c("lateral","medial")[default].
#' @param position String choosing how to view the .data.
#'   Either "dispersed"[default] or "stacked".
#' @param adapt_scales if \code{TRUE}, then the axes will
#' be hemisphere without ticks.  If \code{FALSE}, then will be latitude
#' longitude values.  Also affected by \code{position} argument
#'
#' @importFrom dplyr as_tibble select filter across
#' @importFrom ggplot2 ggplot aes geom_polygon coord_fixed
#' @importFrom tidyr unnest
#'
#' @details
#' \describe{
#'
#' \item{`dk`}{
#' The Desikan-Killiany Cortical Atlas [default],
#' FreeSurfer cortical segmentations.}
#'
#' \item{`aseg`}{
#' FreeSurfer automatic subcortical segmentation of a brain volume}
#' }
#'
#' @return a ggplot object
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' ggseg()
#' ggseg(mapping = aes(fill = region))
#' ggseg(
#'   colour = "black",
#'   size = .7,
#'   mapping = aes(fill = region)
#' ) + theme_void()
#' ggseg(position = "stacked")
#' ggseg(adapt_scales = FALSE)
#' }
#' @seealso [ggplot2][ggplot], [aes][aes],
#' [geom_polygon][geom_polygon], [coord_fixed][coord_fixed]
#'
#' @export
ggseg <- function(
  ...
) {
  lifecycle::deprecate_stop(
    "2.0.0",
    "ggseg()",
    details = "Please use `ggplot() + geom_brain()` instead."
  )
}
