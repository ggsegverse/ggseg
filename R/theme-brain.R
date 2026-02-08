#' Themes for brain atlas plots
#'
#' @description
#' A set of ggplot2 themes designed for brain atlas visualisations. All themes
#' remove axis ticks and grid lines for a clean presentation.
#'
#' @param text.size Text size in points (default: `12`).
#' @param text.colour Text colour (`theme_custombrain` and `theme_brain2` only).
#' @param text.family Font family (default: `"mono"`).
#' @param plot.background Background fill colour (`theme_custombrain` and
#'   `theme_brain2` only).
#'
#' @details
#' \describe{
#'
#' \item{`theme_brain`}{
#' Default theme. Transparent background, no axes, no grid.}
#'
#' \item{`theme_darkbrain`}{
#' Dark theme with black background and light text.}
#'
#' \item{`theme_custombrain`}{
#' Fully customisable background, text colour, size, and font.}
#'
#' \item{`theme_brain2`}{
#' Like `theme_custombrain` but with axis text removed entirely.}
#'
#' }
#'
#' @return A [ggplot2::theme] object.
#' @seealso [geom_brain()], [ggplot2::theme()]
#' @export
#' @importFrom ggplot2 theme element_blank element_rect element_text
#' @examples
#' library(ggplot2)
#'
#' p <- ggplot() +
#'   geom_brain(atlas = dk)
#'
#' p +
#'   theme_brain()
#'
#' p +
#'   theme_darkbrain()
#'
theme_brain <- function(text.size = 12, text.family = "mono") {
  theme(
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    panel.background = element_blank(),
    plot.background = element_blank(),
    legend.background = element_blank(),
    text = element_text(family = text.family, size = text.size),
    axis.text = element_text(family = text.family, size = text.size)
  )
}

#' @export
#' @rdname theme_brain
#' @importFrom ggplot2 theme element_blank element_rect element_text
theme_darkbrain <- function(text.size = 12, text.family = "mono") {
  theme(
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    panel.background = element_blank(),
    legend.background = element_rect(fill = "black"),
    plot.background = element_rect(fill = "black"),
    text = element_text(
      colour = "lightgrey",
      family = text.family,
      size = text.size
    ),
    axis.text = element_text(
      colour = "lightgrey",
      family = text.family,
      size = text.size
    )
  )
}

#' @export
#' @rdname theme_brain
#' @importFrom ggplot2 theme element_blank element_rect element_text
theme_custombrain <- function(
  plot.background = "white",
  text.colour = "darkgrey",
  text.size = 12,
  text.family = "mono"
) {
  theme(
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    panel.background = element_blank(),
    legend.background = element_rect(fill = plot.background),
    plot.background = element_rect(fill = plot.background),
    text = element_text(
      colour = text.colour,
      family = text.family,
      size = text.size
    ),
    axis.text = element_text(
      colour = text.colour,
      family = text.family,
      size = text.size
    )
  )
}

#' @export
#' @rdname theme_brain
#' @importFrom ggplot2 theme element_blank element_rect element_text
theme_brain2 <- function(
  plot.background = "white",
  text.colour = "darkgrey",
  text.size = 12,
  text.family = "mono"
) {
  theme(
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    panel.background = element_blank(),
    legend.background = element_rect(fill = plot.background),
    plot.background = element_rect(fill = plot.background),
    text = element_text(
      colour = text.colour,
      family = text.family,
      size = text.size
    ),
    axis.text = element_blank()
  )
}
