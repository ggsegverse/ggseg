#' Ensure the sf package is installed
#'
#' Internal guard used at every ggseg entry point that takes the sf
#' code path. Since the sf-optional milestone moved sf to Suggests,
#' callers without sf installed should get a clear error pointing to
#' the polygon alternative (`geom_brain_polygon`, `position_brain_polygon`,
#' `annotate_brain_polygon`).
#'
#' @param what Character describing the calling function or operation,
#'   used in the error message.
#' @return Invisible `TRUE` if sf is installed; aborts otherwise.
#' @keywords internal
#' @noRd
require_sf <- function(what) {
  if (!requireNamespace("sf", quietly = TRUE)) {
    cli::cli_abort(c(
      "{what} requires the {.pkg sf} package, which is not installed.",
      "i" = "Install with {.run install.packages(\"sf\")}, or use the polygon-path equivalent ({.fn geom_brain_polygon}, {.fn position_brain_polygon}, {.fn annotate_brain_polygon})."
    ))
  }
  invisible(TRUE)
}


#' Test whether sf is available without raising
#'
#' @return Logical.
#' @keywords internal
#' @noRd
has_sf <- function() {
  requireNamespace("sf", quietly = TRUE)
}
