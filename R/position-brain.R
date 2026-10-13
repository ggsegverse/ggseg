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
#' @param nrow Number of rows for grid layout; cannot be combined with a
#'   `position` formula.
#' @param ncol Number of columns for grid layout; cannot be combined with a
#'   `position` formula.
#' @param views Character vector specifying view order. Names the data does
#'   not have are dropped with a warning.
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
  # Validate before the sf guard: a bad nrow/ncol combination is wrong whether
  # or not sf is installed, and "install sf" would hide the real mistake.
  validate_grid_args(position, nrow, ncol)
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
#' @param nrow Number of rows for grid layout, a positive whole number. If
#'   `NULL` (default), calculated automatically. Cannot be combined with a
#'   `position` formula, which a grid layout would discard. Grid cells are
#'   hemisphere/view pairs for a cortical atlas and views for a slice-based
#'   one.
#' @param ncol Number of columns for grid layout, a positive whole number. If
#'   `NULL` (default), calculated automatically. Cannot be combined with a
#'   `position` formula.
#' @param views Character vector specifying which views to include and their
#'   order. If `NULL` (default), all views are included in their original
#'   order. Names the atlas does not have are dropped with a warning.
#' @param zoom Controls per-view zoom. `NULL`/`FALSE` (default) draws each view
#'   at full extent. `TRUE` zooms each view onto the regions your `data`
#'   covers, taken from its `label` column when it has one and `region`
#'   otherwise; a character vector names the focus explicitly, as either
#'   labels or regions.
#' @param zoom_pad Fractional padding added around the focus window when `zoom`
#'   is active. Defaults to `0.05` (5%).
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
#' @return A `PositionBrain` ggproto object.
#' @examples
#' \dontrun{
#' # Deprecated: prefer position_brain(). Shown for reference only.
#' position_brain_sf("horizontal")
#' }
#' @export
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
  validate_grid_args(position, nrow, ncol)
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

# layout argument validation ----

#' The single atlas type a frame describes
#'
#' Three layout sites branch on the atlas type, and all three read it off an
#' arbitrary data.frame -- `reposition_brain()` is exported and takes any sf
#' frame, so a row-bound mix of a cortical and a slice-based atlas reaches
#' them. Guarding with `[1]` would silently lay the mix out as whichever type
#' came first; leaving it unguarded is a bare "condition has length > 1" error
#' in R >= 4.2. Both are wrong, so say what is wrong.
#'
#' @param data Data.frame with an optional `type` column.
#' @param call Environment to report the error against.
#' @return The single type as a string, or `NA_character_` when absent.
#' @keywords internal
#' @noRd
atlas_type_of <- function(data, call = rlang::caller_env()) {
  types <- unique(data$type)
  if (length(types) > 1) {
    cli::cli_abort(
      c(
        "A single brain layout cannot mix atlas types.",
        "x" = "{.arg data} carries type{?s} {.val {types}}.",
        "i" = "Lay out one atlas at a time."
      ),
      call = call
    )
  }
  if (length(types) == 0) NA_character_ else as.character(types)
}

#' Validate `nrow`/`ncol` against the layout `position`
#'
#' A grid layout is built from `nrow`/`ncol` alone, so a `position` formula
#' supplied alongside them would be discarded. Rather than drop it silently,
#' insist on one or the other. `nrow`/`ncol` also index the grid arithmetic
#' directly, so a zero or fractional value would produce `Inf`/`NaN` cells.
#'
#' @param position The layout spec passed by the user.
#' @param nrow,ncol Requested grid dimensions, or `NULL`.
#' @param call Environment to report the error against.
#' @return Invisibly `NULL`; called for its side effect.
#' @keywords internal
#' @noRd
validate_grid_args <- function(
  position,
  nrow,
  ncol,
  call = rlang::caller_env()
) {
  if ((!is.null(nrow) || !is.null(ncol)) && inherits(position, "formula")) {
    cli::cli_abort(
      c(
        "{.arg nrow}/{.arg ncol} cannot be combined with a layout formula.",
        "x" = "A grid layout would discard {.code {format(position)}}.",
        "i" = "Supply either {.arg position} or {.arg nrow}/{.arg ncol}."
      ),
      call = call
    )
  }

  validate_grid_dim(nrow, "nrow", call)
  validate_grid_dim(ncol, "ncol", call)
  invisible(NULL)
}

#' @param value The supplied dimension.
#' @param arg Argument name, for the error message.
#' @rdname validate_grid_args
#' @keywords internal
#' @noRd
validate_grid_dim <- function(value, arg, call) {
  if (is.null(value) || is_grid_dim(value)) {
    return(invisible(NULL))
  }

  cli::cli_abort(
    c(
      "{.arg {arg}} must be a single positive whole number.",
      "x" = describe_supplied(value)
    ),
    call = call
  )
}

#' @rdname validate_grid_args
#' @keywords internal
#' @noRd
is_grid_dim <- function(value) {
  is.numeric(value) &&
    length(value) == 1L &&
    !is.na(value) &&
    value >= 1 &&
    value == trunc(value)
}

#' @rdname validate_grid_args
#' @keywords internal
#' @noRd
describe_supplied <- function(value) {
  if (is.atomic(value) && length(value) == 1L) {
    cli::format_inline("You supplied {.val {value}}.")
  } else {
    cli::format_inline("You supplied {.obj_type_friendly {value}}.")
  }
}

