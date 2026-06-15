#' Join user data with a brain atlas
#'
#' Matches your data to a brain atlas by a shared column (usually `region`),
#' keeping every atlas region whether or not you have a value for it. Grouped
#' data (via [dplyr::group_by()]) gives one complete atlas per group. You
#' rarely need this directly -- [geom_brain()] joins your data for you; reach
#' for `brain_join()` when you want the joined sf object yourself.
#'
#' @param data A data.frame with a column matching an atlas column
#'   (typically `"region"`). Can be grouped with [dplyr::group_by()].
#' @param atlas A `ggseg_atlas` object or data.frame containing atlas data.
#' @param by Character vector of column names to join by. If `NULL` (default),
#'   columns are detected automatically.
#'
#' @return An `sf` object if the atlas contains geometry, otherwise a tibble.
#' @export
#' @importFrom dplyr is.grouped_df full_join as_tibble
#' @importFrom tidyr nest unnest
#' @importFrom utils capture.output
#' @examplesIf requireNamespace("sf", quietly = TRUE)
#' someData <- data.frame(
#'   region = c(
#'     "transverse temporal", "insula",
#'     "precentral", "superior parietal"
#'   ),
#'   p = sample(seq(0, .5, .001), 4),
#'   stringsAsFactors = FALSE
#' )
#'
#' brain_join(someData, dk())
#' brain_join(someData, dk(), "region")
#'
brain_join <- function(data, atlas, by = NULL) {
  atlas <- as.data.frame(atlas)

  if (is.null(by)) {
    by <- names(data)[names(data) %in% names(atlas)]
    cli::cli_inform("Merging atlas and data by {.field {by}}.")
  }

  if (is.grouped_df(data)) {
    data2 <- nest(data)
    data2$data <- lapply(seq_len(nrow(data2)), function(x) {
      full_join(atlas, data2$data[[x]], by = by)
    })

    dt <- unnest(data2, data)
  } else {
    dt <- full_join(atlas, data, by = by)
  }

  errs <- dt[is.na(dt$atlas), ]

  if (nrow(errs) > 0) {
    errs <- dplyr::select(errs, -dplyr::starts_with("."))
    errs <- dplyr::as_tibble(errs)

    cli::cli_warn(c(
      "Some data not merged properly.",
      "i" = "Check for naming errors in data:",
      " " = paste(capture.output(errs)[-1], collapse = "\n")
    ))
  }

  if ("geometry" %in% names(dt)) {
    require_sf("brain_join()")
    sf::st_as_sf(dt)
  } else {
    as_tibble(dt)
  }
}
