#' @importFrom dplyr as_tibble group_by mutate row_number ungroup
#' @importFrom sf st_combine st_coordinates
to_coords <- function(x, n) {
  cols <- c(".long", ".lat", ".subid", ".id", ".poly", ".order")
  if (length(x) == 0) {
    k <- data.frame(matrix(
      nrow = 0,
      ncol = length(cols)
    ))
    names(k) <- cols
    return(k)
  }

  k <- st_combine(x)
  k <- st_coordinates(k)
  k <- as_tibble(k)
  k$L2 <- n * 10000 + k$L2
  k <- group_by(k, L2)
  k <- mutate(k, .order = row_number())
  k <- ungroup(k)
  names(k) <- cols

  k
}

#' @importFrom dplyr group_by group_split select starts_with
#' @importFrom sf st_polygon st_sfc st_sf st_zm st_cast
coords2sf <- function(x, vertex_size_limits = NULL) {
  dt <- select(x, starts_with("."))
  dt <- group_by(dt, .subid, .id) # nolint [object_usage_linter]
  dt <- group_split(dt)

  if (!is.null(vertex_size_limits)) {
    min_size <- vertex_size_limits[1]
    max_size <- vertex_size_limits[2]
    if (!is.na(min_size)) {
      dt <- dt[vapply(dt, function(x) nrow(x) > min_size, logical(1))]
    }
    if (!is.na(max_size)) {
      dt <- dt[vapply(dt, function(x) nrow(x) < max_size, logical(1))]
    }
  }

  dt <- lapply(dt, as.matrix)
  dt <- lapply(dt, function(x) matrix(as.numeric(x[, 1:4]), ncol = 4))

  dt <- st_polygon(dt)
  dt <- st_sfc(dt)
  dt <- st_sf(dt)
  dt <- st_zm(dt)
  st_cast(dt, "MULTIPOLYGON")
}

#' @importFrom dplyr mutate row_number as_tibble
sf2coords <- function(x) {
  dt <- x
  dt$ggseg <- lapply(
    seq_len(nrow(x)),
    function(i) to_coords(x$geometry[[i]], i)
  )
  dt$geometry <- NULL
  dt
}
