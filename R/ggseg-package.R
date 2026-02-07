#' ggseg: Plot brain segmentations with ggplot
#'
#' Plotting results from analyses done on data derived from brain
#' segmentations is a common need, but may be quite laborious.
#' Results from such analyses are usually easier to interpret if
#' the plot can mimic the shape and position in the brain it
#' represents.
#'
#' This package contains data from various brain parcellations,
#' with convenient functions to inspect the results directly on
#' a brain-plot wither with ggplot (2D polygons).
#'
#' @name ggseg
#' @docType package
#' @keywords internal
#' @import ggplot2
#' @import ggseg.formats
#' @importFrom sf st_as_sf st_as_sfc
#' @importFrom utils capture.output
"_PACKAGE"
