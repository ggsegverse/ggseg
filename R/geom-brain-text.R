#' Label brain regions
#'
#' `geom_brain_text()` writes a region's name onto the region;
#' `geom_brain_label()` draws it in a box, the same distinction ggplot2 makes
#' between [ggplot2::geom_text()] and [ggplot2::geom_label()].
#'
#' Added after a [geom_brain()] layer, it takes that layer's atlas, layout,
#' hemisphere and view, so the names land on the regions without repeating
#' what the plot already says:
#'
#' ```r
#' ggplot() +
#'   geom_brain(atlas = dk(), hemi = "left") +
#'   geom_brain_text()
#' ```
#'
#' To name some regions and not others, hand it `data` holding those regions,
#' exactly as any other ggplot2 layer takes a subset. Its columns are
#' available to the mapping, so the text can be anything the data carries.
#'
#' @section Where a label sits:
#'
#' Not at the region's centroid. A crescent or horseshoe region -- the
#' cingulate, a tract -- has its centroid outside itself, which would print the
#' name on a neighbouring structure: measured across the bundled atlases, a
#' centroid falls outside its own region for 9% of `dk` shapes and 41% of
#' `tracula` ones. The anchor is the middle of the widest run of region that a
#' horizontal line crosses, which is inside the region by construction.
#'
#' @param mapping Aesthetic mapping, as in any layer. The text defaults to the
#'   region's display name; map `label` to write something else.
#' @param data Regions to name. Defaults to every region the brain layer
#'   draws. A data frame keyed on `label` -- or on `region` -- names only the
#'   regions it holds.
#' @param atlas The atlas to label. Taken from the [geom_brain()] layer it
#'   follows when not given.
#' @param position,hemi,view Taken from the [geom_brain()] layer it follows
#'   when not given, so the labels sit where the regions are.
#' @param ... Passed to [ggplot2::geom_text()] or [ggplot2::geom_label()]:
#'   `size`, `colour`, `fontface`, `nudge_x` and the rest.
#' @param inherit.aes Whether to inherit the plot's aesthetic mapping.
#'
#' @return A ggplot2 layer.
#' @seealso [annotate_brain()], which labels the views rather than the regions.
#' @export
#' @examples
#' library(ggplot2)
#'
#' ggplot() +
#'   geom_brain(atlas = dk(), hemi = "left") +
#'   geom_brain_text(
#'     data = data.frame(label = c("lh_insula", "lh_precuneus")),
#'     size = 3
#'   )
geom_brain_text <- function(
  mapping = NULL,
  data = NULL,
  atlas = NULL,
  position = NULL,
  hemi = NULL,
  view = NULL,
  ...,
  inherit.aes = FALSE
) {
  brain_text_layer(
    mapping = mapping,
    data = data,
    atlas = atlas,
    position = position,
    hemi = hemi,
    view = view,
    geom = ggplot2::GeomText,
    inherit.aes = inherit.aes,
    ...
  )
}

#' @rdname geom_brain_text
#' @export
geom_brain_label <- function(
  mapping = NULL,
  data = NULL,
  atlas = NULL,
  position = NULL,
  hemi = NULL,
  view = NULL,
  ...,
  inherit.aes = FALSE
) {
  brain_text_layer(
    mapping = mapping,
    data = data,
    atlas = atlas,
    position = position,
    hemi = hemi,
    view = view,
    geom = ggplot2::GeomLabel,
    inherit.aes = inherit.aes,
    ...
  )
}

#' @noRd
brain_text_layer <- function(
  mapping,
  data,
  atlas,
  position,
  hemi,
  view,
  geom,
  inherit.aes,
  ...
) {
  text_layer <- ggplot2::layer(
    geom = geom,
    stat = ggplot2::StatIdentity,
    data = data,
    mapping = mapping,
    position = "identity",
    params = list(...),
    inherit.aes = inherit.aes,
    layer_class = LayerBrainText,
    check.aes = FALSE
  )

  text_layer$brain_atlas <- atlas
  text_layer$brain_position <- position
  text_layer$brain_hemi <- hemi
  text_layer$brain_view <- view
  text_layer
}

