# The sf coordinate path these two functions implement is the oracle the
# polygon renderer is checked against: test-ggseg-adapt_scales.R asserts the
# polygon path reproduces sf-derived coordinates exactly. Nothing in R/ calls
# them, so they live here rather than shipping as unreachable package code.

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

  k <- sf::st_combine(x)
  k <- sf::st_coordinates(k)
  k <- dplyr::as_tibble(k)
  k$L2 <- n * 10000 + k$L2
  k <- dplyr::group_by(k, L2)
  k <- dplyr::mutate(k, .order = dplyr::row_number())
  k <- dplyr::ungroup(k)
  names(k) <- cols

  k
}

sf2coords <- function(x) {
  dt <- x
  dt$ggseg <- lapply(
    seq_len(nrow(x)),
    function(i) to_coords(x$geometry[[i]], i)
  )
  dt$geometry <- NULL
  dt
}

# Mocking the whole sf coordinate surface, rather than one internal, is what
# makes "the scales need no sf" a claim about the code under test instead of a
# claim about a function the test itself supplies.
local_sf_unusable <- function(.env = parent.frame()) {
  reject <- function(...) stop("the sf coordinate path was used")
  testthat::local_mocked_bindings(
    st_combine = reject,
    st_coordinates = reject,
    st_as_sf = reject,
    st_bbox = reject,
    .package = "sf",
    .env = .env
  )
}
