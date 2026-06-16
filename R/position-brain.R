#' Reposition brain slices
#'
#' Repositions pre-joined sf atlas data (i.e. data and atlas already joined to
#' a single sf data frame) for control over final plot layout. For even more
#' detailed control, convert the "hemi" and "view" columns into factors ordered
#' by wanted order of appearance.
#'
#' This is the sf layout helper. It requires the `sf` package (an optional
#' dependency); for the sf-free default, build a layout with [position_brain()]
#' and pass it to [geom_brain()].
#'
#' @param data sf-data.frame of joined brain atlas and data
#' @param position Position formula for slices. For cortical atlases, use
#'   formulas like `hemi ~ view`. For subcortical/tract atlases, use
#'   "horizontal", "vertical", or `type ~ .` for type-based layout.
#' @param nrow Number of rows for grid layout (subcortical/tract only)
#' @param ncol Number of columns for grid layout (subcortical/tract only)
#' @param views Character vector specifying view order (subcortical/tract only)
#'
#' @return sf-data.frame with re-positioned slices
#' @export
#'
#' @examplesIf requireNamespace("sf", quietly = TRUE)
#' reposition_brain(dk(), hemi ~ view)
#' reposition_brain(dk(), view ~ hemi)
#' reposition_brain(dk(), hemi + view ~ .)
#' reposition_brain(dk(), . ~ hemi + view)
#'
#' \donttest{
#' reposition_brain(aseg(), nrow = 2)
#' reposition_brain(aseg(), views = c("sagittal", "axial_3"))
#' }
reposition_brain <- function(
  data,
  position = "horizontal",
  nrow = NULL,
  ncol = NULL,
  views = NULL
) {
  require_sf("reposition_brain()")
  data <- as.data.frame(data, stringsAsFactors = FALSE)
  frame_2_position(
    data,
    position,
    nrow = nrow,
    ncol = ncol,
    views = views
  )
}


#' Arrange brain atlas views
#'
#' Controls how an atlas's hemispheres and views are arranged in the plot --
#' side by side, stacked, or in a grid -- and can zoom each view in on the
#' regions you care about. Pass the result to the `position` argument of
#' [geom_brain()] (or [annotate_brain()]).
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
#' @param zoom Controls per-view zoom. `NULL`/`FALSE` (default) draws each view
#'   at full extent. `TRUE` zooms each view onto its focus regions; a character
#'   vector names the focus regions explicitly.
#' @param zoom_pad Fractional padding added around the focus window when `zoom`
#'   is active. Defaults to `0.05` (5\%).
#'
#' @export
#' @return A layout specification to hand to [geom_brain()]'s `position`
#'   argument.
#' @examples
#' library(ggplot2)
#'
#' # Cortical atlas with formula
#' ggplot() +
#'   geom_brain(
#'     atlas = dk(), aes(fill = region),
#'     position = position_brain(. ~ view + hemi),
#'     show.legend = FALSE
#'   )
#'
#' ggplot() +
#'   geom_brain(
#'     atlas = dk(), aes(fill = region),
#'     position = position_brain(view ~ hemi),
#'     show.legend = FALSE
#'   )
#'
#' ggplot() +
#'   geom_brain(
#'     atlas = aseg(), aes(fill = region),
#'     position = position_brain(nrow = 2)
#'   )
#'
#' ggplot() +
#'   geom_brain(
#'     atlas = aseg(), aes(fill = region),
#'     position = position_brain(
#'       views = c("sagittal", "axial_3", "coronal_2"),
#'       nrow = 1
#'     )
#'   )
#'
#' ggplot() +
#'   geom_brain(
#'     atlas = aseg(), aes(fill = region),
#'     position = position_brain(type ~ .)
#'   )
position_brain <- function(
  position = "horizontal",
  nrow = NULL,
  ncol = NULL,
  views = NULL,
  zoom = NULL,
  zoom_pad = 0.05
) {
  position_brain_polygon(
    position = position,
    nrow = nrow,
    ncol = ncol,
    views = views,
    zoom = zoom,
    zoom_pad = zoom_pad
  )
}

#' Deprecated sf brain-view layout
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' The sf rendering path is deprecated. `position_brain_sf()` returns the
#' legacy `PositionBrain` ggproto for use with [geom_brain_sf()]. For new
#' code, use [position_brain()] (the polygon default), or convert the atlas
#' with `as_sf_atlas()` and use [ggplot2::geom_sf()] directly.
#'
#' @inheritParams position_brain
#' @export
#' @return A `PositionBrain` ggproto object.
#' @importFrom ggplot2 ggproto
#' @keywords internal
position_brain_sf <- function(
  position = "horizontal",
  nrow = NULL,
  ncol = NULL,
  views = NULL
) {
  lifecycle::deprecate_warn(
    "2.2.0",
    "position_brain_sf()",
    details = paste(
      "Use `position_brain()` for the polygon default, or `as_sf_atlas()`",
      "with `ggplot2::geom_sf()` for an sf workflow."
    )
  )
  require_sf("position_brain_sf()")
  make_position_brain_sf(position, nrow = nrow, ncol = ncol, views = views)
}

