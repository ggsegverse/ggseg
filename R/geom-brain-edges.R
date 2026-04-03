#' Plot dissolved group edges on a brain atlas
#'
#' A ggplot2 geom that dissolves atlas parcels into group-level
#' boundaries and renders their outlines. Useful for overlaying
#' network or lobe edges on top of a parcellated brain plot.
#'
#' The `edge_group` column must exist in the atlas (either in the
#' atlas `core` or derivable from `as.data.frame(atlas)`). Regions
#' sharing the same `edge_group` value are dissolved into a single
#' polygon per hemisphere and view using [sf::st_union()]. A small
#' buffer is applied before dissolving to close micro-gaps between
#' adjacent parcels.
#'
#' @param mapping Set of aesthetic mappings created by [ggplot2::aes()].
#' @param data Ignored. Edge geometry is derived from the atlas.
#' @param atlas A `brain_atlas` object (e.g. `dk()`, `aseg()`).
#' @param edge_group Column name (string) in the atlas to dissolve
#'   parcels by. All regions sharing the same value are merged.
#' @param hemi Character vector of hemispheres to include.
#' @param view Character vector of views to include.
#' @param position Position adjustment, typically [position_brain()].
#' @param buffer Numeric buffer distance for closing gaps between
#'   adjacent parcels before dissolving. If `NULL` (default),
#'   auto-computed as 0.5\% of the atlas extent.
#' @param show.legend Logical. Should this layer be included in legends?
#' @param inherit.aes Logical. Defaults to `FALSE` since this is
#'   typically used as an overlay.
#' @param ... Additional arguments passed to the geom (e.g. `colour`,
#'   `size`, `linetype`).
#'
#' @return A list of ggplot2 layer and coord objects.
#' @include geom-brain.R
#' @export
#'
#' @examples
#' library(ggplot2)
#'
#' # Overlay lobe boundaries on a region plot
#' ggplot() +
#'   geom_brain(atlas = dk(), aes(fill = region), show.legend = FALSE) +
#'   geom_brain_edges(atlas = dk(), edge_group = "lobe")
#'
#' # Use fixed colour instead of auto-colouring by group
#' ggplot() +
#'   geom_brain(atlas = dk(), aes(fill = region), show.legend = FALSE) +
#'   geom_brain_edges(atlas = dk(), edge_group = "lobe", colour = "black")
geom_brain_edges <- function(
  mapping = aes(),
  data = NULL,
  atlas,
  edge_group,
  hemi = NULL,
  view = NULL,
  position = position_brain(),
  buffer = NULL,
  show.legend = NA,
  inherit.aes = FALSE,
  ...
) {
  list(
    layer_brain_edges(
      geom = GeomBrainEdges,
      data = data,
      mapping = mapping,
      stat = "sf",
      position = position,
      show.legend = show.legend,
      inherit.aes = inherit.aes,
      params = c(
        list(
          na.rm = FALSE,
          atlas = atlas,
          edge_group = edge_group,
          hemi = hemi,
          view = view,
          buffer = buffer
        ),
        list(...)
      )
    ),
    coord_sf(default = TRUE, clip = "off")
  )
}


#' @section GeomBrainEdges ggproto:
#' `GeomBrainEdges` is a [ggplot2::Geom] ggproto object that renders
#' dissolved brain atlas group boundaries as outlines. It inherits
#' rendering logic from [GeomBrain] with default aesthetics suited
#' for edge overlays (transparent fill, black outlines).
#'
#' @export
#' @rdname geom_brain_edges
#' @usage NULL
#' @format NULL
#' @importFrom sf st_union st_buffer
GeomBrainEdges <- ggproto(
  "GeomBrainEdges",
  GeomBrain,
  default_aes = aes(
    colour = "black",
    fill = NA,
    size = 0.5,
    linetype = 1,
    alpha = NA,
    stroke = 0.5
  ),
  draw_panel = function(
    data,
    atlas,
    hemi,
    view,
    edge_group,
    buffer,
    panel_params,
    coord,
    legend = NULL,
    lineend = "butt",
    linejoin = "round",
    linemitre = 10,
    na.rm = TRUE
  ) {
    GeomBrain$draw_panel(
      data = data,
      atlas = atlas,
      hemi = hemi,
      view = view,
      panel_params = panel_params,
      coord = coord,
      legend = legend,
      lineend = lineend,
      linejoin = linejoin,
      linemitre = linemitre,
      na.rm = na.rm
    )
  }
)


#' @keywords internal
#' @noRd
layer_brain_edges <- function(
  geom = NULL,
  stat = NULL,
  data = NULL,
  mapping = NULL,
  position = NULL,
  params = list(),
  inherit.aes = FALSE,
  check.aes = TRUE,
  check.param = TRUE,
  show.legend = NA
) {
  ggplot2::layer(
    geom = geom,
    stat = stat,
    data = data,
    mapping = mapping,
    position = position,
    params = params,
    inherit.aes = inherit.aes,
    check.aes = check.aes,
    check.param = check.param,
    show.legend = show.legend,
    layer_class = LayerBrainEdges
  )
}


