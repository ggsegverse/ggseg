# Colour and fill ----
#' Colour and fill scales from brain atlas palettes
#'
#' @description
#' Apply atlas-specific colour palettes to brain plots. Colours correspond to
#' the region colours used in the original atlas publications. Palettes are
#' looked up by atlas name via [ggseg.formats::atlas_palette()].
#'
#' @param name String name of the atlas palette (e.g. `"dk"`, `"aseg"`).
#' @param na.value Colour for `NA` entries (default: `"grey"`).
#' @param aesthetics Which aesthetic to scale: `"fill"`, `"colour"`, or
#'   `"color"`.
#' @param ... Additional arguments passed to [ggseg.formats::atlas_palette()].
#'
#' @return A ggplot2 scale object.
#' @rdname scale_brain
#' @export
#' @examples
#' scale_brain()
#' scale_colour_brain()
#' scale_fill_brain()
#'

#' @importFrom ggplot2 scale_color_manual scale_colour_manual scale_fill_manual
#' @importFrom ggseg.formats atlas_palette
scale_brain <- function(
  name = "dk",
  na.value = "grey",
  ...,
  aesthetics = c("fill", "colour", "color")
) {
  pal <- atlas_palette(name = name, ...)
  aesthetics <- match.arg(aesthetics)
  func <- switch(
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

#' Manual colour and fill scales for brain plots
#'
#' @description
#' Apply a custom named colour palette to brain atlas plots. Unlike
#' [scale_brain()] which looks up palettes by atlas name,
#' `scale_brain_manual()` accepts a pre-built named character vector mapping
#' region names to colours.
#'
#' @param palette Named character vector mapping region names to colours.
#' @param na.value Colour for `NA` entries (default: `"grey"`).
#' @param aesthetics Which aesthetic to scale: `"fill"`, `"colour"`, or
#'   `"color"`.
#' @param ... Additional arguments (unused).
#'
#' @return A ggplot2 scale object.
#' @rdname scale_brain_manual
#' @export
#' @examples
#' library(ggplot2)
#'
#' pal <- c("insula" = "red", "precentral" = "blue")
#' ggplot() +
#'   geom_brain(atlas = dk, aes(fill = region), show.legend = FALSE) +
#'   scale_fill_brain_manual(palette = pal)
#'
scale_brain_manual <- function(
  palette,
  na.value = "grey",
  ...,
  aesthetics = c("fill", "colour", "color")
) {
  aesthetics <- match.arg(aesthetics)
  func <- switch(
    aesthetics,
    color = ggplot2::scale_color_manual,
    colour = ggplot2::scale_colour_manual,
    fill = ggplot2::scale_fill_manual
  )
  func(values = palette, na.value = na.value)
}

#' @rdname scale_brain_manual
#' @export
scale_colour_brain_manual <- function(...) {
  scale_brain_manual(..., aesthetics = "colour")
}

#' @rdname scale_brain_manual
#' @export
scale_color_brain_manual <- function(...) {
  scale_brain_manual(..., aesthetics = "color")
}

#' @export
#' @rdname scale_brain_manual
scale_fill_brain_manual <- function(...) {
  scale_brain_manual(..., aesthetics = "fill")
}

# Deprecated scale_brain2 variants ----
#' @rdname scale_brain2-deprecated
#' @export
#' @keywords internal
scale_brain2 <- function(...) {
  lifecycle::deprecate_warn("1.7.0", "scale_brain2()", "scale_brain_manual()")
  scale_brain_manual(...)
}

#' @rdname scale_brain2-deprecated
#' @export
#' @keywords internal
scale_colour_brain2 <- function(...) {
  lifecycle::deprecate_warn(
    "1.7.0", "scale_colour_brain2()", "scale_colour_brain_manual()"
  )
  scale_colour_brain_manual(...)
}

#' @rdname scale_brain2-deprecated
#' @export
#' @keywords internal
scale_color_brain2 <- function(...) {
  lifecycle::deprecate_warn(
    "1.7.0", "scale_color_brain2()", "scale_color_brain_manual()"
  )
  scale_color_brain_manual(...)
}

#' @rdname scale_brain2-deprecated
#' @export
#' @keywords internal
scale_fill_brain2 <- function(...) {
  lifecycle::deprecate_warn(
    "1.7.0", "scale_fill_brain2()", "scale_fill_brain_manual()"
  )
  scale_fill_brain_manual(...)
}

#' Deprecated scale functions
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' These functions have been renamed for clarity:
#' - `scale_brain2()` -> [scale_brain_manual()]
#' - `scale_fill_brain2()` -> [scale_fill_brain_manual()]
#' - `scale_colour_brain2()` -> [scale_colour_brain_manual()]
#' - `scale_color_brain2()` -> [scale_color_brain_manual()]
#'
#' @param ... Arguments passed to the replacement function.
#' @name scale_brain2-deprecated
#' @keywords internal
NULL


# Axis scales ----
#' Axis and label scales for brain atlas plots
#'
#' @description
#' Add axis labels and tick labels corresponding to brain atlas regions.
#' These scales add hemisphere or view labels to the x and y axes based on
#' the atlas layout.
#'
#' @param atlas A `brain_atlas` object or data.frame containing atlas data.
#' @param position Layout style: `"dispersed"` (default) or `"stacked"`.
#' @param aesthetics Which axis to scale: `"x"`, `"y"`, or `"labs"`.
#' @param ... Additional arguments passed to [adapt_scales()].
#'
#' @return A ggplot2 scale or labs object.
#' @rdname scale_continous_brain
#' @export
#' @examples
#' \dontrun{
#' library(ggplot2)
#'
#' ggplot() +
#'   geom_brain(atlas = dk) +
#'   scale_x_brain() +
#'   scale_y_brain() +
#'   scale_labs_brain()
#' }
#'
scale_continous_brain <- function(
  atlas = dk,
  position = "dispersed",
  aesthetics = c("y", "x")
) {
  positions <- adapt_scales(atlas, position, aesthetics)
  aesthetics <- match.arg(aesthetics)
  func <- switch(
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
  positions <- adapt_scales(atlas, position, aesthetics)

  aesthetics <- match.arg(aesthetics)
  func <- switch(aesthetics, labs = labs)
  func(x = positions$x, y = positions$y)
}
