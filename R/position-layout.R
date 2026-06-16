# Shared, coordinate-agnostic view layout ----
#
# The sf path (position-brain.R) and the polygon path (position-brain-polygon.R)
# arrange an atlas's view groups into a uniform grid with the *same* algorithm:
# gather each group to the cell origin, centre it in a cell sized to the largest
# group, and shift it to its grid position. That is a single translation per
# group, derivable from the group's bounding box alone — so the math lives here
# once and each path supplies only how to read a bbox and how to translate.

#' Per-group `(dx, dy)` offsets that tile view groups into uniform cells
#'
#' Combines the three steps the old `gather_*` / `center_view*` / `stack_*`
#' helpers did — gather to origin, centre in a uniform cell (sized to the
#' largest group, +20\% separation), and shift to the `(row, col)` grid cell —
#' into one translation per group. 1-D layouts pass a constant row or col index.
#'
#' @param bboxes Numeric matrix, one row per group, columns `xmin`, `ymin`,
#'   `xmax`, `ymax`.
#' @param row_idx,col_idx Integer 1-based cell indices, one per group.
#' @return Numeric matrix with columns `dx`, `dy`, one row per group.
#' @keywords internal
#' @noRd
layout_cell_offsets <- function(bboxes, row_idx, col_idx) {
  w <- bboxes[, "xmax"] - bboxes[, "xmin"]
  h <- bboxes[, "ymax"] - bboxes[, "ymin"]
  cell_w <- max(w)
  cell_h <- max(h)
  sep_x <- cell_w * 1.2
  sep_y <- cell_h * 1.2
  cbind(
    dx = -bboxes[, "xmin"] + (cell_w - w) / 2 + (col_idx - 1) * sep_x,
    dy = -bboxes[, "ymin"] + (cell_h - h) / 2 + (row_idx - 1) * sep_y
  )
}


#' Padded overall bounding box from per-group post-translation bboxes
#'
#' 1\% of the largest extent, anchored at the negative pad (matching the old
#' `get_box()` / `get_box_flat()`).
#'
#' @param bboxes Numeric matrix of post-translation group bboxes.
#' @return Named numeric `c(xmin, ymin, xmax, ymax)`.
#' @keywords internal
#' @noRd
layout_box <- function(bboxes) {
  pad <- max(bboxes) * 0.01
  c(
    xmin = -pad,
    ymin = -pad,
    xmax = max(bboxes[, "xmax"]) + pad,
    ymax = max(bboxes[, "ymax"]) + pad
  )
}


#' Resolve per-group cell indices and the row-major binding order
#'
#' @param groups List of per-view group data.frames.
#' @param posi `"rows"`, `"columns"`, or `"grid"`.
#' @param rows,columns Grid column names (grid mode only).
#' @return List with integer `row`/`col` (per group) and `order` (row-major
#'   bind order, dropping no groups — empty cells simply have no group).
#' @keywords internal
#' @noRd
cell_indices <- function(groups, posi, rows = NULL, columns = NULL) {
  n <- length(groups)
  if (posi == "columns") {
    return(list(row = rep(1L, n), col = seq_len(n), order = seq_len(n)))
  }
  if (posi == "rows") {
    return(list(row = seq_len(n), col = rep(1L, n), order = seq_len(n)))
  }
  lookup <- grid_lookup(groups, rows, columns)
  ri <- match(lookup$df_rows, lookup$row_vals)
  ci <- match(lookup$df_cols, lookup$col_vals)
  list(row = ri, col = ci, order = order(ri, ci))
}


#' Lay out view groups into uniform cells (sf- and polygon-agnostic)
#'
#' Shared driver for [frame_2_position()] (sf) and [frame_2_position_flat()]
#' (polygon). Reads each group's bbox via `bbox_of`, computes the offsets with
#' [layout_cell_offsets()], applies them via `translate`, and returns the groups
#' in row-major bind order plus the padded overall box.
#'
#' @param groups List of per-view group objects.
#' @param posi `"rows"`, `"columns"`, or `"grid"`.
#' @param rows,columns Grid column names (grid mode only).
#' @param bbox_of `function(group)` returning `c(xmin, ymin, xmax, ymax)`.
#' @param translate `function(group, dx, dy)` returning the shifted group.
#' @return List with `data` (translated groups, bind order) and `box`.
#' @keywords internal
#' @noRd
position_groups <- function(groups, posi, rows, columns, bbox_of, translate) {
  bboxes <- t(vapply(groups, bbox_of, numeric(4)))
  colnames(bboxes) <- c("xmin", "ymin", "xmax", "ymax")

  idx <- cell_indices(groups, posi, rows, columns)
  offs <- layout_cell_offsets(bboxes, idx$row, idx$col)

  moved <- lapply(seq_along(groups), function(i) {
    translate(groups[[i]], offs[i, "dx"], offs[i, "dy"])
  })
  # post-translation bboxes: dx shifts xmin/xmax, dy shifts ymin/ymax
  post <- bboxes + offs[, c("dx", "dy", "dx", "dy")]

  ord <- idx$order
  list(data = moved[ord], box = layout_box(post[ord, , drop = FALSE]))
}
