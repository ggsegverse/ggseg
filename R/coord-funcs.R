#' Midpoint of a numeric range
#'
#' @param x Numeric vector.
#'
#' @return Single numeric value, the mean of `min(x)` and `max(x)`.
#' @keywords internal
#' @noRd
gap <- function(x) {
  (min(x) + max(x)) / 2
}
