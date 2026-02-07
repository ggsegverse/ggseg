#' Brain geom
#'
#' call to \code{\link[ggplot2]{geom_sf}}
#'
#' @param mapping argument to pass to \code{\link[ggplot2]{aes}} to map
#'        variables from the supplied data to the plot
#' @param data data.frame with data to plot
#' @param atlas object of type brain_atlas to plot
#' @param hemi hemisphere to plot. Defaults to everything in the atlas.
#' @param view view to plot, as recorded in the "view" column in the atlas data.
#'        For cortical atlases: "lateral", "medial", "superior", "inferior".
#'        For subcortical atlases: slice identifiers like "axial_130_130_130".
#'        Defaults to all views.
#' @param position position of the data. Default is "identity" but can be
#'        changed by \code{\link{position_brain}}.
#' @param show.legend logical. Should legend be added or not.
#' @param inherit.aes logical. if aes should be inherited from the
#'        main ggplot call or not
#' @param ... arguments to \code{\link[ggplot2]{geom_sf}}
#'
#' @return ggplot object
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


# geom ----
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

# quiets concerns of R CMD check
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(
    "GeomPolygon",
    ".stroke",
    ".pt",
    "coord_sf",
    "GeomBrain"
  ))
}
