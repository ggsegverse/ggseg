# sf-optional brain renderer over flat polygon data ----
#
# Renders a brain atlas using ggplot2::geom_polygon over the polygon
# representation in atlas$data$polygons (see ggseg.formats). No sf objects,
# no GDAL/GEOS/PROJ system libraries needed — enables wasm and air-gapped
# builds. First piece of Epic ggsegverse/ggseg#128.
#
# Scope of this iteration: simple per-view stacking from the polygons'
# pre-positioned coordinates. position_brain_sf() is not yet wired up for
# the polygon path; users wanting custom layouts should keep using
# geom_brain_sf() for now.

#' Plot brain atlas regions from the polygon representation (sf-optional)
#'
#' Renders a `ggseg_atlas` via `ggplot2::geom_polygon` using the polygon
#' representation in `atlas$data$polygons`. Use this on atlases produced by
#' `ggseg.formats::as_polygon_atlas()` — or any atlas carrying a
#' `$data$polygons` slot — to render without requiring the `sf` package
#' or its GDAL/GEOS/PROJ system libraries.
#'
#' Hole geometry round-trips correctly via the `subgroup` aesthetic
#' (`grid::pathGrob` even-odd fill).
#'
#' @param mapping Set of aesthetic mappings created by `ggplot2::aes()`.
#' @param data A data.frame containing variables to map. If `NULL`, the
#'   atlas is plotted without user data.
#' @param atlas A `ggseg_atlas` object carrying `$data$polygons`.
#' @param hemi Character vector of hemispheres to include.
#' @param view Character vector of views to include.
#' @param position Position adjustment. Defaults to [position_brain_lite()],
#'   which lays views out horizontally without sf. Pass `"identity"` to use
#'   the polygons' raw coordinates.
#' @param show.legend Logical. Should this layer be included in legends?
#' @param inherit.aes Logical. If `FALSE`, overrides the default aesthetics.
#' @param ... Additional arguments passed to `ggplot2::geom_polygon()`.
#'
#' @return A list of ggplot2 layer and coord objects.
#' @export
#' @importFrom ggplot2 aes geom_polygon coord_fixed scale_fill_manual
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' poly <- ggseg.formats::as_polygon_atlas(dk())
#' ggplot() + geom_brain_polygon(atlas = poly)
#' }
geom_brain_polygon <- function(
  mapping = aes(),
  data = NULL,
  atlas,
  hemi = NULL,
  view = NULL,
  position = position_brain_polygon(),
  show.legend = NA,
  inherit.aes = TRUE,
  ...
) {
  flat <- prepare_polygon_atlas(
    atlas,
    hemi = hemi,
    view = view,
    position = position
  )

  if (!is.null(data)) {
    flat <- brain_join_polygon(data, flat)
  }

  base_mapping <- aes(
    x = .data$x,
    y = .data$y,
    group = .data$.feature_id,
    subgroup = .data$subgroup
  )
  if (!"fill" %in% names(mapping)) {
    base_mapping$fill <- quote(.data$region)
  }
  user_mapping <- utils::modifyList(base_mapping, as.list(mapping))
  class(user_mapping) <- "uneval"

  dots <- list(...)
  if (!"colour" %in% names(dots) && !"color" %in% names(dots)) {
    dots$colour <- "grey35"
  }
  if (!"linewidth" %in% names(dots) && !"size" %in% names(dots)) {
    dots$linewidth <- 0.2
  }

  layer <- do.call(
    geom_polygon,
    c(
      list(
        mapping = user_mapping,
        data = flat,
        position = "identity",
        show.legend = show.legend,
        inherit.aes = inherit.aes
      ),
      dots
    )
  )

  result <- list(layer, coord_fixed(clip = "off"))

  if (!is.null(atlas$palette) && !"fill" %in% names(mapping)) {
    result <- c(
      result,
      list(scale_fill_manual(values = atlas$palette, na.value = "grey"))
    )
  }

  result
}


#' Flatten a polygon atlas into a row-per-point data.frame for geom_polygon
#'
#' Unnests `atlas$data$polygons`, joins with `atlas$core`, applies optional
#' hemi/view filters, and adds the `.feature_id` helper column that the
#' polygon renderer maps to `group` so each (label, view, group) polygon
#' piece renders as one ring set.
#'
#' @keywords internal
#' @noRd
prepare_polygon_atlas <- function(
  atlas,
  hemi = NULL,
  view = NULL,
  position = NULL
) {
  if (is.null(atlas$data$polygons)) {
    cli::cli_abort(c(
      "{.arg atlas} has no {.field polygons} slot.",
      "i" = "Convert with {.fn ggseg.formats::as_polygon_atlas} first, or use
            {.fn geom_brain} for sf-backed atlases."
    ))
  }

  flat <- tidyr::unnest(atlas$data$polygons, cols = "geometry")
  flat <- dplyr::left_join(
    flat,
    atlas$core,
    by = "label",
    relationship = "many-to-many"
  )

  if (!is.null(view)) {
    avail <- unique(flat$view)
    invalid <- setdiff(view, avail)
    if (length(invalid)) {
      cli::cli_abort(
        "Invalid view(s): {.val {invalid}}. Available: {.val {avail}}"
      )
    }
    flat <- flat[flat$view %in% view, , drop = FALSE]
  }

  if (!is.null(hemi)) {
    avail <- unique(flat$hemi)
    invalid <- setdiff(hemi, avail)
    if (length(invalid)) {
      cli::cli_abort(
        "Invalid hemisphere(s): {.val {invalid}}. Available: {.val {avail}}"
      )
    }
    flat <- flat[flat$hemi %in% hemi, , drop = FALSE]
  }

  flat$atlas <- atlas$atlas
  flat$type <- atlas$type

  if (atlas$type == "cortical") {
    if (!"hemi" %in% names(flat)) {
      flat$hemi <- NA_character_
    }
    missing_hemi <- is.na(flat$hemi)
    if (any(missing_hemi)) {
      flat$hemi[missing_hemi] <- ifelse(
        grepl("^lh[_.]", flat$label[missing_hemi]),
        "left",
        ifelse(
          grepl("^rh[_.]", flat$label[missing_hemi]),
          "right",
          NA_character_
        )
      )
    }
  }

  flat$.feature_id <- as.integer(factor(
    paste(flat$label, flat$view, flat$group, sep = "@@")
  ))

  if (is_polygon_position(position)) {
    flat <- frame_2_position_flat(
      flat,
      position$position,
      nrow = position$nrow,
      ncol = position$ncol,
      views = position$views
    )
  }

  flat
}


#' Polygon-path version of `brain_join()` — joins user data onto flat rows
#'
#' Matches on `region` (and `hemi` if both data and atlas carry it). Polygon
#' rows without a matching data row keep `NA` for the joined columns; the
#' renderer paints them grey via `na.value` on the fill scale.
#'
#' @keywords internal
#' @noRd
brain_join_polygon <- function(data, flat) {
  by <- intersect(c("region", "hemi"), intersect(names(data), names(flat)))
  if (!length(by)) {
    cli::cli_abort(c(
      "{.arg data} has no columns in common with the atlas.",
      "i" = "Need {.field region} (and optionally {.field hemi})."
    ))
  }
  dplyr::left_join(flat, data, by = by, suffix = c("", ".user"))
}
