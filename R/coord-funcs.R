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

#' @importFrom dplyr summarise_at mutate
#' @importFrom ggplot2 vars
#' @importFrom stats sd
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


#' @keywords internal
#' @noRd
gap <- function(x) {
  (min(x) + max(x)) / 2
}
