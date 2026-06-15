# sf-optional annotate_brain ----
#
# Mirror of annotate_brain() for the polygon path. Computes label positions
# from flat polygon data using range() instead of sf::st_bbox.

#' Add view labels to a polygon-path brain plot
#'
#' Annotates each brain view with a text label positioned above the view's
#' bounding box. For cortical atlases, labels show hemisphere and view
#' (e.g. "left lateral"). For subcortical and tract atlases, labels show
#' the view name directly.
#'
#' Labels respect the layout applied by [position_brain_polygon()], so the
#' same `position` argument should be passed to both [geom_brain_polygon()]
#' and `annotate_brain_polygon()`.
#'
#' @param atlas A `ggseg_atlas` object with 2D geometry (sf or polygons).
#' @param position A [position_brain_polygon()] spec matching the one used
#'   in [geom_brain_polygon()].
#' @param hemi Character vector of hemispheres to include. If `NULL`
#'   (default), all hemispheres are included.
#' @param view Character vector of views to include. If `NULL` (default),
#'   all views are included.
#' @param size Text size in mm (default `3`).
#' @param colour Text colour (default `"grey30"`).
#' @param family Font family (default `"mono"`).
#' @param padding Vertical gap between each label and its view, as a
#'   fraction of the plot's total height (default `0.05`). Labels are also
#'   bottom-anchored (`vjust = 0`) so they sit clear of the geometry.
#' @param nudge_y Additional absolute vertical offset for labels
#'   (default `0`).
#' @param ... Additional arguments passed to [ggplot2::annotate()].
#'
#' @return A ggplot2 annotation layer.
#' @keywords internal
#' @noRd
#' @examples
#' \dontrun{
#' library(ggplot2)
#' poly <- ggseg.formats::as_polygon_atlas(dk())
#' pos <- position_brain_polygon(hemi ~ view)
#' ggplot() +
#'   geom_brain_polygon(atlas = poly, position = pos, show.legend = FALSE) +
#'   annotate_brain_polygon(atlas = poly, position = pos)
#' }
annotate_brain_polygon <- function(
  atlas,
  position = position_brain_polygon(),
  hemi = NULL,
  view = NULL,
  size = 3,
  colour = "grey30",
  family = "mono",
  padding = 0.05,
  nudge_y = 0,
  ...
) {
  flat <- prepare_polygon_atlas(
    atlas,
    hemi = hemi,
    view = view,
    position = position
  )

  label_df <- compute_label_positions_flat(flat)

  y_range <- diff(range(flat$y))
  label_df$y <- label_df$y + y_range * padding + nudge_y

  annotate_brain_labels(label_df, size, colour, family, ...)
}


#' Compute label text and positions from flat polygon data
#'
#' Mirror of [compute_label_positions()] for row-per-point data. Groups by
#' (hemi, view) for cortical atlases, just `view` otherwise, then returns
#' one centred label per group using base `range()` instead of
#' `sf::st_bbox`.
#'
#' @param flat A row-per-point data.frame returned by
#'   [prepare_polygon_atlas()].
#' @return A data.frame with columns `x`, `y`, `label`.
#' @keywords internal
#' @noRd
compute_label_positions_flat <- function(flat) {
  atlas_type <- unique(flat$type)[1]

  if (atlas_type == "cortical") {
    groups <- split(
      flat,
      list(flat$hemi, flat$view),
      drop = TRUE
    )
    label_fn <- function(df) paste(unique(df$hemi), unique(df$view))
  } else {
    groups <- split(flat, flat$view, drop = TRUE)
    label_fn <- function(df) unique(df$view)
  }

  do.call(
    rbind,
    lapply(groups, function(df) {
      data.frame(
        x = (min(df$x) + max(df$x)) / 2,
        y = max(df$y),
        label = label_fn(df),
        stringsAsFactors = FALSE,
        row.names = NULL
      )
    })
  )
}