#' Construct a PositionBrain ggproto without the deprecation warning
#'
#' @keywords internal
#' @noRd
#' @importFrom ggplot2 ggproto
make_position_brain_sf <- function(
  position = "horizontal",
  nrow = NULL,
  ncol = NULL,
  views = NULL
) {
  ggproto(
    NULL,
    PositionBrain,
    position = position,
    nrow = nrow,
    ncol = ncol,
    views = views
  )
}

#' ggproto Position class for brain atlas layout
#'
#' Handles coordinate repositioning of brain views/slices during
#' the ggplot2 rendering pipeline. Created by [position_brain()].
#'
#' @keywords internal
#' @importFrom ggplot2 ggproto Position
#' @noRd
PositionBrain <- ggproto(
  "PositionBrain",
  Position,
  position = hemi + view ~ .,
  nrow = NULL,
  ncol = NULL,
  views = NULL,
  setup_params = function(self, data) {
    list(
      position = self$position,
      nrow = self$nrow,
      ncol = self$ncol,
      views = self$views
    )
  },
  compute_layer = function(self, data, params, layout) {
    df3 <- frame_2_position(
      data,
      params$position,
      nrow = params$nrow,
      ncol = params$ncol,
      views = params$views
    )
    bbx <- sf::st_bbox(df3$geometry)

    if (is.null(layout$coord$limits$y)) {
      layout$coord$limits$y <- bbx[c(2, 4)]
    }

    if (is.null(layout$coord$limits$x)) {
      layout$coord$limits$x <- bbx[c(1, 3)]
    }

    df3
  }
)

# geometry movers ----

#' Extract and validate variable names from a position formula
#'
#' @param pos A formula describing the layout.
#' @return Character vector of variable names (excluding `.`).
#' @keywords internal
#' @noRd
parse_formula_vars <- function(pos) {
  chosen <- all.vars(pos, unique = FALSE)
  chosen <- chosen[!grepl(".", chosen, fixed = TRUE)]

  if (anyDuplicated(chosen)) {
    cli::cli_abort(
      "Cannot position brain with the same data as columns and rows"
    )
  }
  chosen
}

#' Detect stacking direction from a formula with `+`
#'
#' For formulas like `hemi + view ~ .` or `. ~ hemi + view`,
#' determines whether the stacked layout is row-based or column-based.
#'
#' @param pos A formula containing `+` on one side and `.` on the other.
#' @return `"rows"` or `"columns"`.
#' @keywords internal
#' @noRd
stacking_direction <- function(pos) {
  if (grepl("~\\s*\\.", deparse(pos))) "rows" else "columns"
}

#' Validate that a single-direction formula includes both `.` and `~`
#'
#' @param pos A formula.
#' @param position The resolved position (`"rows"`, `"columns"`, or vars).
#' @keywords internal
#' @noRd
validate_stacking_formula <- function(pos, position) {
  is_single <- length(position) == 1 && position %in% c("rows", "columns")
  if (!is_single) {
    return(invisible())
  }

  has_both <- sum(grepl("\\.|~", pos)) == 2
  if (!has_both) {
    cli::cli_abort(
      "Formula for a single row or column must contain both a '.' and '~'"
    )
  }
}

#' Parse a position formula into layout instructions
#'
#' Interprets a formula like `hemi ~ view` into row/column
#' variable names and validates against the atlas type.
#'
#' @param pos A formula describing the layout.
#' @param data Data.frame with atlas columns (`type`, `hemi`, `view`).
#'
#' @return A list with `position` (character), `chosen` (variable names),
#'   and `data` (possibly modified data.frame).
#' @keywords internal
#' @noRd
position_formula <- function(pos, data) {
  chosen <- parse_formula_vars(pos)
  atlas_type <- unique(data$type)[1]

  if (atlas_type == "cortical") {
    position <- position_cortical(pos, chosen)
  } else {
    result <- position_subcortical(pos, chosen, data)
    position <- result$position
    chosen <- result$chosen
    data <- result$data
  }

  validate_stacking_formula(pos, position)
  list(position = position, chosen = chosen, data = data)
}

