#' Plot brain atlas regions
#'
#' Colour brain regions by your own values. Give `geom_brain()` an atlas like
#' `dk()` and a data frame, and it matches your values to the right regions and
#' lays out the brain views for you. No data? It just draws the atlas.
#'
#' @param mapping Set of aesthetic mappings created by [ggplot2::aes()].
#' @param data A data.frame containing variables to map. If `NULL`, the atlas
#'   is plotted without user data. Group it with [dplyr::group_by()] to facet.
#' @param atlas A `ggseg_atlas` object (e.g. `dk()`, `aseg()`, `tracula()`).
#' @param hemi Character vector of hemispheres to include (e.g. `"left"`,
#'   `"right"`). Defaults to all hemispheres in the atlas.
#' @param view Character vector of views to include, as recorded in the atlas
#'   data. For cortical atlases: `"lateral"`, `"medial"`. For subcortical/tract
#'   atlases: slice identifiers like `"axial_3"`. Defaults to all views.
#' @param position Position adjustment, either as a string or the result of
#'   a call to [position_brain()].
#' @param context Keep the rest of the brain as a soft grey backdrop (`TRUE`,
#'   the default), or show only the regions you're plotting (`FALSE`).
#' @param show.legend Logical. Should this layer be included in the legends?
#' @param inherit.aes Logical. If `FALSE`, overrides the default aesthetics
#'   rather than combining with them.
#' @param ... Additional arguments passed to [ggplot2::geom_polygon()].
#'
#' @return A list of ggplot2 layer and coord objects.
#' @rdname ggbrain
#' @export
#'
#' @examples
#' library(ggplot2)
#'
#' ggplot() +
#'   geom_brain(atlas = dk())
geom_brain <- function(
  mapping = aes(),
  data = NULL,
  atlas,
  hemi = NULL,
  view = NULL,
  position = position_brain(),
  context = TRUE,
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

  do.call(
    geom_brain_polygon,
    c(
      list(
        mapping = mapping,
        data = data,
        atlas = atlas,
        hemi = hemi,
        view = view,
        position = position,
        context = context,
        show.legend = show.legend,
        inherit.aes = inherit.aes
      ),
      dots
    )
  )
}

#' Deprecated sf brain geom
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' The sf rendering path is deprecated. `geom_brain_sf()` renders an atlas via
#' [ggplot2::geom_sf()] and [coord_sf()][ggplot2::coord_sf]. For new code, use
#' [geom_brain()] (the polygon default), or convert the atlas with
#' `as_sf_atlas()` and use [ggplot2::geom_sf()] directly for the full sf
#' toolkit (labels, other sf layers).
#'
#' @inheritParams geom_brain
#' @return A list of ggplot2 layer and coord objects.
#' @export
#' @keywords internal
#' @importFrom ggplot2 aes coord_sf scale_fill_manual
geom_brain_sf <- function(
  mapping = aes(),
  data = NULL,
  atlas,
  hemi = NULL,
  view = NULL,
  position = NULL,
  show.legend = NA,
  inherit.aes = TRUE,
  ...
) {
  lifecycle::deprecate_warn(
    "2.2.0",
    "geom_brain_sf()",
    details = paste(
      "Use `geom_brain()` for the polygon default, or `as_sf_atlas()` with",
      "`ggplot2::geom_sf()` for an sf workflow."
    )
  )
  require_sf("geom_brain_sf()")
  if (is.null(position)) {
    position <- make_position_brain_sf()
  }
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

  result <- list(
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

  has_fill_aes <- "fill" %in% names(mapping)
  if (!is.null(atlas$palette) && !has_fill_aes) {
    result <- c(
      result,
      list(
        scale_fill_manual(values = atlas$palette, na.value = "grey")
      )
    )
  }

  result
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
#' @importFrom ggplot2 Geom aes ggproto draw_key_polygon
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
      cli::cli_abort("{.fn geom_brain} must be used with {.fn coord_sf}.")
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


#' Build a grid grob from transformed brain coordinates
#'
#' Adapted from `ggplot2::sf_grob`. Converts transformed coordinate
#' data into a grid graphical object with polygon fill and stroke.
#'
#' @param x Data.frame of transformed coordinates with columns
#'   `geometry`, `alpha`, `colour`, `fill`, `size`, and `linetype`.
#' @param lineend Line end style passed to [grid::gpar()].
#' @param linejoin Line join style passed to [grid::gpar()].
#' @param linemitre Line mitre limit passed to [grid::gpar()].
#' @param na.rm If `TRUE`, silently remove missing values.
#'
#' @return A grid [grob][grid::grid.grob] object.
#' @keywords internal
#' @importFrom ggplot2 GeomPolygon alpha .pt
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

#' Merge values from one list into another
#'
#' @param old List to update.
#' @param new List whose elements overwrite matching names in `old`.
#'
#' @return Updated list.
#' @keywords internal
#' @noRd
modify_list <- function(old, new) {
  for (i in names(new)) {
    old[[i]] <- new[[i]]
  }
  old
}
