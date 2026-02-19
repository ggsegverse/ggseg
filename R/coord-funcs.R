#' Reduce horizontal gap between hemispheres
#'
#' Shifts right-hemisphere coordinates closer to the left hemisphere
#' by collapsing the empty space between them.
#'
#' @param geobrain Data.frame with `.long` and `hemi` columns.
#' @param hemisphere Character vector of hemispheres present.
#'
#' @return Modified data.frame with adjusted `.long` values.
#' @importFrom dplyr group_by summarise_at vars mutate
#' @importFrom stats sd
#' @keywords internal
#' @noRd
squish_position <- function(geobrain, hemisphere) {
  mm <- group_by(geobrain, hemi)
  mm <- summarise_at(mm, vars(.long), list(max = max, min = min, sd = sd))
  diff <- mm$min[2] - mm$max[1]

  mutate(
    geobrain,
    .long = ifelse(hemi == "right", .long - diff + mm$sd[1] * .5, .long)
  )
}

#' Stack brain views into a compact layout
#'
#' Repositions cortical or subcortical atlas coordinates so that
#' hemisphere/view combinations tile without overlap.
#'
#' @param atlas Data.frame with columns `hemi`, `view`, `type`,
#'   `.lat`, and `.long`.
#'
#' @return Modified data.frame with repositioned coordinates.
#' @importFrom dplyr group_by mutate arrange
#' @keywords internal
#' @noRd
stack_brain <- function(atlas) {
  if (unique(atlas$type) == "cortical") {
    stack <- group_by(atlas, hemi, view)
    stack <- calc_stack(stack)

    atlas <- mutate(
      atlas,
      .lat = ifelse(hemi %in% "right", .lat + (stack$.lat_max[1]), .lat),
      .long = ifelse(
        hemi %in% "right" & view %in% "lateral",
        .long - stack$.long_min[3],
        .long
      ),
      .long = ifelse(
        hemi %in% "right" & view %in% "medial",
        .long + (stack$.long_min[2] - stack$.long_min[4]),
        .long
      )
    )
  } else if (unique(atlas$type) == "subcortical") {
    stack <- group_by(atlas, view)
    stack <- calc_stack(stack)
    stack <- arrange(stack, .long_min)

    for (k in seq_len(nrow(stack))) {
      atlas <- mutate(
        atlas,
        .lat = ifelse(
          view %in% stack$view[k],
          .lat + mean(stack$.lat_max) * k,
          .lat
        ),
        .long = ifelse(
          view %in% stack$view[k],
          .long - stack$.long_mean[k],
          .long
        )
      )
    }
  } else {
    cli::cli_warn("Atlas 'type' not set, stacking not possible.")
  }

  atlas
}

#' Compute stacking offsets for grouped brain views
#'
#' Summarises grouped coordinate data to determine bounding-box
#' statistics used by [stack_brain()].
#'
#' @param stack Grouped data.frame with `.long` and `.lat` columns.
#'
#' @return Data.frame of per-group min, max, sd, and mean values.
#' @importFrom dplyr summarise_at mutate
#' @importFrom ggplot2 vars
#' @importFrom stats sd
#' @keywords internal
#' @noRd
calc_stack <- function(stack) {
  stack <- summarise_at(
    stack,
    vars(.long, .lat),
    list(min = min, max = max, sd = sd, mean = mean)
  )

  stack <- mutate(stack, sd = .lat_sd + .long_sd)

  stack$.lat_max[1] <- ifelse(
    stack$.lat_max[1] / 4.5 < stack$.lat_sd[1],
    stack$.lat_max[1] + stack$.lat_sd[1],
    stack$.lat_max[1]
  )
  stack
}


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
