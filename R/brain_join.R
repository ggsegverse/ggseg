#' Join user data with a brain atlas
#'
#' Performs a full join between user data and a brain atlas. Grouped data
#' is handled automatically, producing one complete atlas per group.
#'
#' @param data A data.frame with a column matching an atlas column
#'   (typically `"region"`). Can be grouped with [dplyr::group_by()].
#' @param atlas A `brain_atlas` object or data.frame containing atlas data.
#' @param by Character vector of column names to join by. If `NULL` (default),
#'   columns are detected automatically.
#'
#' @return An `sf` object if the atlas contains geometry, otherwise a tibble.
#' @export
#' @importFrom dplyr is.grouped_df full_join as_tibble
#' @importFrom tidyr nest unnest
#' @importFrom sf st_as_sf
#' @examples
#' someData <- data.frame(
#'   region = c(
#'     "transverse temporal", "insula",
#'     "precentral", "superior parietal"
#'   ),
#'   p = sample(seq(0, .5, .001), 4),
#'   stringsAsFactors = FALSE
#' )
#'
#' brain_join(someData, dk)
#' brain_join(someData, dk, "region")
#'
brain_join <- function(data, atlas, by = NULL) {
  atlas <- as.data.frame(atlas)

  if (is.null(by)) {
    by <- names(data)[names(data) %in% names(atlas)]
    message(paste0(
      "merging atlas and data by ",
      paste(
        vapply(by, function(x) paste0("'", x, "'"), character(1)),
        collapse = ", "
      )
    ))
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
    errs <- dplyr::select(errs, -starts_with("."))
    errs <- dplyr::as_tibble(errs)

    warning(
      paste(
        "Some data not merged properly. Check for naming errors in data:",
        paste0(capture.output(errs)[-1], collapse = "\n"),
        sep = "\n"
      ),
      call. = FALSE
    )
  }

  if ("geometry" %in% names(dt)) {
    st_as_sf(dt)
  } else {
    as_tibble(dt)
  }
}
