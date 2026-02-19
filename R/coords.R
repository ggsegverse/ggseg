#' Extract polygon coordinates from sf geometry
#'
#' Converts an sf geometry column into a data.frame of polygon
#' vertex coordinates with unique sub-ID and ordering columns.
#'
#' @param x An sf geometry object (e.g. `sfc_MULTIPOLYGON`).
#' @param n Integer row index used to generate unique `.subid` values.
#'
#' @return Data.frame with columns `.long`, `.lat`, `.subid`, `.id`,
#'   `.poly`, and `.order`.
#' @importFrom dplyr as_tibble group_by mutate row_number ungroup
#' @importFrom sf st_combine st_coordinates
#' @keywords internal
#' @noRd
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

#' Convert coordinate data.frame back to sf geometry
#'
#' Rebuilds sf MULTIPOLYGON geometry from a data.frame of vertex
#' coordinates (columns starting with `.`).
#'
#' @param x Data.frame with coordinate columns `.long`, `.lat`,
#'   `.subid`, `.id`.
#' @param vertex_size_limits Optional length-2 numeric vector
#'   `c(min, max)` to filter polygons by vertex count.
#'
#' @return An sf data.frame with MULTIPOLYGON geometry.
#' @importFrom dplyr group_by group_split select starts_with
#' @importFrom sf st_polygon st_sfc st_sf st_zm st_cast
#' @keywords internal
#' @noRd
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

#' Convert sf atlas data.frame to coordinate list-column
#'
#' Extracts vertex coordinates from each row's geometry into a
#' nested `ggseg` list-column, then drops the geometry column.
#'
#' @param x An sf data.frame with a `geometry` column.
#'
#' @return Data.frame with a `ggseg` list-column of coordinate
#'   data.frames and no `geometry` column.
#' @importFrom dplyr mutate row_number as_tibble
#' @keywords internal
#' @noRd
sf2coords <- function(x) {
  dt <- x
  dt$ggseg <- lapply(
    seq_len(nrow(x)),
    function(i) to_coords(x$geometry[[i]], i)
  )
  dt$geometry <- NULL
  dt
}
