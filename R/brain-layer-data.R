#' The drawn data for a brain plot's regions
#'
#' [ggplot2::layer_data()] takes a layer by position, and [geom_brain()] adds
#' two: the context backdrop first, so it draws underneath, then the regions.
#' `layer_data(p)` therefore returns the backdrop. This returns the regions
#' whatever the layer order, so inspecting a brain plot does not depend on how
#' many layers it happens to have.
#'
#' @param plot A ggplot built with [geom_brain()] or [stat_brain()].
#' @param context When `TRUE`, return the context backdrop's data instead of
#'   the regions'.
#' @return A data.frame of the drawn data, as [ggplot2::layer_data()] returns.
#' @seealso [geom_brain()]
#' @export
#' @examples
#' library(ggplot2)
#'
#' p <- ggplot() + geom_brain(atlas = dk())
#'
#' # the regions, whichever layer they are
#' head(brain_layer_data(p))
#'
#' # and the backdrop behind them
#' head(brain_layer_data(p, context = TRUE))
brain_layer_data <- function(plot, context = FALSE) {
  if (!inherits(plot, "ggplot")) {
    cli::cli_abort("{.arg plot} must be a {.cls ggplot}.")
  }
  wanted <- if (context) "context" else c("regions", "all")
  idx <- which(vapply(
    plot$layers,
    function(l) isTRUE(l$brain_rows %in% wanted),
    logical(1)
  ))
  if (length(idx) == 0 && !context && length(plot$layers) > 0) {
    # The deprecated sf path tags no layer, and adds only one.
    return(ggplot2::layer_data(plot, 1L))
  }
  if (length(idx) == 0) {
    cli::cli_abort(c(
      "{.arg plot} has no {if (context) 'context' else 'region'} brain layer.",
      "i" = "Build it with {.fn geom_brain} or {.fn stat_brain}."
    ))
  }
  ggplot2::layer_data(plot, idx[[1]])
}