#' Resolve position for a cortical atlas formula
#'
#' @param pos A formula.
#' @param chosen Character vector of variable names.
#' @return Position specification: variable names or `"rows"`/`"columns"`.
#' @keywords internal
#' @noRd
position_cortical <- function(pos, chosen) {
  if (length(chosen) < 2) {
    missing_vars <- c("view", "hemi")[!c("view", "hemi") %in% chosen]
    cli::cli_abort(c(
      "Position formula not correct.",
      "x" = paste("Missing:", paste(missing_vars, collapse = " & "))
    ))
  }
  if (any(grepl("+", pos, fixed = TRUE))) {
    chosen <- stacking_direction(pos)
  }
  chosen
}

#' Resolve position for a subcortical/tract atlas formula
#'
#' @param pos A formula.
#' @param chosen Character vector of variable names.
#' @param data Data.frame with atlas columns.
#' @return A list with `position`, `chosen`, and `data`.
#' @keywords internal
#' @noRd
position_subcortical <- function(pos, chosen, data) {
  if ("type" %in% chosen) {
    data$.view_type <- extract_view_type(data$view)
    chosen[chosen == "type"] <- ".view_type"
  }

  position <- if (length(chosen) == 1) {
    stacking_direction(pos)
  } else {
    chosen
  }

  list(
    position = position,
    chosen = chosen,
    data = data
  )
}


#' Extract the type prefix from view names
#'
#' Splits view names like `"axial_3"` on underscore and returns
#' the first part (`"axial"`).
#'
#' @param views Character vector of view names.
#'
#' @return Character vector of type prefixes.
#' @keywords internal
#' @noRd
extract_view_type <- function(views) {
  vapply(
    views,
    function(v) {
      parts <- strsplit(v, "_", fixed = TRUE)[[1]]
      if (length(parts) >= 1) parts[1] else v # nocov
    },
    character(1),
    USE.NAMES = FALSE
  )
}

#' Reposition brain views according to layout specification
#'
#' Main dispatcher that splits data by view/hemisphere, gathers
#' geometry, and delegates to the appropriate stacking function.
#'
#' @param data Data.frame with atlas columns and `geometry`.
#' @param pos Position specification: a formula, `"horizontal"`,
#'   or `"vertical"`.
#' @param nrow Number of grid rows (optional).
#' @param ncol Number of grid columns (optional).
#' @param views Character vector of views to include.
#'
#' @return An sf data.frame with repositioned geometry and
#'   adjusted bounding box.
#' @keywords internal
#' @noRd
frame_2_position <- function(
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

  posi <- if (length(dfpos$position) > 1) "grid" else dfpos$position
  rows <- if (posi == "grid") dfpos$position[1] else NULL
  columns <- if (posi == "grid") dfpos$position[2] else NULL

  res <- position_groups(
    dfpos$data,
    posi,
    rows,
    columns,
    bbox_of = function(g) as.numeric(sf::st_bbox(g$geometry)),
    translate = function(g, dx, dy) {
      g$geometry <- g$geometry + c(dx, dy)
      g
    }
  )

  out <- do.call(rbind, res$data)
  if (posi == "grid") {
    out <- drop_temp_columns(out)
  }
  df4 <- sf::st_as_sf(out)
  box <- res$box
  class(box) <- "bbox"
  attr(sf::st_geometry(df4), "bbox") <- box

  df4
}


#' Split atlas data into a grid of views
#'
#' Assigns grid row/column indices to each view and returns
#' a list of per-view data.frames.
#'
#' @param data Data.frame with a `view` column.
#' @param nrow Number of grid rows (optional, auto-calculated).
#' @param ncol Number of grid columns (optional, auto-calculated).
#'
#' @return A list with `data` (list of data.frames) and
#'   `position` (column names for grid coordinates).
#' @keywords internal
#' @noRd
split_data_grid <- function(data, nrow = NULL, ncol = NULL) {
  view_list <- unique(data$view)
  n_views <- length(view_list)

  if (is.null(nrow) && is.null(ncol)) {
    ncol <- ceiling(sqrt(n_views))
    nrow <- ceiling(n_views / ncol)
  } else if (is.null(nrow)) {
    nrow <- ceiling(n_views / ncol)
  } else if (is.null(ncol)) {
    ncol <- ceiling(n_views / nrow)
  }

  data$.grid_row <- ((seq_along(view_list) - 1) %/% ncol + 1)[
    match(data$view, view_list)
  ]
  data$.grid_col <- ((seq_along(view_list) - 1) %% ncol + 1)[
    match(data$view, view_list)
  ]

  df_list <- lapply(view_list, function(v) {
    data[data$view == v, ]
  })

  list(
    data = df_list,
    position = c(".grid_row", ".grid_col")
  )
}

