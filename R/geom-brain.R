#' Plot brain atlas regions
#'
#' A ggplot2 geom for rendering brain atlas regions as filled polygons,
#' built on top of [ggplot2::geom_sf()]. Accepts a `brain_atlas` object and
#' automatically joins user data to atlas geometry for visualisation.
#'
#' @param mapping Set of aesthetic mappings created by [ggplot2::aes()].
#' @param data A data.frame containing variables to map. If `NULL`, the atlas
#'   is plotted without user data.
#' @param atlas A `brain_atlas` object (e.g. `dk`, `aseg`, `tracula`).
#' @param hemi Character vector of hemispheres to include (e.g. `"left"`,
#'   `"right"`). Defaults to all hemispheres in the atlas.
#' @param view Character vector of views to include, as recorded in the atlas
#'   data. For cortical atlases: `"lateral"`, `"medial"`. For subcortical/tract
#'   atlases: slice identifiers like `"axial_3"`. Defaults to all views.
#' @param position Position adjustment, either as a string or the result of
#'   a call to [position_brain()].
#' @param show.legend Logical. Should this layer be included in the legends?
#' @param inherit.aes Logical. If `FALSE`, overrides the default aesthetics
#'   rather than combining with them.
#' @param ... Additional arguments passed to [ggplot2::geom_sf()].
#'
#' @return A list of ggplot2 layer and coord objects.
#' @rdname ggbrain
#' @export
#'
#' @examples
#' library(ggplot2)
#'
#' ggplot() +
#'   geom_brain(atlas = dk)
geom_brain <- function(
  mapping = aes(),
  data = NULL,
  atlas,
  hemi = NULL,
  view = NULL,
  position = position_brain(),
  show.legend = NA,
  inherit.aes = TRUE,
  ...
) {
  dots <- list(...)
  if ("side" %in% names(dots)) {
    cli::cli_warn(c(
      "The {.arg side} argument is deprecated.",
      "i" = "Use {.arg view} instead. Your value has been passed to view."
    ))
    if (is.null(view)) {
      view <- dots$side
    }
    dots$side <- NULL
  }

  c(
    layer_brain(
      geom = GeomBrain,
      data = data,
      mapping = mapping,
      stat = "sf",
      position = position,
      show.legend = show.legend,
      inherit.aes = inherit.aes,
      params = c(
        list(na.rm = FALSE, atlas = atlas, hemi = hemi, view = view),
        dots
      )
    ),
    coord_sf(default = TRUE, clip = "off")
  )
}


#' @section GeomBrain ggproto:
#' `GeomBrain` is a [ggplot2::Geom] ggproto object that handles rendering
#' of brain atlas polygons. It is used internally by [geom_brain()] and
#' should not typically be called directly.
#'
#' @export
#' @rdname ggbrain
#' @usage NULL
#' @format NULL
#' @importFrom ggplot2 Geom aes
GeomBrain <- ggproto(
  "GeomBrain",
  Geom,
  default_aes = aes(
    shape = NULL,
    colour = NULL,
    fill = NULL,
    size = NULL,
    linetype = 1,
    alpha = NA,
    stroke = 0.5
  ),
  draw_panel = function(
    data,
    atlas,
    hemi,
    view,
    panel_params,
    coord,
    legend = NULL,
    lineend = "butt",
    linejoin = "round",
    linemitre = 10,
    na.rm = TRUE
  ) {
    if (!inherits(coord, "CoordSf")) {
      stop("geom_brain() must be used with coord_sf()", call. = FALSE)
    }

    coord <- coord$transform(data, panel_params)
    brain_grob(
      coord,
      lineend = lineend,
      linejoin = linejoin,
      linemitre = linemitre,
      na.rm = na.rm
    )
  },
  draw_key = function(data, params, size) {
    draw_key_polygon(data, params, size)
  }
)


# adapted from ggplot2::sf_grob
#' @noRd
brain_grob <- function(
  x,
  lineend = "butt",
  linejoin = "round",
  linemitre = 10,
  na.rm = TRUE
) {
  # nolint: object_name_linter
  defaults <- modify_list(
    GeomPolygon$default_aes,
    list(colour = "grey35", size = 0.2)
  )

  alpha <- if (!is.null(x$alpha)) x$alpha else defaults$alpha
  col <- if (!is.null(x$colour)) x$colour else defaults$colour

  fill <- if (!is.null(x$fill)) x$fill else defaults$fill
  fill <- alpha(fill, alpha)
  size <- if (!is.null(x$size)) x$size else defaults$size

  lwd <- size * .pt
  lty <- if (!is.null(x$linetype)) x$linetype else defaults$linetype
  gp <- grid::gpar(
    col = col,
    fill = fill,
    lwd = lwd,
    lty = lty,
    lineend = lineend,
    linejoin = linejoin,
    linemitre = linemitre
  )
  sf::st_as_grob(x$geometry, gp = gp)
}

#' @noRd
modify_list <- function(old, new) {
  for (i in names(new)) {
    old[[i]] <- new[[i]]
  }
  old
}
