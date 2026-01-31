#' Scale ggseg plot axes.
#'
#' \code{adapt_scales} returns a list of coordinate breaks and labels
#' for axes or axes label manipulation of the ggseg brain atlases.
#'
#' @param geobrain a data.frame containing atlas information.
#' @param position String choosing how to view the data. Either "dispersed"[default] or "stacked".
#' @param aesthetics String of which aesthetics to adapt scale of, either "x","y", or "labs".
#'
#' @importFrom dplyr group_by summarise
#' @return nested list with coordinates for labels
adapt_scales = function(geobrain, position = "dispersed", aesthetics = "labs") {
  atlas = ifelse(
    any(names(geobrain) %in% "atlas"),
    unique(geobrain$atlas),
    "unknown"
  )

  if (unique(geobrain$type) == "cortical") {
    y <- dplyr::group_by(geobrain, hemi)
    y <- dplyr::summarise(y, val = gap(.lat))

    x <- dplyr::group_by(geobrain, side)
    x <- dplyr::summarise(x, val = gap(.long))

    stk = list(
      y = y,
      x = x
    )

    disp <- dplyr::group_by(geobrain, hemi)
    disp <- dplyr::summarise_at(disp, dplyr::vars(.long, .lat), list(gap))

    ad_scale <- list(
      stacked = list(
        x = list(breaks = stk$x$val, labels = stk$x$side),
        y = list(breaks = stk$y$val, labels = stk$y$hemi),
        labs = list(y = "hemisphere", x = "side")
      ),

      dispersed = list(
        x = list(breaks = disp$.long, labels = disp$hemi),
        y = list(breaks = NULL, labels = ""),
        labs = list(y = NULL, x = "hemisphere")
      )
    )
  } else if (unique(geobrain$type) == "subcortical") {
    y <- group_by(geobrain, side)
    y <- dplyr::summarise(y, val = gap(.lat))

    x <- dplyr::group_by(geobrain, side)
    x <- dplyr::summarise(x, val = gap(.long))

    stk = list(
      y = y,
      x = x
    )

    disp <- dplyr::group_by(geobrain, side)
    disp <- dplyr::summarise_at(disp, dplyr::vars(.long, .lat), list(gap))

    ad_scale <- list(
      stacked = list(
        x = list(breaks = NULL, labels = ""),
        y = list(breaks = stk$y$val, labels = stk$y$side),
        labs = list(y = "side", x = NULL)
      ),

      dispersed = list(
        x = list(breaks = disp$.long, labels = disp$side),
        y = list(breaks = NULL, labels = ""),
        labs = list(y = NULL, x = "side")
      )
    )
  }

  ad_scale[[position]][[aesthetics]]
}


## quiets concerns of R CMD checks
utils::globalVariables(c(
  "area",
  "atlas",
  "colour",
  "group",
  "hemi",
  ".lat",
  ".long",
  ".id",
  "side",
  "x",
  ".data",
  "dkt",
  ".lat_sd",
  ".long_sd",
  "data",
  "tt",
  "atlas_scale_positions",
  ".long_min",
  "L2"
))
