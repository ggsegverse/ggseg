#' @importFrom ggplot2 aes ggplot labs
#' @importFrom stats setNames
#' @export
plot.brain_atlas <- function(x, ...) {
  sf_data <- if (inherits(x$data, "brain_atlas_data") && !is.null(x$data$sf)) {
    x$data$sf
  } else {
    x$data
  }

  if (is.null(sf_data) || !"geometry" %in% names(sf_data)) {
    cli::cli_abort(
      "This is not a correctly formatted brain atlas.
       It is missing geometry data, and cannot be plotted."
    )
  }

  p <- ggplot() +
    geom_brain(
      atlas = x,
      ...
    ) +
    labs(title = paste(x$atlas, x$type, "atlas"))

  if ("palette" %in% names(x)) {
    p <- p +
      scale_fill_manual(
        values = x$palette
      )
  }
  p
}

## quiets concerns of R CMD checks
utils::globalVariables(c("region", "lab"))
