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
