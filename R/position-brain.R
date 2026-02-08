# position ----

#' Reposition brain slices
#'
#' Function for repositioning
#' pre-joined atlas data (i.e. data and atlas
#' already joined to a single data frame).
#' This makes it possible for users to
#' reposition the geometry data for the atlas
#' for control over final plot layout. For even
#' more detailed control over the positioning,
#' the "hemi" and "view" columns should be
#' converted into factors and ordered by wanted
#' order of appearance.
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
#' @examples
#' reposition_brain(dk, hemi ~ view)
#' reposition_brain(dk, view ~ hemi)
#' reposition_brain(dk, hemi + view ~ .)
#' reposition_brain(dk, . ~ hemi + view)
#'
#' \dontrun{
#' # Subcortical with grid layout
#' reposition_brain(aseg_data, nrow = 2)
#'
#' # Subcortical with specific views
#' reposition_brain(aseg_data, views = c("sagittal", "axial_3"))
#' }
reposition_brain <- function(
  data,
  position = "horizontal",
  nrow = NULL,
  ncol = NULL,
  views = NULL
) {
  data <- as.data.frame(data, stringsAsFactors = FALSE)
  frame_2_position(data, position, nrow = nrow, ncol = ncol, views = views)
}


#' Alter brain atlas position
#'
#' Function to be used in the position argument in geom_brain
#' to alter the position of the brain slice/views.
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
#'
#' @export
#' @return a ggproto object
#' @importFrom ggplot2 ggproto
#' @examples
#' library(ggplot2)
#'
#' # Cortical atlas with formula
#' ggplot() +
#'   geom_brain(
#'     atlas = dk, aes(fill = region),
#'     position = position_brain(. ~ view + hemi),
#'     show.legend = FALSE
#'   )
#'
#' ggplot() +
#'   geom_brain(
#'     atlas = dk, aes(fill = region),
#'     position = position_brain(view ~ hemi),
#'     show.legend = FALSE
#'   )
#'
#' \dontrun{
#' # Subcortical atlas with grid layout
#' ggplot() +
#'   geom_brain(
#'     atlas = aseg, aes(fill = region),
#'     position = position_brain(nrow = 2)
#'   )
#'
#' # Subcortical with specific view order
#' ggplot() +
#'   geom_brain(
#'     atlas = aseg, aes(fill = region),
#'     position = position_brain(
#'       views = c("sagittal", "axial_3", "coronal_2"),
#'       nrow = 1
#'     )
#'   )
#'
#' # Subcortical with type-based formula (axial/coronal/sagittal)
#' ggplot() +
#'   geom_brain(
#'     atlas = aseg, aes(fill = region),
#'     position = position_brain(type ~ .)
#'   )
#' }
position_brain <- function(
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

PositionBrain <- ggplot2::ggproto(
  "PositionBrain",
  ggplot2:::Position,
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

    data <- df3

    df3
  }
)

# geometry movers ----

position_formula <- function(pos, data) {
  chosen <- all.vars(pos, unique = FALSE)
  chosen <- chosen[!grepl("\\.", chosen)]

  if (any(duplicated(chosen))) {
    cli::cli_abort(
      "Cannot position brain with the same data as columns and rows"
    )
  }

  atlas_type <- unique(data$type)[1]

  if (atlas_type == "cortical") {
    if (length(chosen) < 2) {
      missing_vars <- c("view", "hemi")[!c("view", "hemi") %in% chosen]
      cli::cli_abort(c(
        "Position formula not correct.",
        "x" = paste("Missing:", paste(missing_vars, collapse = " & "))
      ))
    }
    position <- if (length(grep("\\+", pos)) > 0) {
      ifelse(grep("^\\.", pos) == 2, "columns", "rows")
    } else {
      chosen
    }
  } else {
    if ("type" %in% chosen) {
      data$.view_type <- extract_view_type(data$view)
      chosen[chosen == "type"] <- ".view_type"
    }

    if (length(chosen) == 1) {
      position <- if (grepl("~\\s*\\.", deparse(pos))) {
        "rows"
      } else {
        "columns"
      }
    } else {
      position <- chosen
    }
  }

  has_both <- sum(grepl("\\.|~", pos)) == 2
  is_single <- position %in% c("rows", "columns")
  if (all(!has_both & is_single)) {
    cli::cli_abort(
      "Formula for a single row or column must contain both a '.' and '~'"
    )
  }

  list(
    position = position,
    chosen = chosen,
    data = data
  )
}


extract_view_type <- function(views) {
  vapply(
    views,
    function(v) {
      parts <- strsplit(v, "_")[[1]]
      if (length(parts) >= 1) parts[1] else v # nocov
    },
    character(1),
    USE.NAMES = FALSE
  )
}


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

  df2 <- lapply(dfpos$data, gather_geometry)
  posi <- ifelse(length(dfpos$position) > 1, "grid", dfpos$position)

  df3 <- switch(
    posi,
    rows = stack_vertical(df2),
    columns = stack_horizontal(df2),
    grid = stack_grid(df2, dfpos$position[1], dfpos$position[2])
  )

  df4 <- st_as_sf(df3$df)
  attr(sf::st_geometry(df4), "bbox") <- df3$box

  df4
}


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