#' Warn about requested views the atlas does not have
#'
#' `views` filters by `%in%`, so an unknown name is a silent no-op that quietly
#' drops a panel from the plot. Name it instead.
#'
#' @param views Requested view names.
#' @param available View names the atlas actually carries.
#' @return Invisibly `NULL`; called for its side effect.
#' @keywords internal
#' @noRd
warn_unmatched_views <- function(views, available) {
  unmatched <- setdiff(views, available)
  if (length(unmatched) == 0) {
    return(invisible(NULL))
  }

  cli::cli_warn(
    c(
      "!" = "View{?s} {.val {unmatched}} {?is/are} not in the atlas \\
        and {?was/were} dropped.",
      "i" = "Available views: {.val {available}}."
    ),
    class = "ggseg_unmatched_views"
  )
  invisible(NULL)
}

#' Atlas values closest to a set of unmatched ones
#'
#' Cheap fuzzy lookup used to turn "that name is unknown" into "did you mean
#' this". Matches in whichever direction makes the shorter string the pattern,
#' so `"Thalamus Proper"` still finds `"thalamus"`.
#'
#' @param x Unmatched values.
#' @param available The real values.
#' @return Character vector of suggestions, possibly empty.
#' @keywords internal
#' @noRd
nearest_values <- function(x, available) {
  if (length(available) == 0) {
    return(character(0))
  }

  hits <- lapply(x, function(v) {
    close <- vapply(
      available,
      function(a) {
        short <- if (nchar(a) <= nchar(v)) a else v
        long <- if (nchar(a) <= nchar(v)) v else a
        # A one- or two-character pattern fuzzily matches everything, which
        # would suggest the whole atlas instead of a near miss.
        nchar(short) >= 4 &&
          length(agrep(short, long, max.distance = 0.2, ignore.case = TRUE)) > 0
      },
      logical(1),
      USE.NAMES = FALSE
    )
    available[close]
  })

  unique(unlist(hits))
}

# geometry movers ----

#' Extract and validate variable names from a position formula
#'
#' @param pos A formula describing the layout.
#' @return Character vector of variable names (excluding `.`).
#' @keywords internal
#' @noRd
parse_formula_vars <- function(pos) {
  chosen <- all.vars(pos, unique = FALSE)
  chosen <- chosen[chosen != "."]

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

  if (identical(atlas_type_of(data), "cortical")) {
    position <- position_cortical(pos, chosen)
    validate_stacking_formula(pos, position)
  } else {
    result <- position_subcortical(pos, chosen, data)
    position <- result$position
    chosen <- result$chosen
    data <- result$data
  }

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
  if ("hemi" %in% chosen) {
    cli::cli_warn(c(
      "!" = "{.arg hemi} is ignored for slice-based atlases.",
      "i" = paste0(
        "Slice-based atlas views already contain both hemispheres; ",
        "{.arg hemi} will be dropped from the layout variables."
      )
    ))
    chosen <- setdiff(chosen, "hemi")
  }

  if ("type" %in% chosen) {
    data$.view_type <- extract_view_type(data$view)
    chosen[chosen == "type"] <- ".view_type"
  }

  if (length(chosen) == 0) {
    chosen <- "view"
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
  validate_grid_args(pos, nrow, ncol)

  if (!is.null(views)) {
    warn_unmatched_views(views, unique(data$view))
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
#' Assigns grid row/column indices to each cell and returns a list of per-cell
#' data.frames. A cell is one view for a slice-based atlas, whose views already
#' carry both hemispheres, and one hemisphere/view pair for a cortical atlas,
#' where splitting on `view` alone would put both hemispheres in every cell.
#'
#' @param data Data.frame with a `view` column (and `hemi` when cortical).
#' @param nrow Number of grid rows (optional, auto-calculated).
#' @param ncol Number of grid columns (optional, auto-calculated).
#'
#' @return A list with `data` (list of data.frames) and
#'   `position` (column names for grid coordinates).
#' @keywords internal
#' @noRd
split_data_grid <- function(data, nrow = NULL, ncol = NULL) {
  cell_id <- grid_cell_id(data)
  cells <- unique(cell_id)
  n_cells <- length(cells)

  if (is.null(nrow) && is.null(ncol)) {
    ncol <- ceiling(sqrt(n_cells))
    nrow <- ceiling(n_cells / ncol)
  } else if (is.null(nrow)) {
    nrow <- ceiling(n_cells / ncol)
  } else if (is.null(ncol)) {
    ncol <- ceiling(n_cells / nrow)
  }

  idx <- match(cell_id, cells)
  data$.grid_row <- ((seq_along(cells) - 1) %/% ncol + 1)[idx]
  data$.grid_col <- ((seq_along(cells) - 1) %% ncol + 1)[idx]

  df_list <- lapply(cells, function(v) {
    data[cell_id == v, , drop = FALSE]
  })

  list(
    data = df_list,
    position = c(".grid_row", ".grid_col")
  )
}

#' Identify the grid cell each row belongs to
#'
#' @param data Data.frame with `type`, `view` and possibly `hemi`.
#' @return Character vector, one cell identifier per row.
#' @keywords internal
#' @noRd
grid_cell_id <- function(data) {
  cortical <- identical(atlas_type_of(data), "cortical") &&
    "hemi" %in% names(data)
  if (cortical) {
    paste(data$hemi, data$view)
  } else {
    data$view
  }
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

  groups <- if (identical(atlas_type_of(data), "cortical")) {
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
  if (!identical(atlas_type_of(data), "cortical")) {
    return(unique(data$view))
  }
  sides <- unique(data$view)
  left_sides <- sides[sides %in% unique(data$view[data$hemi == "left"])]
  right_sides <- sides[sides %in% unique(data$view[data$hemi == "right"])]
  left_views <- paste("left", left_sides)
  right_views <- paste("right", right_sides)
  c(left_views, right_views)
}