#' Split atlas data by position specification
#'
#' Routes to formula-based or string-based splitting depending
#' on whether `position` is a formula or character.
#'
#' @param data Data.frame with atlas columns.
#' @param position A formula or character layout specification.
#'
#' @return A list with `data` (list of data.frames) and
#'   `position` (layout direction or variable names).
#' @keywords internal
#' @noRd
split_data <- function(data, position) {
  if (inherits(position, "formula")) {
    split_data_formula(data, position)
  } else {
    split_data_string(data, position)
  }
}

#' Split atlas data by a position formula (e.g. `hemi ~ view`)
#'
#' @return A list with `data` (one data.frame per group) and `position`
#'   (the resolved layout direction or variable names).
#' @keywords internal
#' @noRd
split_data_formula <- function(data, position) {
  pos <- position_formula(position, data)
  if (!is.null(pos$data)) {
    data <- pos$data
  }
  groups <- dplyr::group_split(dplyr::group_by_at(data, pos$chosen))
  list(data = groups, position = pos$position)
}

#' Split atlas data by a string layout
#'
#' `position` is either `"horizontal"`/`"vertical"` (expanded to the atlas's
#' default view order) or pre-built `"hemi view"` / `"view"` identifiers.
#'
#' @inherit split_data_formula return
#' @keywords internal
#' @noRd
split_data_string <- function(data, position) {
  layout_direction <- "columns"
  if (length(position) == 1 && position %in% c("horizontal", "vertical")) {
    layout_direction <- if (position == "vertical") "rows" else "columns"
    position <- default_order(data)
  }

  pos <- as.data.frame(
    strsplit(position, " ", fixed = TRUE),
    stringsAsFactors = FALSE
  )

  groups <- if (identical(unique(data$type)[1], "cortical")) {
    split_cortical_pairs(data, pos)
  } else {
    lapply(pos, function(view) data[data$view == view, ])
  }

  list(data = groups, position = layout_direction)
}

#' Subset cortical data into its existing hemi/view pairs
#'
#' Columns of `pos` are `c(hemi, view)` pairs; keep only the pairs the atlas
#' actually contains, then subset the data to each.
#' @keywords internal
#' @noRd
split_cortical_pairs <- function(data, pos) {
  has_pair <- (pos[1, ] %in% data$hemi) & (pos[2, ] %in% data$view)
  pos <- pos[has_pair]
  lapply(pos, function(pair) {
    data[data$hemi == pair[1] & data$view == pair[2], ]
  })
}

#' Build a lookup of row/column values per data.frame element
#'
#' @param df List of data.frames from a split atlas.
#' @param rows Column name for the row variable.
#' @param columns Column name for the column variable.
#'
#' @return A list with `df_rows`, `df_cols` (per-element values),
#'   and `row_vals`, `col_vals` (unique levels).
#' @keywords internal
#' @noRd
grid_lookup <- function(df, rows, columns) {
  as_char <- function(x) {
    if (is.numeric(x)) as.character(x) else x
  }
  df_rows <- vapply(
    df,
    function(x) as_char(unique(x[[rows]])),
    character(1)
  )
  df_cols <- vapply(
    df,
    function(x) as_char(unique(x[[columns]])),
    character(1)
  )
  list(
    df_rows = df_rows,
    df_cols = df_cols,
    row_vals = unique(df_rows),
    col_vals = unique(df_cols)
  )
}

#' Remove temporary columns added during grid layout
#'
#' @param df A data.frame.
#' @return The data.frame with temp columns removed.
#' @keywords internal
#' @noRd
drop_temp_columns <- function(df) {
  temp <- c(
    "xmin",
    "xmax",
    "ymin",
    "ymax",
    ".grid_row",
    ".grid_col",
    ".view_type"
  )
  temp <- temp[temp %in% names(df)]
  if (length(temp) > 0) {
    df[, temp] <- NULL
  }
  df
}

#' Generate the default view ordering for an atlas
#'
#' For cortical atlases, returns `"hemi view"` pairs (left first).
#' For subcortical/tract atlases, returns unique views as-is.
#'
#' @param data Data.frame with `type`, `view`, and `hemi` columns.
#'
#' @return Character vector of ordered view identifiers.
#' @keywords internal
#' @noRd
default_order <- function(data) {
  if (unique(data$type) != "cortical") {
    return(unique(data$view))
  }
  sides <- unique(data$view)
  left_sides <- sides[sides %in% unique(data$view[data$hemi == "left"])]
  right_sides <- sides[sides %in% unique(data$view[data$hemi == "right"])]
  left_views <- paste("left", left_sides)
  right_views <- paste("right", right_sides)
  c(left_views, right_views)
}