split_data <- function(data, position) {
  if (inherits(position, "formula")) {
    pos <- position_formula(position, data)
    if (!is.null(pos$data)) {
      data <- pos$data
    }
    df2 <- dplyr::group_by_at(data, pos$chosen)
    df2 <- dplyr::group_split(df2)
    pos <- pos$position
  } else {
    layout_direction <- "columns"
    if (length(position) == 1) {
      if (position %in% c("horizontal", "vertical")) {
        layout_direction <- ifelse(position == "vertical", "rows", "columns")
        position <- default_order(data)
      }
    }
    pos <- as.data.frame(strsplit(position, " "), stringsAsFactors = FALSE)
    atlas_type <- unique(data$type)[1]
    if (atlas_type == "cortical") {
      k <- cbind(
        pos[2, ] %in% data$view,
        pos[1, ] %in% data$hemi
      )
      k <- vapply(seq_len(nrow(k)), function(x) sum(k[x, ]), numeric(1))
      pos <- pos[ifelse(k == 2, TRUE, FALSE)]

      df2 <- lapply(pos, function(x) {
        data[data$hemi == x[1] & data$view == x[2], ]
      })
    } else {
      df2 <- lapply(pos, function(x) {
        data[data$view == x, ]
      })
    }
    pos <- layout_direction
  }

  list(data = df2, position = pos)
}

gather_geometry <- function(df) {
  bbx <- sf::st_bbox(df$geometry)
  df$geometry <- df$geometry - bbx[c("xmin", "ymin")]
  df
}

center_view <- function(df, cell_size, grid_pos) {
  bbox <- sf::st_bbox(df$geometry)
  view_width <- bbox["xmax"] - bbox["xmin"]
  view_height <- bbox["ymax"] - bbox["ymin"]
  view_size <- c(view_width, view_height)
  center_offset <- (cell_size - view_size) / 2
  df$geometry <- df$geometry + grid_pos + center_offset
  df
}

stack_horizontal <- function(df) {
  sep <- get_sep(df)
  cell_size <- sep / 1.2

  bx <- list()
  for (k in seq_along(df)) {
    df[[k]] <- center_view(df[[k]], cell_size, c((k - 1) * sep[1], 0))
    bx[[k]] <- sf::st_bbox(df[[k]]$geometry)
  }

  list(df = do.call(rbind, df), box = get_box(bx))
}

stack_vertical <- function(df) {
  sep <- get_sep(df)
  cell_size <- sep / 1.2

  bx <- list()
  for (k in seq_along(df)) {
    df[[k]] <- center_view(df[[k]], cell_size, c(0, (k - 1) * sep[2]))
    bx[[k]] <- sf::st_bbox(df[[k]]$geometry)
  }

  list(df = do.call(rbind, df), box = get_box(bx))
}

stack_grid <- function(df, rows, columns) {
  bx <- list()
  sep <- get_sep(df)

  get_unique <- function(x, col) {
    val <- unique(x[[col]])
    if (is.numeric(val)) as.character(val) else val
  }

  row_vals <- unique(vapply(df, get_unique, character(1), rows))
  col_vals <- unique(vapply(df, get_unique, character(1), columns))

  df_ordered <- list()
  for (r in seq_along(row_vals)) {
    for (c in seq_along(col_vals)) {
      match_fn <- function(x) {
        row_match <- unique(x[[rows]]) == row_vals[r]
        col_match <- unique(x[[columns]]) == col_vals[c]
        isTRUE(row_match) && isTRUE(col_match)
      }
      idx <- which(vapply(df, match_fn, logical(1)))
      if (length(idx) == 1) {
        df_ordered[[length(df_ordered) + 1]] <- list(
          data = df[[idx]],
          row = r,
          col = c
        )
      }
    }
  }

  cell_size <- sep / 1.2
  df_positioned <- lapply(df_ordered, function(item) {
    grid_pos <- c((item$col - 1) * sep[1], (item$row - 1) * sep[2])
    center_view(item$data, cell_size, grid_pos)
  })

  bx <- lapply(df_positioned, function(x) sf::st_bbox(x$geometry))
  result_df <- do.call(rbind, df_positioned)

  cols_to_remove <- c(
    "xmin",
    "xmax",
    "ymin",
    "ymax",
    ".grid_row",
    ".grid_col",
    ".view_type"
  )
  cols_to_remove <- cols_to_remove[cols_to_remove %in% names(result_df)]
  if (length(cols_to_remove) > 0) {
    result_df[, cols_to_remove] <- NULL
  }

  list(
    df = result_df,
    box = get_box(bx)
  )
}

get_box <- function(bx) {
  bx <- do.call(rbind, bx)
  pad <- max(bx) * .01
  bx <- c(
    -pad,
    -pad,
    max(bx[, "xmax"]) + pad,
    max(bx[, "ymax"]) + pad
  )
  x <- stats::setNames(bx, c("xmin", "ymin", "xmax", "ymax"))
  class(x) <- "bbox"
  x
}

get_sep <- function(data) {
  get_bbox <- function(x) sf::st_bbox(x$geometry)
  bboxes <- vapply(data, get_bbox, numeric(4))
  sep <- c(max(bboxes[3, ]), max(bboxes[4, ]))
  c("x" = sep[1] + sep[1] * .2, "y" = sep[2] + sep[2] * .2)
}

default_order <- function(data) {
  if (unique(data$type) == "cortical") {
    sides <- unique(data$view)
    left_sides <- sides[sides %in% unique(data$view[data$hemi == "left"])]
    right_sides <- sides[sides %in% unique(data$view[data$hemi == "right"])]
    left_views <- paste("left", left_sides)
    right_views <- paste("right", right_sides)
    return(c(left_views, right_views))
  }
  unique(data$view)
}
