#' Ensure the sf package is installed
#'
#' Internal guard used by the deprecated sf code path. Since the
#' sf-optional milestone moved sf to Suggests, callers without sf
#' installed should get a clear error pointing to the polygon default
#' (`geom_brain()`, `position_brain()`, `annotate_brain()`).
#'
#' @param what Character describing the calling function or operation,
#'   used in the error message.
#' @return Invisible `TRUE` if sf is installed; aborts otherwise.
#' @keywords internal
#' @noRd
require_sf <- function(what) {
  if (!has_sf()) {
    cli::cli_abort(c(
      "{what} requires the {.pkg sf} package, which is not installed.",
      "i" = paste0(
        "Install with {.run install.packages(\"sf\")}, or use the ",
        "polygon default ({.fn geom_brain}, {.fn position_brain}, ",
        "{.fn annotate_brain})."
      )
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
