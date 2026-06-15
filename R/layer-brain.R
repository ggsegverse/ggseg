#' Create a brain atlas ggplot2 layer
#'
#' Thin wrapper around [ggplot2::layer()] that substitutes the
#' custom [LayerBrain] class for atlas-specific setup logic.
#'
#' @param geom A ggplot2 Geom ggproto object.
#' @param stat A ggplot2 Stat ggproto object or string.
#' @param data Data to display (data.frame or waiver).
#' @param mapping Set of aesthetic mappings.
#' @param position Position adjustment.
#' @param params Additional parameters for the geom/stat.
#' @param inherit.aes Whether to inherit aesthetics from the plot.
#' @param check.aes Whether to check aesthetics.
#' @param check.param Whether to check parameters.
#' @param show.legend Whether to include in legends.
#'
#' @return A [ggplot2::layer()] object of class `LayerBrain`.
#' @importFrom ggplot2 layer
#' @keywords internal
#' @noRd
layer_brain <- function(
  geom = NULL,
  stat = NULL,
  data = NULL,
  mapping = NULL,
  position = NULL,
  params = list(),
  inherit.aes = TRUE,
  check.aes = TRUE,
  check.param = TRUE,
  show.legend = NA
) {
  layer(
    geom = geom,
    stat = stat,
    data = data,
    mapping = mapping,
    position = position,
    params = params,
    inherit.aes = inherit.aes,
    check.aes = check.aes,
    check.param = check.param,
    show.legend = show.legend,
    layer_class = LayerBrain
  )
}

# ggplot2 does not export `Layer`, so we reach into its namespace once
# to get the parent ggproto. Using `getFromNamespace()` rather than `:::`
# keeps `R CMD check` clean.
ggplot2_Layer <- function() {
  utils::getFromNamespace("Layer", "ggplot2")
}

#' Custom ggplot2 Layer for brain atlas data
#'
#' A [ggplot2::ggproto()] Layer subclass that handles atlas
#' validation, hemisphere/view filtering, data joining, and
#' automatic aesthetic mapping in `setup_layer()`. Subclasses
#' ggplot2's non-exported `Layer` ggproto via
#' [utils::getFromNamespace()], avoiding `:::` usage.
#'
#' @importFrom utils capture.output getFromNamespace
#' @importFrom ggplot2 ggproto ggproto_parent
#' @keywords internal
#' @noRd
LayerBrain <- ggproto(
  "LayerBrain",
  ggplot2_Layer(),
  setup_layer = function(self, data, plot) {
    dt <- ggproto_parent(ggplot2_Layer(), self)$setup_layer(data, plot)

    atlas_obj <- self$geom_params$atlas

    if (is.null(atlas_obj)) {
      cli::cli_abort(
        "No atlas supplied, please provide a brain atlas to the geom."
      )
    }

    atlas <- as.data.frame(atlas_obj)

    if (nrow(atlas) == 0) {
      cli::cli_abort("Atlas has no data to plot.")
    }

    if (!is.null(self$geom_params$hemi)) {
      hemi <- self$geom_params$hemi
      invalid <- setdiff(hemi, unique(atlas$hemi))
      if (length(invalid) > 0) {
        avail <- unique(atlas$hemi)
        cli::cli_abort(
          "Invalid hemisphere(s): {.val {invalid}}. Available: {.val {avail}}"
        )
      }
      atlas <- atlas[atlas$hemi %in% hemi, ]
    }

    if (!is.null(self$geom_params$view)) {
      view <- self$geom_params$view
      invalid <- setdiff(view, unique(atlas$view))
      if (length(invalid) > 0) {
        avail <- unique(atlas$view)
        cli::cli_abort(
          "Invalid view(s): {.val {invalid}}. Available: {.val {avail}}"
        )
      }
      atlas <- atlas[atlas$view %in% view, ]
    }

    if (class(dt)[1] != "waiver") {
      if (!dplyr::is.grouped_df(dt)) {
        facet_vars <- plot$facet$vars()
        group_vars <- intersect(facet_vars, names(dt))
        group_vars <- setdiff(group_vars, names(atlas))
        if (length(group_vars) > 0) {
          dt <- dplyr::group_by(dt, dplyr::across(dplyr::all_of(group_vars)))
        }
      }

      data <- brain_join(dt, atlas)

      merge_errs <- vapply(
        data$geometry,
        function(x) length(!is.na(x)) > 0,
        logical(1)
      )

      if (!all(merge_errs)) {
        k <- data[!merge_errs, ]
        k <- k[, !vapply(k, anyNA, logical(1))]
        k$geometry <- NULL
        k <- paste(utils::capture.output(k), collapse = "\n")

        cli::cli_warn(sprintf(
          "Some data not merged. Check for spelling mistakes in:\n%s",
          k
        ))
        data <- data[merge_errs, ]
      }
    } else {
      data <- atlas
    }

    data <- sf::st_as_sf(data)

    needs_mapping <- function(aes_name) {
      self_map <- self$computed_mapping[[aes_name]]
      plot_map <- plot$computed_mapping[[aes_name]]
      if (isTRUE(self$inherit.aes)) {
        is.null(self_map) && is.null(plot_map)
      } else {
        is.null(self_map)
      }
    }

    if (needs_mapping("geometry") && inherits(data, "sf")) {
      geometry_col <- attr(data, "sf_column")
      self$computed_mapping$geometry <- as.name(geometry_col)
    }

    if (needs_mapping("hemi")) {
      self$computed_mapping$hemi <- as.name("hemi")
    }

    if (needs_mapping("view")) {
      self$computed_mapping$view <- as.name("view")
    }

    if (needs_mapping("type")) {
      self$computed_mapping$type <- as.name("type")
    }

    if (needs_mapping("fill")) {
      self$computed_mapping$fill <- as.name("label")
    }

    self$computed_mapping$label <- as.name("label")

    self$geom_params$legend <- "polygon"

    data
  }
)
