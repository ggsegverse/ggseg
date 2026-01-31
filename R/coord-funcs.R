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
    stack <- group_by(atlas, hemi, side)
    stack <- calc_stack(stack)

    atlas = mutate(
      atlas,
      .lat = ifelse(hemi %in% "right", .lat + (stack$.lat_max[1]), .lat),
      .long = ifelse(
        hemi %in% "right" & side %in% "lateral",
        .long - stack$.long_min[3],
        .long
      ),
      .long = ifelse(
        hemi %in% "right" & side %in% "medial",
        .long + (stack$.long_min[2] - stack$.long_min[4]),
        .long
      )
    )
  } else if (unique(atlas$type) == "subcortical") {
    stack <- group_by(atlas, side)
    stack <- calc_stack(stack)
    stack <- arrange(stack, .long_min)

    for (k in 1:nrow(stack)) {
      atlas <- mutate(
        atlas,
        .lat = ifelse(
          side %in% stack$side[k],
          .lat + mean(stack$.lat_max) * k,
          .lat
        ),
        .long = ifelse(
          side %in% stack$side[k],
          .long - stack$.long_mean[k],
          .long
        )
      )
    }
  } else {
    cat("Atlas '.type' not set, stacking not possible.")
  }

  return(atlas)
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


#' Turn coordinates to sf polygons
#'
#' @param coords lat, long, order, polygon
#' @param vertex_size_limits size limits of the vertices
#'
#' @noRd
#' @importFrom dplyr group_by group_split
#' @importFrom sf st_polygon st_sfc st_sf st_zm st_cast
#' @importFrom tidyr unnest
#' @keywords internal
coords2sf <- function(coords, vertex_size_limits = NULL) {
  dt <- unnest(coords, ggseg)
  dt <- dt[, c(".long", ".lat", ".id", ".subid")]
  dt <- group_by(dt, .subid, .id)
  dt <- group_split(dt)

  if (!is.null(vertex_size_limits)) {
    if (!is.na(vertex_size_limits[1])) {
      dt <- dt[sapply(dt, function(x) nrow(x) > vertex_size_limits[1])]
    }

    if (!is.na(vertex_size_limits[2])) {
      dt <- dt[sapply(dt, function(x) nrow(x) < vertex_size_limits[2])]
    }
  }

  dt <- lapply(dt, as.matrix)
  dt <- lapply(dt, function(x) rbind(x[, 1:4], x[1, 1:4]))
  dt <- lapply(dt, function(x) matrix(as.numeric(x), ncol = 4))

  dt <- st_polygon(dt)
  dt <- st_sfc(dt)
  dt <- st_sf(dt)
  dt <- st_zm(dt)
  dt <- st_cast(dt, "MULTIPOLYGON")
  dt$lab <- coords$lab
  dt
}

#' Turn sf polygons to coordinates
#' @noRd
sf2coords <- function(x) {
  x$ggseg <- lapply(1:nrow(x), function(y) to_coords(x$geometry[[y]], y))
  x$geometry <- NULL
  x
}


#' @importFrom dplyr as_tibble group_by mutate row_number ungroup
#' @importFrom sf st_combine st_coordinates
#' @keywords internal
#' @noRd
to_coords <- function(x, n) {
  k <- st_combine(x)
  k <- st_coordinates(k)
  k <- as_tibble(k)
  k$L2 <- n * 10000 + k$L2

  k <- group_by(k, L2)
  k <- mutate(k, .order = row_number())
  k <- ungroup(k)

  names(k) <- c(".long", ".lat", ".subid", ".id", ".poly", ".order")

  k
}

#' @keywords internal
#' @noRd
gap <- function(x) {
  (min(x) + max(x)) / 2
}
