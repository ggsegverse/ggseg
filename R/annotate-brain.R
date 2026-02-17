#' Add view labels to brain atlas plots
#'
#' Annotates each brain view with a text label positioned above the
#' view's bounding box. For cortical atlases, labels show hemisphere
#' and view (e.g., "left lateral"). For subcortical and tract atlases,
#' labels show the view name directly (e.g., "axial_1", "sagittal").
#'
#' Labels respect the repositioning done by [position_brain()], so the
#' same `position` argument should be passed to both [geom_brain()] and
#' `annotate_brain()`.
#'
#' @param atlas A `brain_atlas` object (e.g. `dk()`, `aseg()`).
#' @param position A [position_brain()] object or position specification
#'   matching the one used in [geom_brain()].
#' @param hemi Character vector of hemispheres to include. If `NULL`
#'   (default), all hemispheres are included.
#' @param view Character vector of views to include. If `NULL`
#'   (default), all views are included.
#' @param size Text size in mm (default: `3`).
#' @param colour Text colour (default: `"grey30"`).
#' @param family Font family (default: `"mono"`).
#' @param nudge_y Additional vertical offset for labels (default: `0`).
#' @param ... Additional arguments passed to [ggplot2::annotate()].
#'
#' @return A ggplot2 annotation layer.
#' @export
#'
#' @examples
#' library(ggplot2)
#'
#' pos <- position_brain(hemi ~ view)
#' ggplot() +
#'   geom_brain(atlas = dk(), position = pos, show.legend = FALSE) +
#'   annotate_brain(atlas = dk(), position = pos)
#'
#' ggplot() +
#'   geom_brain(atlas = dk(), show.legend = FALSE) +
#'   annotate_brain(atlas = dk())
annotate_brain <- function(
  atlas,
  position = position_brain(),
  hemi = NULL,
  view = NULL,
  size = 3,
  colour = "grey30",
  family = "mono",
  nudge_y = 0,
  ...
) {
  data <- as.data.frame(atlas)

  if (!is.null(hemi)) {
    data <- data[data$hemi %in% hemi, ]
  }
  if (!is.null(view)) {
    data <- data[data$view %in% view, ]
  }

  params <- extract_position_params(position)
  repositioned <- reposition_brain(
    data,
    params$position,
    nrow = params$nrow,
    ncol = params$ncol,
    views = params$views
  )

  label_df <- compute_label_positions(repositioned)

  overall_bbox <- sf::st_bbox(repositioned$geometry)
  y_range <- unname(overall_bbox["ymax"] - overall_bbox["ymin"])
  label_df$y <- label_df$y + y_range * 0.02 + nudge_y

  ggplot2::annotate(
    "text",
    x = label_df$x,
    y = label_df$y,
    label = label_df$label,
    size = size,
    colour = colour,
    family = family,
    ...
  )
}


#' Extract position parameters from a PositionBrain object
#'
#' @param pos A PositionBrain ggproto object or raw position value.
#' @return A list with position, nrow, ncol, views.
#' @keywords internal
#' @noRd
extract_position_params <- function(pos) {
  if (inherits(pos, "PositionBrain")) {
    list(
      position = pos$position,
      nrow = pos$nrow,
      ncol = pos$ncol,
      views = pos$views
    )
  } else {
    list(position = pos, nrow = NULL, ncol = NULL, views = NULL)
  }
}


#' Compute label text and positions from repositioned brain data
#'
#' @param repositioned An sf data.frame returned by [reposition_brain()].
#' @return A data.frame with columns x, y, label.
#' @keywords internal
#' @noRd
compute_label_positions <- function(repositioned) {
  atlas_type <- unique(repositioned$type)[1]

  if (atlas_type == "cortical") {
    groups <- split(
      repositioned,
      list(repositioned$hemi, repositioned$view),
      drop = TRUE
    )
    label_fn <- function(df) paste(unique(df$hemi), unique(df$view))
  } else {
    groups <- split(repositioned, repositioned$view, drop = TRUE)
    label_fn <- function(df) unique(df$view)
  }

  do.call(rbind, lapply(groups, function(df) {
    bbox <- sf::st_bbox(df$geometry)
    data.frame(
      x = unname((bbox["xmin"] + bbox["xmax"]) / 2),
      y = unname(bbox["ymax"]),
      label = label_fn(df),
      stringsAsFactors = FALSE,
      row.names = NULL
    )
  }))
}
