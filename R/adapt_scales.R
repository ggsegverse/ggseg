#' Compute axis scale positions for brain atlas plots
#'
#' Returns axis breaks, labels, and lab strings based on atlas layout.
#' Used internally by [scale_continous_brain()] and related functions.
#'
#' @param geobrain A data.frame containing atlas information with columns
#'   `hemi`, `view`, `type`, `.lat`, and `.long`.
#' @param position Layout style: `"dispersed"` (default) or `"stacked"`.
#' @param aesthetics Which scale to compute: `"x"`, `"y"`, or `"labs"`.
#'
#' @return A list with scale components (breaks, labels, or axis titles).
#' @keywords internal
#' @noRd
#' @importFrom dplyr group_by summarise
adapt_scales <- function(
  geobrain,
  position = "dispersed",
  aesthetics = "labs"
) {
  if (!is.data.frame(geobrain)) {
    geobrain <- sf2coords(as.data.frame(geobrain))
    geobrain <- tidyr::unnest(geobrain, ggseg)
  }

  if (unique(geobrain$type) == "cortical") {
    y <- dplyr::group_by(geobrain, hemi)
    y <- dplyr::summarise(y, val = gap(.lat))

    x <- dplyr::group_by(geobrain, view)
    x <- dplyr::summarise(x, val = gap(.long))

    stk <- list(
      y = y,
      x = x
    )

    disp <- dplyr::group_by(geobrain, hemi)
    disp <- dplyr::summarise_at(disp, dplyr::vars(.long, .lat), list(gap))

    ad_scale <- list(
      stacked = list(
        x = list(breaks = stk$x$val, labels = stk$x$view),
        y = list(breaks = stk$y$val, labels = stk$y$hemi),
        labs = list(y = "hemisphere", x = "view")
      ),
      dispersed = list(
        x = list(breaks = disp$.long, labels = disp$hemi),
        y = list(breaks = NULL, labels = NULL),
        labs = list(y = NULL, x = "hemisphere")
      )
    )
  } else if (unique(geobrain$type) %in% c("subcortical", "tract")) {
    y <- group_by(geobrain, view)
    y <- dplyr::summarise(y, val = gap(.lat))

    x <- dplyr::group_by(geobrain, view)
    x <- dplyr::summarise(x, val = gap(.long))

    stk <- list(
      y = y,
      x = x
    )

    disp <- dplyr::group_by(geobrain, view)
    disp <- dplyr::summarise_at(disp, dplyr::vars(.long, .lat), list(gap))

    ad_scale <- list(
      stacked = list(
        x = list(breaks = NULL, labels = NULL),
        y = list(breaks = stk$y$val, labels = stk$y$view),
        labs = list(y = "view", x = NULL)
      ),
      dispersed = list(
        x = list(breaks = disp$.long, labels = disp$view),
        y = list(breaks = NULL, labels = NULL),
        labs = list(y = NULL, x = "view")
      )
    )
  }

  ad_scale[[position]][[aesthetics]]
}
