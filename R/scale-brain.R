# Colour and fill ----
#' Colour and fill scales from the ggseg atlases
#'
#' @description
#' The `brain` palette scales provides scales for the different atlases in the
#' package. Colours are according to the colours used in the papers where the
#' atlases where first introduced.
#'
#' @section Palettes:
#' The following palettes are available for use with these scales:
#' \describe{
#'   \item{ggseg - }{dk, aseg}
#'   \item{ggsegExtra - }{tracula, jhu, yeo7, yeo17, glasser, chenAr, chenTh,}
#' }
#'
#' @param name String name of atlas
#' @param na.value String name or hex for the colour of NA entries
#' @param aesthetics String vector of which aesthetics to scale c("colour", "color", "fill").
#' @param ... additional arguments to pass to \code{\link{brain_pal}}
#'
#' @return scaling function for altering colour of ggplot aesthetics
#' @rdname scale_brain
#' @export
#' @examples
#' scale_brain()
#' scale_colour_brain()
#' scale_fill_brain()
#'

#' @importFrom ggplot2 scale_color_manual scale_colour_manual scale_fill_manual
scale_brain = function(
  name = "dk",
  na.value = "grey",
  ...,
  aesthetics = c("fill", "colour", "color")
) {
  pal = brain_pal(name = name, ...)
  aesthetics = match.arg(aesthetics)
  func = switch(
    aesthetics,
    color = scale_color_manual,
    colour = scale_colour_manual,
    fill = scale_fill_manual
  )
  func(values = pal, na.value = na.value)
}

#' @rdname scale_brain
#' @export
scale_colour_brain <- function(...) {
  scale_brain(..., aesthetics = "colour")
}

#' @rdname scale_brain
#' @export
scale_color_brain <- function(...) {
  scale_brain(..., aesthetics = "color")
}

#' @export
#' @rdname scale_brain
scale_fill_brain <- function(...) {
  scale_brain(..., aesthetics = "fill")
}

#' Colour and fill scales from the ggseg atlases
#'
#' @description
#' The `brain` palette scales provides scales for the different atlases in the
#' package. Colours are according to the colours used in the papers where the
#' atlases where first introduced.
#'
#' @section Palettes:
#' The following palettes are available for use with these scales:
#' \describe{
#'   \item{ggseg - }{dk, aseg}
#'   \item{ggsegExtra - }{tracula, jhu, yeo7, yeo17, glasser, chenAr, chenTh,}
#' }
#'
#' @param palette named character vector of regions and colours
#' @param na.value String name or hex for the colour of NA entries
#' @param aesthetics String vector of which aesthetics to scale c("colour", "color", "fill").
#' @param ... additional arguments to pass to \code{\link{brain_pal}}
#' @return scaling function for altering colour of ggplot aesthetics
#'
#' @rdname scale_brain2
#' @export
#' @examples
#' scale_brain()
#' scale_colour_brain()
#' scale_fill_brain()
#'
scale_brain2 = function(
  palette,
  na.value = "grey",
  ...,
  aesthetics = c("fill", "colour", "color")
) {
  aesthetics = match.arg(aesthetics)
  func = switch(
    aesthetics,
    color = ggplot2::scale_color_manual,
    colour = ggplot2::scale_colour_manual,
    fill = ggplot2::scale_fill_manual
  )
  func(values = palette, na.value = na.value)
}

#' @rdname scale_brain2
#' @export
scale_colour_brain2 <- function(...) {
  scale_brain2(..., aesthetics = "colour")
}

#' @rdname scale_brain2
#' @export
scale_color_brain2 <- function(...) {
  scale_brain2(..., aesthetics = "color")
}

#' @export
#' @rdname scale_brain2
scale_fill_brain2 <- function(...) {
  scale_brain2(..., aesthetics = "fill")
}


# Axis scales ----
#' Axis and label scales from the ggseg atlases
#'
#' @description
#' The `brain` axis and label scales provides scales for the different atlases in the
#' package. These add axis labels and tick labels corresponding to the different atlases.
#'
#' @param atlas data.frame containing the atlas
#' @param position Character of either "dispersed" or "stacked".
#' @param aesthetics String vector of which aesthetics to scale "x", "y", or "labs".
#' @param ... additional arguments to pass to \code{\link{adapt_scales}}
#' @return a scaling function to alter continuous axes labels in ggplot2
#' @rdname scale_continous_brain
#' @export
#' @examples
#' \dontrun{
#' scale_x_brain()
#' scale_y_brain()
#' scale_labs_brain()
#' }
#'
scale_continous_brain = function(
  atlas = dk,
  position = "dispersed",
  aesthetics = c("y", "x")
) {
  positions = adapt_scales(atlas, position, aesthetics)
  aesthetics = match.arg(aesthetics)
  func = switch(
    aesthetics,
    y = ggplot2::scale_y_continuous,
    x = ggplot2::scale_x_continuous
  )
  func(breaks = positions$breaks, labels = positions$labels)
}

#' @export
#' @rdname scale_continous_brain
scale_x_brain <- function(...) {
  scale_continous_brain(..., aesthetics = "x")
}

#' @export
#' @rdname scale_continous_brain
scale_y_brain <- function(...) {
  scale_continous_brain(..., aesthetics = "y")
}

#' @export
#' @rdname scale_continous_brain
#' @importFrom ggplot2 labs
scale_labs_brain <- function(
  atlas = dk,
  position = "dispersed",
  aesthetics = "labs"
) {
  positions = adapt_scales(atlas, position, aesthetics)

  aesthetics = match.arg(aesthetics)
  func = switch(aesthetics, labs = labs)
  func(x = positions$x, y = positions$y)
}
