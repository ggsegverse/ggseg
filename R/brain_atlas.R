#' Plot a brain atlas
#'
#' Plots a brain atlas using [geom_brain()], coloured by region label. If the
#' atlas contains a palette, it is applied via [ggplot2::scale_fill_manual()].
#'
#' @param x A `brain_atlas` object.
#' @param ... Additional arguments passed to [geom_brain()].
#'
#' @return A [ggplot2::ggplot] object.
#' @importFrom ggplot2 aes ggplot labs scale_fill_manual
#' @importFrom stats setNames
#' @export
#' @examples
#' plot(dk)
#' plot(aseg)
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
      aes(fill = label), # nolint [object_usage_linter]
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

