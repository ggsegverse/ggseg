#' Trim both ends of each connector, then drop the ones left too short
#'
#' Runs at draw time because millimetres do not exist until there is a device:
#' the endpoints arrive in npc, and the only way to take a perceptible gap off
#' them is to convert, trim along the segment's own direction, and convert back.
#' @noRd
#' @exportS3Method grid::makeContent
makeContent.brain_leader <- function(x) {
  anchor_x <- grid::convertX(grid::unit(x$anchor_x, "npc"), "mm", TRUE)
  anchor_y <- grid::convertY(grid::unit(x$anchor_y, "npc"), "mm", TRUE)
  label_x <- grid::convertX(grid::unit(x$label_x, "npc"), "mm", TRUE)
  label_y <- grid::convertY(grid::unit(x$label_y, "npc"), "mm", TRUE)

  box_padding <- grid::convertWidth(x$box_padding, "mm", TRUE)
  point_padding <- grid::convertWidth(x$point_padding, "mm", TRUE)
  min_length <- grid::convertWidth(x$min_length, "mm", TRUE)

  run_x <- label_x - anchor_x
  run_y <- label_y - anchor_y
  length_mm <- sqrt(run_x^2 + run_y^2)

  drawn <- length_mm > 0 &
    length_mm - box_padding - point_padding >= min_length
  if (!any(drawn)) {
    return(grid::setChildren(x, grid::gList()))
  }

  unit_x <- run_x[drawn] / length_mm[drawn]
  unit_y <- run_y[drawn] / length_mm[drawn]

  grid::setChildren(
    x,
    grid::gList(grid::segmentsGrob(
      x0 = grid::unit(anchor_x[drawn] + unit_x * point_padding, "mm"),
      y0 = grid::unit(anchor_y[drawn] + unit_y * point_padding, "mm"),
      x1 = grid::unit(label_x[drawn] - unit_x * box_padding, "mm"),
      y1 = grid::unit(label_y[drawn] - unit_y * box_padding, "mm"),
      gp = grid::gpar(
        col = recycle_to(x$colour, length(drawn))[drawn],
        lwd = x$linewidth * ggplot2::.pt
      )
    ))
  )
}

#' @noRd
connector_params <- c(
  "box.padding",
  "point.padding",
  "min.segment.length",
  "segment.colour",
  "segment.linewidth"
)

#' Geoms that draw a leader line back to the region they name
#'
#' A label nudged clear of a cramped region has to say which region it belongs
#' to, so these wrap [ggplot2::GeomText] and [ggplot2::GeomLabel] with a
#' connector. The connector appears only when the data carries `x_orig` and
#' `y_orig` -- the anchor the label was moved from -- so an un-nudged label
#' draws exactly what ggplot2 would draw.
#'
#' Padding is measured at draw time, in millimetres, because that is the only
#' place a gap between a line and a glyph can be asked for in the units a
#' reader perceives. A connector left shorter than `min.segment.length` once
#' both paddings are taken off is dropped rather than drawn as a stub.
#' @noRd
brain_text_geom <- function(parent, name) {
  ggproto(
    name,
    parent,
    default_aes = {
      defaults <- parent$default_aes
      defaults$hjust <- NA
      defaults$vjust <- NA
      defaults
    },
    # ggplot2 reads a geom's parameters off `draw_group` whenever `draw_panel`
    # takes `...`, which ours must in order to pass the rest through, so the
    # connector's own arguments are invisible to it. `extra_params` is what
    # lets `layer()` accept them; `parameters()` is what stops
    # `Geom$draw_layer()` filtering them back out before `draw_panel()` runs,
    # because it filters on `parameters()` with `extra = FALSE`.
    extra_params = c(parent$extra_params, connector_params),
    parameters = function(self, extra = FALSE) {
      union(parent$parameters(extra), connector_params)
    },
    draw_panel = function(
      self,
      data,
      panel_params,
      coord,
      box.padding = grid::unit(0.3, "lines"),
      point.padding = grid::unit(0.15, "lines"),
      min.segment.length = grid::unit(0.5, "lines"),
      segment.colour = NULL,
      segment.linewidth = 0.4,
      ...
    ) {
      nudged <- all(c("x_orig", "y_orig") %in% names(data))
      data <- justify_away_from_anchor(data, nudged)
      text <- ggproto_parent(parent, self)$draw_panel(
        data,
        panel_params,
        coord,
        ...
      )

      if (!nudged) {
        return(text)
      }

      grid::gList(
        brain_leader_grob(
          data,
          panel_params,
          coord,
          box.padding = box.padding,
          point.padding = point.padding,
          min.segment.length = min.segment.length,
          segment.colour = segment.colour,
          segment.linewidth = segment.linewidth
        ),
        text
      )
    }
  )
}

#' Face the text away from the region it points at
#'
#' A label nudged to the left of its region reads as belonging to it only if it
#' is right-justified, so justification follows the direction of the nudge
#' unless the caller set it. `NA` in `default_aes` is what distinguishes "not
#' given" from a deliberate `hjust = 0.5`.
#' @noRd
justify_away_from_anchor <- function(data, nudged) {
  if (!nudged) {
    data$hjust[is.na(data$hjust)] <- 0.5
    data$vjust[is.na(data$vjust)] <- 0.5
    return(data)
  }

  from_direction <- function(delta) {
    ifelse(delta > 0, 0, ifelse(delta < 0, 1, 0.5))
  }

  implied_h <- from_direction(data$x - data$x_orig)
  implied_v <- from_direction(data$y - data$y_orig)
  data$hjust[is.na(data$hjust)] <- implied_h[is.na(data$hjust)]
  data$vjust[is.na(data$vjust)] <- implied_v[is.na(data$vjust)]
  data
}

#' @noRd
brain_leader_grob <- function(
  data,
  panel_params,
  coord,
  box.padding,
  point.padding,
  min.segment.length,
  segment.colour,
  segment.linewidth
) {
  ends <- coord$transform(
    data.frame(
      x = data$x_orig,
      y = data$y_orig,
      xend = data$x,
      yend = data$y
    ),
    panel_params
  )

  grid::gTree(
    anchor_x = ends$x,
    anchor_y = ends$y,
    label_x = ends$xend,
    label_y = ends$yend,
    box_padding = as_padding_unit(box.padding),
    point_padding = as_padding_unit(point.padding),
    min_length = as_padding_unit(min.segment.length),
    colour = segment.colour %||% data$colour,
    linewidth = segment.linewidth,
    cl = "brain_leader"
  )
}

#' Accept a bare number as millimetres, the way ggplot2 sizes things
#' @noRd
as_padding_unit <- function(x) {
  if (grid::is.unit(x)) x else grid::unit(x, "mm")
}

#' @noRd
recycle_to <- function(x, n) {
  if (length(x) == n) x else rep_len(x, n)
}

#' @noRd
GeomBrainText <- brain_text_geom(ggplot2::GeomText, "GeomBrainText")

#' @noRd
GeomBrainLabel <- brain_text_geom(ggplot2::GeomLabel, "GeomBrainLabel")
