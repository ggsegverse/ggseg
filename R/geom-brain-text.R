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
#' @param nudge_x,nudge_y Move the label off its region, in atlas units -- the
#'   same units the plot's axes are in, so a `dk` view being about 215 units
#'   wide, 30 is a visible shift. One value moves every label; a vector as long
#'   as the data moves each one separately. A nudged label keeps a leader line
#'   back to its region and turns to face away from it.
#' @param ... Passed to [ggplot2::geom_text()] or [ggplot2::geom_label()]:
#'   `size`, `colour`, `fontface` and the rest. The leader line takes
#'   `box.padding` and `point.padding` (its gap from the text and from the
#'   region) and `min.segment.length` (below which it is not drawn at all).
#' @param inherit.aes Whether to inherit the plot's aesthetic mapping.
#'
#' @section Aesthetics:
#'
#' Everything [ggplot2::geom_text()] or [ggplot2::geom_label()] understands,
#' and two of its own: `segment.colour` and `segment.linewidth`, the colour
#' and width of the leader line. They are aesthetics rather than arguments so
#' that one label can be accented and the rest left quiet:
#'
#' ```r
#' geom_brain_text(
#'   data = regions,
#'   aes(segment.colour = accent, segment.linewidth = weight)
#' )
#' ```
#'
#' Neither is scaled, so map them to a column that already holds the values
#' you want drawn, the way `scale_colour_identity()` works. A connector given
#' no colour of its own takes the colour of its text.
#'
#' `label` is an aesthetic like any other. Left alone it writes the region's
#' display name, and mapping it writes whatever you say instead, including an
#' expression over your own columns:
#' `aes(label = sprintf("%s (%.1f)", region, estimate))`.
#'
#' @section Moving a label off a cramped region:
#'
#' A region too small or too narrow for its own name is the normal case, not
#' the exception -- `banks of superior temporal sulcus` is wider than a quarter
#' of a `dk` view at 8pt. Nudge those labels clear and the connector back to
#' the region is drawn for you, so nothing has to be said twice:
#'
#' ```r
#' ggplot() +
#'   geom_brain(atlas = dk(), hemi = "left", view = "lateral") +
#'   geom_brain_text(
#'     data = data.frame(label = c("lh_insula", "lh_temporalpole")),
#'     nudge_x = c(0, -40),
#'     nudge_y = c(0, -30)
#'   )
#' ```
#'
#' The label with no nudge is drawn plainly, on its region, with no line.
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
  nudge_x = 0,
  nudge_y = 0,
  ...,
  inherit.aes = FALSE
) {
  brain_text_layer(
    mapping = mapping,
    data = data,
    atlas = atlas,
    position = position,
    hemi = hemi,
    nudge_x = nudge_x,
    nudge_y = nudge_y,
    view = view,
    geom = GeomBrainText,
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
  nudge_x = 0,
  nudge_y = 0,
  ...,
  inherit.aes = FALSE
) {
  brain_text_layer(
    mapping = mapping,
    data = data,
    atlas = atlas,
    position = position,
    hemi = hemi,
    nudge_x = nudge_x,
    nudge_y = nudge_y,
    view = view,
    geom = GeomBrainLabel,
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
  nudge_x,
  nudge_y,
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
  text_layer$brain_nudge <- list(x = nudge_x, y = nudge_y)
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
#' @keywords internal
#' @noRd
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
    anchors <- nudge_label_anchors(anchors, self$brain_nudge)

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

  # `.brain_row` is the caller's own row order, which `merge()` destroys and
  # which a per-label `nudge_x` is written against. A region drawn in four
  # views becomes four anchors that all belong to the one row the caller
  # wrote, so the nudge follows the row, not the anchor.
  user_data[[".brain_row"]] <- seq_len(nrow(user_data))
  named <- merge(anchors, user_data, by = key, suffixes = c("", ".data"))
  if (nrow(named) == 0) {
    cli::cli_warn(c(
      "No region to label.",
      "i" = "No {.field {key}} in {.arg data} is drawn by the atlas."
    ))
  }
  named[order(named$.brain_row, named$view), , drop = FALSE]
}

#' Write the display name unless the caller mapped something else
#' @noRd
#' Move each label off its anchor, remembering where it came from
#'
#' The remembered anchor is what the leader line is drawn to and what the
#' justification is derived from, so recording it is what makes the nudge
#' self-documenting rather than just a shifted label.
#' @noRd
nudge_label_anchors <- function(anchors, nudge) {
  if (is.null(nudge) || !nrow(anchors)) {
    return(anchors)
  }
  if (all(nudge$x == 0) && all(nudge$y == 0)) {
    return(anchors)
  }

  # One nudge per row the caller wrote, so a region drawn in several views
  # moves the same way in each, and a count mismatch is their row count.
  row <- anchors$.brain_row %||% seq_len(nrow(anchors))
  wanted <- max(row)

  for (arg in c("x", "y")) {
    if (!length(nudge[[arg]]) %in% c(1L, wanted)) {
      cli::cli_abort(c(
        "{.arg nudge_{arg}} must be one value, or one per label.",
        "x" = "It has {length(nudge[[arg]])}, for {wanted} label{?s}.",
        "i" = "The labels are {.val {unique(anchors$label)}}."
      ))
    }
  }

  anchors$x_orig <- anchors$x
  anchors$y_orig <- anchors$y
  anchors$x <- anchors$x + rep_len(nudge$x, wanted)[row]
  anchors$y <- anchors$y + rep_len(nudge$y, wanted)[row]
  anchors
}

#' @noRd
default_label_mapping <- function(mapping, anchors) {
  mapping <- mapping %||% ggplot2::aes()

  if (is.null(mapping$x)) {
    mapping$x <- ggplot2::aes(x = .data$x)$x
  }
  if (is.null(mapping$y)) {
    mapping$y <- ggplot2::aes(y = .data$y)$y
  }
  for (recorded in intersect(c("x_orig", "y_orig"), names(anchors))) {
    if (is.null(mapping[[recorded]])) {
      mapping[[recorded]] <- ggplot2::aes(z = .data[[recorded]])$z
    }
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
  nxt <- c(seq_along(x)[-1L], 1L)

  runs <- lapply(scanlines, widest_run_at, x = x, y = y, nxt = nxt)
  runs <- Filter(Negate(is.null), runs)
  if (length(runs) == 0) {
    return(list(mean(x), mean(y)))
  }

  widths <- vapply(runs, function(run) run$width, numeric(1))
  best <- runs[[which.max(widths)]]
  list(best$x, best$y)
}

#' The widest stretch of polygon one horizontal line crosses, or `NULL`
#'
#' A line can miss the polygon, or clip a single vertex, in which case there
#' is no run to speak of.
#' @noRd
widest_run_at <- function(line, x, y, nxt) {
  crosses <- (y <= line & y[nxt] > line) | (y[nxt] <= line & y > line)
  if (!any(crosses)) {
    return(NULL)
  }

  at <- (line - y[crosses]) / (y[nxt][crosses] - y[crosses])
  cuts <- sort(x[crosses] + at * (x[nxt][crosses] - x[crosses]))
  if (length(cuts) < 2L) {
    return(NULL)
  }

  starts <- cuts[seq(1L, length(cuts) - 1L, by = 2L)]
  ends <- cuts[seq(2L, length(cuts), by = 2L)]
  widest <- which.max(ends - starts)

  list(
    x = (starts[widest] + ends[widest]) / 2,
    y = line,
    width = ends[widest] - starts[widest]
  )
}