#' The layer behind [geom_brain_text()]
#'
#' `setup_layer()` runs at plot-build time, which is what lets it read the
#' [geom_brain()] layer it follows: the atlas, layout, hemisphere and view come
#' from there unless the caller gave its own, so labels cannot end up
#' describing a different brain from the one drawn. The user's `data`, when
#' there is any, selects which regions are named -- the ggplot2 way of taking
#' a subset -- and its columns stay available to the mapping.
#' @format NULL
#' @usage NULL
#' @export
LayerBrainText <- ggproto(
  "LayerBrainText",
  ggplot2_Layer(),
  setup_layer = function(self, data, plot) {
    user_data <- ggproto_parent(ggplot2_Layer(), self)$setup_layer(data, plot)

    source_layer <- brain_layer_before(self, plot)
    atlas <- self$brain_atlas %||% source_layer$brain_atlas
    if (is.null(atlas)) {
      cli::cli_abort(c(
        "No atlas to label.",
        "i" = "Add {.fn geom_brain_text} after a {.fn geom_brain} layer, or
               pass {.arg atlas}."
      ))
    }

    anchors <- brain_label_anchors(
      atlas,
      position = self$brain_position %||% source_layer$brain_position,
      hemi = self$brain_hemi %||% source_layer$brain_hemi,
      view = self$brain_view %||% source_layer$brain_view
    )
    anchors <- select_labelled_regions(anchors, user_data)

    # `setup_layer()` hands back the data the layer will draw; the mapping is
    # settled on `self`, which is the environment the layer keeps.
    self$computed_mapping <- default_label_mapping(
      self$computed_mapping,
      anchors
    )
    anchors
  }
)

#' The brain layer this one annotates, if there is one
#'
#' The nearest earlier layer carrying an atlas -- nearest rather than first,
#' because a plot can draw two atlases and a label layer belongs to the one it
#' was added after.
#' @noRd
brain_layer_before <- function(self, plot) {
  layers <- plot$layers
  mine <- which(vapply(layers, identical, logical(1), self))
  before <- if (length(mine)) layers[seq_len(mine[1] - 1L)] else layers

  for (layer in rev(before)) {
    if (!is.null(layer$brain_atlas)) {
      return(layer)
    }
  }
  list()
}

#' Keep the regions the user asked for, carrying their own columns along
#' @noRd
select_labelled_regions <- function(anchors, user_data) {
  if (!is.data.frame(user_data) || nrow(user_data) == 0) {
    return(anchors)
  }

  key <- intersect(c("label", "region"), names(user_data))
  if (length(key) == 0) {
    cli::cli_abort(c(
      "{.arg data} has no column in common with the atlas.",
      "i" = "Key it on {.field label}, or on {.field region}."
    ))
  }
  key <- key[1]

  named <- merge(anchors, user_data, by = key, suffixes = c("", ".data"))
  if (nrow(named) == 0) {
    cli::cli_warn(c(
      "No region to label.",
      "i" = "No {.field {key}} in {.arg data} is drawn by the atlas."
    ))
  }
  named[order(named$view, named[[key]]), , drop = FALSE]
}

#' Write the display name unless the caller mapped something else
#' @noRd
default_label_mapping <- function(mapping, anchors) {
  mapping <- mapping %||% ggplot2::aes()

  if (is.null(mapping$x)) {
    mapping$x <- ggplot2::aes(x = .data$x)$x
  }
  if (is.null(mapping$y)) {
    mapping$y <- ggplot2::aes(y = .data$y)$y
  }
  if (is.null(mapping$label)) {
    text <- if ("display" %in% names(anchors)) "display" else "label"
    mapping$label <- ggplot2::aes(label = .data[[text]])$label
  }
  mapping
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
  view = NULL
) {
  atlas <- ggseg.formats::as_ggseg_atlas(atlas)
  flat <- prepare_polygon_atlas(
    atlas,
    hemi = hemi,
    view = view,
    position = position,
    context = FALSE
  )

  carry <- intersect(c("label", "region", "display", "hemi"), names(flat))
  pieces <- split(flat, list(flat$label, flat$view, flat$.group), drop = TRUE)
  anchors <- lapply(pieces, function(piece) {
    xy <- scanline_anchor(piece$x, piece$y)
    out <- piece[1, carry, drop = FALSE]
    out$view <- piece$view[1]
    out$x <- xy[[1]]
    out$y <- xy[[2]]
    out$.area <- diff(range(piece$x)) * diff(range(piece$y))
    out
  })
  anchors <- do.call(rbind, anchors)

  # A region split across pieces -- an island, a region crossing a view seam --
  # is named once, on the piece with room to carry it.
  anchors <- anchors[order(-anchors$.area), , drop = FALSE]
  anchors <- anchors[!duplicated(anchors[, c("label", "view")]), , drop = FALSE]
  rownames(anchors) <- NULL
  anchors[, setdiff(names(anchors), ".area"), drop = FALSE]
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
