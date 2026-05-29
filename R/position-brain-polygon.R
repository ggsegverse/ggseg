# sf-optional position machinery ----
#
# Parallel implementations of the position primitives in position-brain.R for
# row-per-point polygon data (the polygon path produced by
# prepare_polygon_atlas). Where the sf path operates on `df$geometry` as sfc
# and uses `sf::st_bbox`, these operate on `df$x`/`df$y` and use base
# `range()` — no sf needed.
#
# Naming: helpers carry the `_flat` suffix to distinguish them from their sf
# counterparts. Stacking helpers return `list(df = combined, box = c(xmin,
# ymin, xmax, ymax))` so the rest of the pipeline reads the same fields.
#
# Layouts are applied at flatten time (inside prepare_polygon_atlas()) rather
# than via a ggproto Position. That side-steps ggplot2's aesthetic-stripping
# of non-standard columns (type / view / hemi), which the sf path's custom
# LayerBrain avoids by declaring those columns as aesthetics.

#' Bounding box of flat polygon coords
#'
#' @param df Data.frame with `x`, `y` numeric columns.
#' @return Named numeric vector `c(xmin, ymin, xmax, ymax)`.
#' @keywords internal
#' @noRd
bbox_flat <- function(df) {
  c(
    xmin = min(df$x),
    ymin = min(df$y),
    xmax = max(df$x),
    ymax = max(df$y)
  )
}


#' Translate flat coords so the bounding box starts at (0, 0)
#'
#' @param df Data.frame with `x`, `y` columns.
#' @return Data.frame with shifted `x`, `y`.
#' @keywords internal
#' @noRd
gather_flat <- function(df) {
  b <- bbox_flat(df)
  df$x <- df$x - b["xmin"]
  df$y <- df$y - b["ymin"]
  df
}


#' Center a view's flat coords within a grid cell
#'
#' Offsets `x`, `y` so the view is centered inside a cell of `cell_size`
#' at position `grid_pos`.
#'
#' @param df Data.frame with `x`, `y` columns (already gathered to origin).
#' @param cell_size Numeric length-2 `c(width, height)`.
#' @param grid_pos Numeric length-2 `c(x, y)` offset.
#' @return Data.frame with repositioned `x`, `y`.
#' @keywords internal
#' @noRd
center_view_flat <- function(df, cell_size, grid_pos) {
  b <- bbox_flat(df)
  view_size <- c(b["xmax"] - b["xmin"], b["ymax"] - b["ymin"])
  center_offset <- (cell_size - view_size) / 2
  df$x <- df$x + grid_pos[1] + center_offset[1]
  df$y <- df$y + grid_pos[2] + center_offset[2]
  df
}


#' Cell separation for flat-coord stacking
#'
#' Determines x/y spacing between grid cells based on the maximum
#' per-view bounding-box dimensions.
#'
#' @param data List of data.frames, each with `x`, `y` columns.
#' @return Named numeric vector `c(x = ..., y = ...)`.
#' @keywords internal
#' @noRd
get_sep_flat <- function(data) {
  bboxes <- vapply(data, bbox_flat, numeric(4))
  sep <- c(
    max(bboxes["xmax", ]) - min(bboxes["xmin", ]),
    max(bboxes["ymax", ]) - min(bboxes["ymin", ])
  )
  c("x" = sep[1] * 1.2, "y" = sep[2] * 1.2)
}


#' Stack flat-coord views horizontally
#'
#' @param df List of data.frames, each with `x`, `y` columns, already
#'   gathered to origin by [gather_flat()].
#' @return List with `df` (combined data.frame) and `box` (numeric bbox).
#' @keywords internal
#' @noRd
stack_horizontal_flat <- function(df) {
  sep <- get_sep_flat(df)
  cell_size <- sep / 1.2

  bx <- list()
  for (k in seq_along(df)) {
    df[[k]] <- center_view_flat(
      df[[k]],
      cell_size,
      c((k - 1) * sep["x"], 0)
    )
    bx[[k]] <- bbox_flat(df[[k]])
  }

  list(df = dplyr::bind_rows(df), box = get_box_flat(bx))
}


#' Stack flat-coord views vertically
#'
#' @inheritParams stack_horizontal_flat
#' @keywords internal
#' @noRd
stack_vertical_flat <- function(df) {
  sep <- get_sep_flat(df)
  cell_size <- sep / 1.2

  bx <- list()
  for (k in seq_along(df)) {
    df[[k]] <- center_view_flat(
      df[[k]],
      cell_size,
      c(0, (k - 1) * sep["y"])
    )
    bx[[k]] <- bbox_flat(df[[k]])
  }

  list(df = dplyr::bind_rows(df), box = get_box_flat(bx))
}


