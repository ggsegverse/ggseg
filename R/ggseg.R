#' Plot brain parcellations (defunct)
#'
#' `ggseg()` is defunct as of version 2.0.0. Use
#' `ggplot() + geom_brain()` instead.
#'
#' @param ... Ignored.
#'
#' @return Does not return; always raises an error.
#' @seealso [geom_brain()] for the replacement API.
#' @export
ggseg <- function(
  ...
) {
  lifecycle::deprecate_stop(
    "2.0.0",
    "ggseg()",
    details = "Please use `ggplot() + geom_brain()` instead."
  )
}
