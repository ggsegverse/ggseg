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
  ggplot2::layer(
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

#' @noRd
LayerBrain <- ggproto(
  "LayerBrain",
  ggplot2:::Layer,
  setup_layer = function(self, data, plot) {
    dt <- ggproto_parent(ggplot2:::Layer, self)$setup_layer(data, plot)

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

      if (any(!merge_errs)) {
        k <- data[!merge_errs, ]
        k <- k[, apply(k, 2, function(x) all(!is.na(x)))]
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

    if (needs_mapping("geometry") && ggplot2:::is_sf(data)) {
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
      self$computed_mapping$fill <- as.name("region")
    }

    self$computed_mapping$label <- as.name("label")

    self$geom_params$legend <- "polygon"

    data
  }
)