#' Stack flat-coord views on a row × column grid
#'
#' @param df List of data.frames, each with `x`, `y` columns and grid
#'   assignment metadata.
#' @param rows Column name identifying the row variable.
#' @param columns Column name identifying the column variable.
#' @keywords internal
#' @noRd
stack_grid_flat <- function(df, rows, columns) {
  sep <- get_sep_flat(df)
  lookup <- grid_lookup(df, rows, columns)

  grid <- expand.grid(
    col_idx = seq_along(lookup$col_vals),
    row_idx = seq_along(lookup$row_vals)
  )

  cell_size <- sep / 1.2
  df_positioned <- Map(
    function(ri, ci) {
      idx <- which(
        lookup$df_rows == lookup$row_vals[ri] &
          lookup$df_cols == lookup$col_vals[ci]
      )
      if (length(idx) != 1) {
        return(NULL)
      }
      grid_pos <- c((ci - 1) * sep["x"], (ri - 1) * sep["y"])
      center_view_flat(df[[idx]], cell_size, grid_pos)
    },
    grid$row_idx,
    grid$col_idx
  )

  df_positioned <- Filter(Negate(is.null), df_positioned)
  bx <- lapply(df_positioned, bbox_flat)
  result_df <- drop_temp_columns(dplyr::bind_rows(df_positioned))

  list(df = result_df, box = get_box_flat(bx))
}


#' Padded bounding box from a list of flat bboxes
#'
#' @param bx List of named numeric vectors with xmin/ymin/xmax/ymax.
#' @return Named numeric vector `c(xmin, ymin, xmax, ymax)` with 1% padding.
#' @keywords internal
#' @noRd
get_box_flat <- function(bx) {
  bx_mat <- do.call(rbind, bx)
  pad <- max(bx_mat) * 0.01
  c(
    xmin = -pad,
    ymin = -pad,
    xmax = max(bx_mat[, "xmax"]) + pad,
    ymax = max(bx_mat[, "ymax"]) + pad
  )
}


#' Apply a position layout to flat polygon data
#'
#' Mirror of [frame_2_position()] for the polygon path. Operates on
#' row-per-point data and returns a flat data.frame (no sf class machinery).
#'
#' @param data Data.frame with `x`, `y`, view/hemi/etc. columns.
#' @param pos Position spec (string or formula).
#' @param nrow,ncol Optional grid dimensions (mutually exclusive with `pos`).
#' @param views Optional ordered view filter.
#' @return Data.frame with repositioned `x`, `y` and a `polygon_bbox`
#'   attribute carrying the overall bounding box.
#' @keywords internal
#' @noRd
frame_2_position_flat <- function(
  data,
  pos,
  nrow = NULL,
  ncol = NULL,
  views = NULL
) {
  if (!is.null(views)) {
    data <- data[data$view %in% views, , drop = FALSE]
    data$view <- factor(data$view, levels = views)
    data <- data[order(data$view), ]
    data$view <- as.character(data$view)
  }

  if (!is.null(nrow) || !is.null(ncol)) {
    dfpos <- split_data_grid(data, nrow, ncol)
  } else {
    dfpos <- split_data(data, pos)
  }

  df2 <- lapply(dfpos$data, gather_flat)
  posi <- ifelse(length(dfpos$position) > 1, "grid", dfpos$position)

  df3 <- switch(
    posi,
    rows = stack_vertical_flat(df2),
    columns = stack_horizontal_flat(df2),
    grid = stack_grid_flat(df2, dfpos$position[1], dfpos$position[2])
  )

  out <- df3$df
  attr(out, "polygon_bbox") <- df3$box
  out
}


#' Position spec for the sf-optional polygon path
#'
#' Mirror of [position_brain()] for use with [geom_brain_polygon()]. Returns
#' a lightweight spec (not a ggproto Position) so the layout can be applied
#' inside [prepare_polygon_atlas()] before data flows through ggplot2's
#' aesthetic machinery — avoiding the column-stripping that would lose the
#' `type`, `view`, and `hemi` columns the layout needs.
#'
#' @inheritParams position_brain
#' @return A `position_brain_polygon_spec` list with the layout parameters.
#' @export
#' @examples
#' \dontrun{
#' library(ggplot2)
#' poly <- ggseg.formats::as_polygon_atlas(dk())
#' ggplot() +
#'   geom_brain_polygon(
#'     atlas = poly,
#'     position = position_brain_polygon("vertical")
#'   )
#' }
position_brain_polygon <- function(
  position = "horizontal",
  nrow = NULL,
  ncol = NULL,
  views = NULL
) {
  structure(
    list(
      position = position,
      nrow = nrow,
      ncol = ncol,
      views = views
    ),
    class = "position_brain_polygon_spec"
  )
}


#' Test whether an object is a polygon-path position spec
#'
#' @param x An object.
#' @return Logical.
#' @keywords internal
#' @noRd
is_polygon_position <- function(x) {
  inherits(x, "position_brain_polygon_spec")
}
