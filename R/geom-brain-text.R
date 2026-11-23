#' Label brain regions
#'
#' `geom_brain_text()` writes a region's name onto the region;
#' `geom_brain_label()` draws it in a box, the same distinction ggplot2 makes
#' between [ggplot2::geom_text()] and [ggplot2::geom_label()].
#'
#' Pass the same `atlas`, `position`, `hemi` and `view` you gave
#' [geom_brain()] and the labels land on the regions, because both read the
#' laid-out geometry from the same place.
#'
#' Every region of a cortical atlas at once is unreadable whatever is done
#' with it, so name the regions a figure is actually about with `regions`.
#' `...` reaches the underlying ggplot2 layer, so `size`, `colour`,
#' `fontface`, `nudge_x` and `nudge_y` all work as usual.
#'
#' @section Where a label sits:
#'
#' Not at the region's centroid. A crescent or horseshoe region -- the
#' cingulate, a tract -- has its centroid outside itself, which would print the
#' name on a neighbouring structure: measured across the bundled atlases, a
#' centroid falls outside its own region for 9% of `dk` shapes and 41% of
#' `tracula` ones. The anchor here is the middle of the widest run of region
#' that a horizontal line crosses, which is inside the region by construction.
#'
#' @param atlas A `ggseg_atlas`, as given to [geom_brain()].
#' @param position The layout passed to [geom_brain()]. Labels follow it.
#' @param hemi,view Restrict to these hemispheres or views, as in
#'   [geom_brain()].
#' @param regions Label only these regions, matched on `region` or `label`.
#'   Naming the few regions a figure is about is usually what is wanted;
#'   every region of a cortical atlas at once is unreadable.
#' @param label Column of the atlas core to write. Defaults to `display`, the
#'   human-readable name, falling back to `label` where an atlas has none.
#' @param ... Passed to [ggplot2::geom_text()] or [ggplot2::geom_label()].
#'
#' @return A ggplot2 layer.
#' @seealso [annotate_brain()], which labels the views rather than the regions.
#' @export
#' @examples
#' library(ggplot2)
#'
#' ggplot() +
#'   geom_brain(atlas = dk()) +
#'   geom_brain_text(atlas = dk(), view = "lateral", hemi = "left", size = 2)
geom_brain_text <- function(
  atlas,
  position = position_brain(),
  hemi = NULL,
  view = NULL,
  regions = NULL,
  label = NULL,
  ...
) {
  brain_text_layer(
    atlas = atlas,
    position = position,
    hemi = hemi,
    view = view,
    regions = regions,
    label = label,
    boxed = FALSE,
    ...
  )
}

#' @rdname geom_brain_text
#' @export
geom_brain_label <- function(
  atlas,
  position = position_brain(),
  hemi = NULL,
  view = NULL,
  regions = NULL,
  label = NULL,
  ...
) {
  brain_text_layer(
    atlas = atlas,
    position = position,
    hemi = hemi,
    view = view,
    regions = regions,
    label = label,
    boxed = TRUE,
    ...
  )
}

#' Build the text or label layer behind the two exports
#' @noRd
brain_text_layer <- function(
  atlas,
  position,
  hemi,
  view,
  regions,
  label,
  boxed,
  ...
) {
  data <- brain_label_anchors(
    atlas,
    position = position,
    hemi = hemi,
    view = view,
    regions = regions,
    label = label
  )

  geom_fn <- if (boxed) ggplot2::geom_label else ggplot2::geom_text

  geom_fn(
    data = data,
    mapping = ggplot2::aes(
      x = .data$x,
      y = .data$y,
      label = .data$.brain_label
    ),
    inherit.aes = FALSE,
    ...
  )
}

