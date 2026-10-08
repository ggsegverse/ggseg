#' Compute axis scale positions for brain atlas plots
#'
#' Returns axis breaks, labels, and lab strings based on atlas layout.
#' Used internally by [scale_continous_brain()] and related functions.
#'
#' @param geobrain A `ggseg_atlas`, or a flattened atlas data.frame with columns
#'   `hemi`, `view`, `type`, `.lat`, and `.long`.
#' @inheritParams reposition_brain
#' @inheritParams scale_brain
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
    if (!ggseg.formats::is_ggseg_atlas(geobrain)) {
      cli::cli_abort(c(
        "{.arg atlas} must be a {.cls ggseg_atlas}.",
        "i" = "Got {.cls {class(geobrain)}}."
      ))
    }
    geobrain <- atlas_scale_coords(geobrain)
  }

  atlas_type <- unique(geobrain$type)
  if (atlas_type == "cortical") {
    adapt_scales_cortical(geobrain, position, aesthetics)
  } else if (atlas_type %in% c("subcortical", "tract", "cerebellar")) {
    # Cerebellar atlases (e.g. suit()) are slice-based like subcortical ones,
    # so their axes are labelled by view, not hemisphere.
    adapt_scales_subcortical(geobrain, position, aesthetics)
  } else {
    cli::cli_abort(c(
      "Cannot build brain axis scales for atlas type {.val {atlas_type}}.",
      "i" = "Supported types: {.val cortical}, {.val subcortical}, \
        {.val tract}, {.val cerebellar}."
    ))
  }
}


#' Vertex coordinates of an atlas for axis scaling
#'
#' Flattens an atlas to one row per polygon vertex and names the coordinates
#' `.long`/`.lat`, the frame [adapt_scales()] summarises. It goes through
#' [prepare_polygon_atlas()], i.e. `ggseg.formats::atlas_polygons()`, so the
#' exported `scale_x_brain()` family works without the optional `sf` package.
#' No branch on `is_atlas_polygon()` / `is_atlas_sf()` is needed:
#' `atlas_polygons()` already serves both, converting an sf-backed atlas on the
#' fly (which can only exist where `sf` is installed anyway). No layout is
#' applied, so the coordinates are the atlas's own frame, as the previous
#' sf-derived ones were.
#'
#' @param atlas A `ggseg_atlas`.
#' @return A data.frame with `.long`, `.lat` and the atlas metadata columns.
#' @keywords internal
#' @noRd
atlas_scale_coords <- function(atlas) {
  flat <- prepare_polygon_atlas(atlas)
  flat$.long <- flat$x
  flat$.lat <- flat$y
  flat
}


#' @keywords internal
#' @noRd
adapt_scales_cortical <- function(geobrain, position, aesthetics) {
  stk_y <- dplyr::summarise(dplyr::group_by(geobrain, hemi), val = gap(.lat))
  stk_x <- dplyr::summarise(dplyr::group_by(geobrain, view), val = gap(.long))
  disp <- dplyr::summarise_at(
    dplyr::group_by(geobrain, hemi),
    dplyr::vars(.long, .lat),
    list(gap)
  )

  ad_scale <- list(
    stacked = list(
      x = list(breaks = stk_x$val, labels = stk_x$view),
      y = list(breaks = stk_y$val, labels = stk_y$hemi),
      labs = list(y = "hemisphere", x = "view")
    ),
    dispersed = list(
      x = list(breaks = disp$.long, labels = disp$hemi),
      y = list(breaks = NULL, labels = NULL),
      labs = list(y = NULL, x = "hemisphere")
    )
  )

  ad_scale[[position]][[aesthetics]]
}


#' @keywords internal
#' @noRd
adapt_scales_subcortical <- function(geobrain, position, aesthetics) {
  stk_y <- dplyr::summarise(dplyr::group_by(geobrain, view), val = gap(.lat))
  disp <- dplyr::summarise_at(
    dplyr::group_by(geobrain, view),
    dplyr::vars(.long, .lat),
    list(gap)
  )

  ad_scale <- list(
    stacked = list(
      x = list(breaks = NULL, labels = NULL),
      y = list(breaks = stk_y$val, labels = stk_y$view),
      labs = list(y = "view", x = NULL)
    ),
    dispersed = list(
      x = list(breaks = disp$.long, labels = disp$view),
      y = list(breaks = NULL, labels = NULL),
      labs = list(y = NULL, x = "view")
    )
  )

  ad_scale[[position]][[aesthetics]]
}
