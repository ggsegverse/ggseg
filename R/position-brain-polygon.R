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


#' Apply a position layout to flat polygon data
#'
#' Mirror of [frame_2_position()] for the polygon path. Operates on
#' row-per-point data and returns a flat data.frame (no sf class machinery).
#'
#' @param data Data.frame with `x`, `y`, view/hemi/etc. columns.
#' @param pos Position spec (string or formula).
#' @param nrow,ncol Optional grid dimensions (mutually exclusive with `pos`).
#' @param views Optional ordered view filter.
#' @param focus Optional character vector of focus region names. When
#'   supplied, each view is cropped to a common window centred on its focus
#'   regions (see [zoom_views_flat()]).
#' @param zoom_pad Fractional padding added around the focus window.
#' @return Data.frame with repositioned `x`, `y` and a `polygon_bbox`
#'   attribute carrying the overall bounding box.
#' @keywords internal
#' @noRd
frame_2_position_flat <- function(
  data,
  pos,
  nrow = NULL,
  ncol = NULL,
  views = NULL,
  focus = NULL,
  zoom_pad = 0.05
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

  if (!is.null(focus)) {
    dfpos$data <- zoom_views_flat(dfpos$data, focus, zoom_pad)
    keep <- vapply(dfpos$data, function(d) nrow(d) > 0, logical(1))
    dfpos$data <- dfpos$data[keep]
  }

  posi <- if (length(dfpos$position) > 1) "grid" else dfpos$position
  rows <- if (posi == "grid") dfpos$position[1] else NULL
  columns <- if (posi == "grid") dfpos$position[2] else NULL

  res <- position_groups(
    dfpos$data,
    posi,
    rows,
    columns,
    bbox_of = bbox_flat,
    translate = function(g, dx, dy) {
      g$x <- g$x + dx
      g$y <- g$y + dy
      g
    }
  )

  out <- dplyr::bind_rows(res$data)
  if (posi == "grid") {
    out <- drop_temp_columns(out)
  }
  attr(out, "polygon_bbox") <- res$box
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
#' @param position Formula describing the rows ~ columns organisation for
#'   cortical atlases (e.g., `hemi ~ view`). For subcortical/tract atlases,
#'   can be "horizontal", "vertical", or a formula with `type ~ .` where type
#'   is extracted from view names like "axial_1" -> "axial".
#' @param nrow Number of rows for grid layout. If NULL (default), calculated
#'   automatically. Only used for subcortical/tract atlases when position is
#'   not a formula.
#' @param ncol Number of columns for grid layout. If NULL (default), calculated
#'   automatically. Only used for subcortical/tract atlases when position is
#'   not a formula.
#' @param views Character vector specifying which views to include and their
#'   order. If NULL (default), all views are included in their original order.
#'   Only applies to subcortical/tract atlases.
#' @param zoom Controls per-view zoom. `NULL`/`FALSE` (default) draws each
#'   view at full extent. `TRUE` zooms each view onto its focus regions —
#'   the regions present in the user `data` passed to [geom_brain_polygon()],
#'   or the atlas's labelled regions when no data is supplied. A character
#'   vector names the focus regions explicitly. Cropping uses an sf-free
#'   polygon clip so context regions become a clean rectangular frame around
#'   the focus.
#' @param zoom_pad Fractional padding added around the focus window when
#'   `zoom` is active. Defaults to `0.05` (5\%).
#' @return A `position_brain_polygon_spec` list with the layout parameters.
#' @keywords internal
#' @noRd
#' @examples
#' \dontrun{
#' library(ggplot2)
#' poly <- ggseg.formats::as_polygon_atlas(dk())
#' ggplot() +
#'   geom_brain_polygon(
#'     atlas = poly,
#'     position = position_brain_polygon("vertical")
#'   )
#'
#' # Zoom each view onto the regions present in user data
#' ggplot() +
#'   geom_brain_polygon(
#'     atlas = poly,
#'     data = my_data,
#'     position = position_brain_polygon(zoom = TRUE)
#'   )
#' }
position_brain_polygon <- function(
  position = "horizontal",
  nrow = NULL,
  ncol = NULL,
  views = NULL,
  zoom = NULL,
  zoom_pad = 0.05
) {
  structure(
    list(
      position = position,
      nrow = nrow,
      ncol = ncol,
      views = views,
      zoom = zoom,
      zoom_pad = zoom_pad
    ),
    class = "position_brain_polygon_spec"
  )
}


#' Resolve a zoom spec into a concrete set of focus region names
#'
#' Translates the `zoom` argument of [position_brain_polygon()] into the
#' character vector of regions used to build each view's focus window.
#' `TRUE` resolves to the regions present in the user `data` (those the user
#' supplied values for), falling back to the atlas's labelled regions when no
#' data is supplied.
#'
#' @param zoom The `zoom` spec: `NULL`/`FALSE`, `TRUE`, or a character vector.
#' @param data Optional user data.frame passed to [geom_brain_polygon()].
#' @param atlas The `ggseg_atlas` being rendered.
#' @return `NULL` when zoom is off, otherwise a character vector of regions.
#' @keywords internal
#' @noRd
resolve_zoom_focus <- function(zoom, data, atlas) {
  if (is.null(zoom) || isFALSE(zoom)) {
    return(NULL)
  }

  if (is.character(zoom)) {
    return(zoom)
  }

  if (!isTRUE(zoom)) {
    cli::cli_abort(c(
      "{.arg zoom} must be {.code NULL}, a logical, or a character vector.",
      "x" = "You supplied {.obj_type_friendly {zoom}}."
    ))
  }

  if (!is.null(data) && "region" %in% names(data)) {
    regs <- unique(data$region)
    regs <- regs[!is.na(regs)]
    if (length(regs)) {
      return(regs)
    }
  }

  regs <- unique(atlas$core$region)
  regs[!is.na(regs)]
}


#' Crop each view onto a common window centred on its focus regions
#'
#' Computes a single window size from the largest focus bounding box across
#' views (plus `pad`), then clips every view to that window centred on the
#' view's own focus centroid. Keeping the window size constant means every
#' view still occupies the same allotted cell after stacking. Views with no
#' focus regions are clipped to the same window centred on the view itself,
#' so they render as context-only frames rather than disappearing.
#'
#' @param view_list List of per-view flat data.frames.
#' @param focus Character vector of focus region names.
#' @param pad Fractional padding around the focus window.
#' @return List of clipped per-view data.frames.
#' @keywords internal
#' @noRd
zoom_views_flat <- function(view_list, focus, pad = 0.05) {
  focus_bboxes <- lapply(view_list, function(df) {
    fr <- df[!is.na(df$region) & df$region %in% focus, , drop = FALSE]
    if (nrow(fr) == 0) {
      return(NULL)
    }
    bbox_flat(fr)
  })

  has_focus <- !vapply(focus_bboxes, is.null, logical(1))
  if (!any(has_focus)) {
    cli::cli_warn(c(
      "No focus regions found in any view; {.arg zoom} had no effect.",
      "i" = "Check that the focus regions exist in the atlas/data."
    ))
    return(view_list)
  }

  dims <- vapply(
    focus_bboxes[has_focus],
    function(b) c(b[["xmax"]] - b[["xmin"]], b[["ymax"]] - b[["ymin"]]),
    numeric(2)
  )
  win_w <- max(dims[1, ]) * (1 + pad)
  win_h <- max(dims[2, ]) * (1 + pad)

  Map(
    function(df, b) {
      if (is.null(b)) {
        b <- bbox_flat(df)
      }
      cx <- (b[["xmin"]] + b[["xmax"]]) / 2
      cy <- (b[["ymin"]] + b[["ymax"]]) / 2
      box <- c(cx - win_w / 2, cx + win_w / 2, cy - win_h / 2, cy + win_h / 2)
      clip_view_flat(df, box)
    },
    view_list,
    focus_bboxes
  )
}


#' Clip all polygon rings in a flat view to a rectangle
#'
#' Splits the flat data into rings (one per `.feature_id` × `subgroup`),
#' clips each with [clip_ring_to_box()], and rebuilds the row-per-point
#' data.frame preserving all metadata columns. Rings fully outside the box
#' are dropped; rings spanning the box gain vertices on the boundary.
#'
#' @param df Flat view data.frame with `x`, `y`, `.feature_id`, `subgroup`.
#' @param box Numeric `c(xmin, xmax, ymin, ymax)`.
#' @return Clipped flat data.frame (possibly zero rows).
#' @keywords internal
#' @noRd
clip_view_flat <- function(df, box) {
  if (nrow(df) == 0) {
    return(df)
  }

  ring <- interaction(df$.feature_id, df$subgroup, drop = TRUE)
  pieces <- split(seq_len(nrow(df)), ring)

  out <- lapply(pieces, function(idx) {
    sub <- df[idx, , drop = FALSE]
    clipped <- clip_ring_to_box(sub$x, sub$y, box)
    if (nrow(clipped) == 0) {
      return(NULL)
    }
    rebuilt <- sub[rep(1L, nrow(clipped)), , drop = FALSE]
    rebuilt$x <- clipped[, 1]
    rebuilt$y <- clipped[, 2]
    rebuilt
  })

  out <- Filter(Negate(is.null), out)
  if (length(out) == 0) {
    return(df[0, , drop = FALSE])
  }
  dplyr::bind_rows(out)
}


#' Clip one polygon ring to an axis-aligned rectangle (Sutherland–Hodgman)
#'
#' sf-free polygon clipping against the convex clip rectangle, applied as
#' four successive half-plane clips. Treats the input as a closed ring.
#'
#' @param x,y Numeric vertex coordinates of the ring.
#' @param box Numeric `c(xmin, xmax, ymin, ymax)`.
#' @return Two-column matrix of clipped vertices (zero rows if fully outside).
#' @keywords internal
#' @noRd
clip_ring_to_box <- function(x, y, box) {
  xmin <- box[[1]]
  xmax <- box[[2]]
  ymin <- box[[3]]
  ymax <- box[[4]]

  pts <- cbind(x, y)

  clip_edge <- function(pts, inside, intersect) {
    n <- nrow(pts)
    if (n == 0) {
      return(pts)
    }
    keep <- vector("list", 0)
    prev <- pts[n, ]
    prev_in <- inside(prev)
    for (i in seq_len(n)) {
      cur <- pts[i, ]
      cur_in <- inside(cur)
      if (cur_in) {
        if (!prev_in) {
          keep[[length(keep) + 1L]] <- intersect(prev, cur)
        }
        keep[[length(keep) + 1L]] <- cur
      } else if (prev_in) {
        keep[[length(keep) + 1L]] <- intersect(prev, cur)
      }
      prev <- cur
      prev_in <- cur_in
    }
    if (length(keep) == 0) {
      matrix(numeric(0), 0, 2)
    } else {
      do.call(rbind, keep)
    }
  }

  cross <- function(a, b, edge, axis) {
    t <- (edge - a[axis]) / (b[axis] - a[axis])
    a + t * (b - a)
  }

  pts <- clip_edge(pts, function(p) p[1] >= xmin, function(a, b) {
    cross(a, b, xmin, 1)
  })
  pts <- clip_edge(pts, function(p) p[1] <= xmax, function(a, b) {
    cross(a, b, xmax, 1)
  })
  pts <- clip_edge(pts, function(p) p[2] >= ymin, function(a, b) {
    cross(a, b, ymin, 2)
  })
  pts <- clip_edge(pts, function(p) p[2] <= ymax, function(a, b) {
    cross(a, b, ymax, 2)
  })

  unname(pts)
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