#' One anchor per region per view, in the laid-out coordinate space
#'
#' Reads the same flattened geometry [geom_brain()] draws, so a label cannot
#' drift from its region: the layout, the hemisphere and view filtering and
#' the zoom have all been applied by the time this sees the coordinates.
#' Context geometry is excluded -- a backdrop is not a region and has no name.
#' @noRd
brain_label_anchors <- function(
  atlas,
  position = NULL,
  hemi = NULL,
  view = NULL,
  regions = NULL,
  label = NULL
) {
  atlas <- ggseg.formats::as_ggseg_atlas(atlas)
  flat <- prepare_polygon_atlas(
    atlas,
    hemi = hemi,
    view = view,
    position = position,
    context = FALSE
  )

  if (!is.null(regions)) {
    # Match what the user can see as well as what the atlas stores: the name
    # on the plot is `display` ("superior frontal"), while `region` is
    # "superiorfrontal" -- asking for the former must not silently miss.
    matched <- flat$region %in%
      regions |
      flat$label %in% regions |
      ("display" %in% names(flat) & flat$display %in% regions)
    if (!any(matched)) {
      cli::cli_abort(c(
        "No region of {.arg atlas} matches {.arg regions}.",
        "i" = "Match on {.field region}, {.field display} or {.field label};
               see {.fn ggseg.formats::atlas_regions}."
      ))
    }
    flat <- flat[matched, , drop = FALSE]
  }

  label <- label %||% if ("display" %in% names(flat)) "display" else "label"
  if (!label %in% names(flat)) {
    cli::cli_abort(c(
      "{.arg label} must name a column of the atlas core.",
      "x" = "{.val {label}} is not one of {.val {names(flat)}}."
    ))
  }

  flat$.brain_label <- flat[[label]]
  flat$.brain_label[is.na(flat$.brain_label)] <- flat$label[
    is.na(flat$.brain_label)
  ]

  pieces <- split(flat, list(flat$label, flat$view, flat$.group), drop = TRUE)
  anchors <- lapply(pieces, function(piece) {
    xy <- scanline_anchor(piece$x, piece$y)
    data.frame(
      label = piece$label[1],
      .brain_label = piece$.brain_label[1],
      view = piece$view[1],
      hemi = piece$hemi[1],
      x = xy[[1]],
      y = xy[[2]],
      area = diff(range(piece$x)) * diff(range(piece$y)),
      stringsAsFactors = FALSE
    )
  })
  anchors <- do.call(rbind, anchors)

  # A region split across pieces -- an island, a region crossing a view seam --
  # gets its name once, on the piece with room to carry it.
  anchors <- anchors[order(-anchors$area), , drop = FALSE]
  keep <- !duplicated(anchors[, c("label", "view")])
  anchors <- anchors[keep, , drop = FALSE]
  rownames(anchors) <- NULL
  anchors[, setdiff(names(anchors), "area"), drop = FALSE]
}

#' A point inside a polygon, on its widest horizontal run
#'
#' The centroid of a crescent lies outside it, which would print a region's
#' name on its neighbour. Scanning horizontal lines and taking the middle of
#' the widest interior run keeps the anchor inside the shape, and prefers the
#' fat part of it, which is where a label fits.
#' @noRd
scanline_anchor <- function(x, y) {
  if (length(x) < 3L || anyNA(x) || anyNA(y)) {
    return(list(mean(x, na.rm = TRUE), mean(y, na.rm = TRUE)))
  }

  scanlines <- seq(min(y), max(y), length.out = 25L)
  scanlines <- scanlines[-c(1L, length(scanlines))]
  best <- NULL
  nxt <- c(seq_along(x)[-1L], 1L)

  for (line in scanlines) {
    crosses <- (y <= line & y[nxt] > line) | (y[nxt] <= line & y > line)
    if (!any(crosses)) {
      next
    }
    at <- (line - y[crosses]) / (y[nxt][crosses] - y[crosses])
    cuts <- sort(x[crosses] + at * (x[nxt][crosses] - x[crosses]))
    if (length(cuts) < 2L) {
      next
    }
    starts <- cuts[seq(1L, length(cuts) - 1L, by = 2L)]
    ends <- cuts[seq(2L, length(cuts), by = 2L)]
    widest <- which.max(ends - starts)
    width <- ends[widest] - starts[widest]
    if (is.null(best) || width > best$width) {
      best <- list(
        x = (starts[widest] + ends[widest]) / 2,
        y = line,
        width = width
      )
    }
  }

  if (is.null(best)) {
    list(mean(x), mean(y))
  } else {
    list(best$x, best$y)
  }
}