#' @importFrom sf st_as_sf st_bbox st_buffer st_union
#' @keywords internal
#' @noRd
LayerBrainEdges <- ggproto(
  "LayerBrainEdges",
  ggplot2:::Layer,
  setup_layer = function(self, data, plot) {
    ggproto_parent(ggplot2:::Layer, self)$setup_layer(data, plot)

    atlas_obj <- self$geom_params$atlas
    edge_group <- self$geom_params$edge_group
    buffer <- self$geom_params$buffer

    if (is.null(atlas_obj)) {
      cli::cli_abort(
        "No atlas supplied, please provide a brain atlas to the geom."
      )
    }

    if (is.null(edge_group) || !is.character(edge_group) || length(edge_group) != 1) {
      cli::cli_abort(
        "{.arg edge_group} must be a single column name (string)."
      )
    }

    atlas <- as.data.frame(atlas_obj)

    if (nrow(atlas) == 0) {
      cli::cli_abort("Atlas has no data to plot.")
    }

    if (!edge_group %in% names(atlas)) {
      cli::cli_abort(c(
        "Column {.val {edge_group}} not found in atlas.",
        "i" = "Available columns: {.val {names(atlas)}}"
      ))
    }

    if (!is.null(self$geom_params$hemi)) {
      hemi <- self$geom_params$hemi
      invalid <- setdiff(hemi, unique(atlas$hemi))
      if (length(invalid) > 0) {
        avail <- unique(atlas$hemi)
        cli::cli_abort(
          "Invalid hemisphere(s): {.val {invalid}}. Available: {.val {avail}}"
        )
      }
      atlas <- atlas[atlas$hemi %in% hemi, ]
    }

    if (!is.null(self$geom_params$view)) {
      view <- self$geom_params$view
      invalid <- setdiff(view, unique(atlas$view))
      if (length(invalid) > 0) {
        avail <- unique(atlas$view)
        cli::cli_abort(
          "Invalid view(s): {.val {invalid}}. Available: {.val {avail}}"
        )
      }
      atlas <- atlas[atlas$view %in% view, ]
    }

    atlas <- atlas[!is.na(atlas$region), ]

    atlas_type <- unique(atlas$type)[1]
    dissolved <- dissolve_edges(atlas, edge_group, buffer)
    dissolved$type <- atlas_type

    data <- sf::st_as_sf(dissolved)

    needs_mapping <- function(aes_name) {
      self_map <- self$computed_mapping[[aes_name]]
      plot_map <- plot$computed_mapping[[aes_name]]
      if (isTRUE(self$inherit.aes)) {
        is.null(self_map) && is.null(plot_map)
      } else {
        is.null(self_map)
      }
    }

    if (needs_mapping("geometry") && ggplot2:::is_sf(data)) {
      geometry_col <- attr(data, "sf_column")
      self$computed_mapping$geometry <- as.name(geometry_col)
    }

    if (needs_mapping("hemi")) {
      self$computed_mapping$hemi <- as.name("hemi")
    }

    if (needs_mapping("view")) {
      self$computed_mapping$view <- as.name("view")
    }

    if (needs_mapping("type")) {
      self$computed_mapping$type <- as.name("type")
    }

    if (needs_mapping("colour")) {
      self$computed_mapping$colour <- as.name(edge_group)
    }

    self$geom_params$legend <- "polygon"

    data
  }
)


#' Dissolve atlas regions into group-level boundaries
#'
#' Buffers geometries to close micro-gaps, unions them by group,
#' then removes the buffer. This produces clean group-level
#' outlines from parcellated atlas data.
#'
#' @param atlas_sf Data.frame with sf geometry and grouping columns.
#' @param edge_group Column name to group by.
#' @param buffer Buffer distance. If `NULL`, auto-computed from extent.
#'
#' @return An sf data.frame with dissolved geometries.
#' @keywords internal
#' @noRd
dissolve_edges <- function(atlas_sf, edge_group, buffer = NULL) {
  if (is.null(buffer)) {
    bbx <- sf::st_bbox(atlas_sf)
    extent <- max(
      bbx[["xmax"]] - bbx[["xmin"]],
      bbx[["ymax"]] - bbx[["ymin"]]
    )
    buffer <- extent * 0.005
  }

  atlas_sf <- sf::st_buffer(atlas_sf, buffer)

  dissolved <- dplyr::group_by(
    atlas_sf,
    dplyr::across(dplyr::all_of(c(edge_group, "hemi", "view")))
  )
  dissolved <- dplyr::summarise(
    dissolved,
    geometry = sf::st_union(.data$geometry),
    .groups = "drop"
  )

  sf::st_buffer(dissolved, -buffer)
}
