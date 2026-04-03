#' Plot brain atlas regions as vertex-derived convex hull polygons
#'
#' A ggplot2 geom for rendering cortical brain atlas regions as smooth
#' filled polygons derived from fsaverage surface mesh vertices. Each region's
#' convex hull is computed from its 2D-projected vertex positions, producing
#' a smoother appearance than the polygon-based [geom_brain()].
#'
#' Requires a cortical `brain_atlas` with vertex data (e.g. [dk()]). The
#' atlas vertices are projected to 2D via an orthographic projection: the
#' anterior-posterior axis (y) and superior-inferior axis (z) of the inflated
#' surface are used as the 2D x and y coordinates respectively. Back-face
#' culling separates lateral from medial views based on the medial-lateral
#' position (x) of each vertex relative to the hemisphere centre.
#'
#' @param mapping Set of aesthetic mappings created by [ggplot2::aes()].
#' @param data A data.frame with variables to map. If `NULL`, the atlas is
#'   plotted with default region colouring.
#' @param atlas A cortical `brain_atlas` object with vertex data (e.g. [dk()]).
#' @param hemi Character vector of hemispheres to include (`"left"`, `"right"`).
#'   Defaults to all hemispheres in the atlas.
#' @param view Character vector of views to include (`"lateral"`, `"medial"`).
#'   Defaults to all views.
#' @param surface Surface type passed to [ggseg.formats::get_brain_mesh()].
#'   Defaults to `"inflated"`.
#' @param brain_meshes Optional custom mesh list. See
#'   [ggseg.formats::get_brain_mesh()].
#' @param position Position adjustment, typically [position_brain()].
#' @param show.legend Logical. Should this layer be included in the legends?
#' @param inherit.aes Logical. If `FALSE`, overrides the default aesthetics
#'   rather than combining with them.
#' @param ... Additional arguments passed to the geom.
#'
#' @return A list of ggplot2 layer and coord objects.
#' @include geom-brain.R
#' @export
#'
#' @examples
#' library(ggplot2)
#'
#' ggplot() +
#'   geom_brain_vertices(atlas = dk())
#'
#' someData <- data.frame(
#'   region = c("transverse temporal", "insula", "precentral"),
#'   p = c(0.1, 0.2, 0.3)
#' )
#' ggplot(someData) +
#'   geom_brain_vertices(atlas = dk(), aes(fill = p))
geom_brain_vertices <- function(
  mapping = aes(),
  data = NULL,
  atlas,
  hemi = NULL,
  view = NULL,
  surface = "inflated",
  brain_meshes = NULL,
  position = position_brain(),
  show.legend = NA,
  inherit.aes = TRUE,
  ...
) {
  result <- list(
    layer_brain_vertices(
      geom = GeomBrainVertices,
      data = data,
      mapping = mapping,
      stat = "sf",
      position = position,
      show.legend = show.legend,
      inherit.aes = inherit.aes,
      params = c(
        list(
          na.rm = FALSE,
          atlas = atlas,
          hemi = hemi,
          view = view,
          surface = surface,
          brain_meshes = brain_meshes
        ),
        list(...)
      )
    ),
    coord_sf(default = TRUE, clip = "off")
  )

  has_fill_aes <- "fill" %in% names(mapping)
  if (!is.null(atlas$palette) && !has_fill_aes) {
    result <- c(
      result,
      list(
        ggplot2::scale_fill_manual(values = atlas$palette, na.value = "grey")
      )
    )
  }

  result
}


#' @section GeomBrainVertices ggproto:
#' `GeomBrainVertices` is a [ggplot2::Geom] ggproto object that renders
#' brain atlas regions as convex hull polygons derived from surface vertex
#' positions. Inherits polygon rendering from [GeomBrain].
#'
#' @export
#' @rdname geom_brain_vertices
#' @usage NULL
#' @format NULL
GeomBrainVertices <- ggproto(
  "GeomBrainVertices",
  GeomBrain,
  default_aes = aes(
    colour = NULL,
    fill = NULL,
    size = NULL,
    linetype = 1,
    alpha = NA,
    stroke = 0.5
  ),
  draw_key = ggplot2::draw_key_polygon,
  draw_panel = function(
    data,
    atlas,
    hemi,
    view,
    surface,
    brain_meshes,
    panel_params,
    coord,
    legend = NULL,
    lineend = "butt",
    linejoin = "round",
    linemitre = 10,
    na.rm = TRUE
  ) {
    GeomBrain$draw_panel(
      data, atlas, hemi, view,
      panel_params, coord,
      legend = legend,
      lineend = lineend,
      linejoin = linejoin,
      linemitre = linemitre,
      na.rm = na.rm
    )
  }
)


#' @keywords internal
#' @noRd
layer_brain_vertices <- function(
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
    layer_class = LayerBrainVertices
  )
}


#' @importFrom sf st_as_sf st_sfc st_multipoint st_convex_hull st_polygon
#' @keywords internal
#' @noRd
LayerBrainVertices <- ggproto(
  "LayerBrainVertices",
  ggplot2:::Layer,
  setup_layer = function(self, data, plot) {
    dt <- ggproto_parent(ggplot2:::Layer, self)$setup_layer(data, plot)

    atlas_obj <- self$geom_params$atlas

    if (is.null(atlas_obj)) {
      cli::cli_abort(
        "No atlas supplied, please provide a brain atlas to the geom."
      )
    }

    if (is.null(atlas_obj$data$vertices)) {
      cli::cli_abort(c(
        "Atlas does not contain vertex data.",
        "i" = "Use a cortical atlas with vertex data, e.g. {.fn dk}."
      ))
    }

    atlas_verts <- ggseg.formats::atlas_vertices(atlas_obj)
    surface <- self$geom_params$surface
    brain_meshes_param <- self$geom_params$brain_meshes

    if (!is.null(self$geom_params$hemi)) {
      hemi <- self$geom_params$hemi
      invalid <- setdiff(hemi, unique(atlas_verts$hemi))
      if (length(invalid) > 0) {
        avail <- unique(atlas_verts$hemi)
        cli::cli_abort(
          "Invalid hemisphere(s): {.val {invalid}}. Available: {.val {avail}}"
        )
      }
      atlas_verts <- atlas_verts[atlas_verts$hemi %in% hemi, ]
    }

    sf_data <- expand_atlas_vertices_to_sf(atlas_verts, surface, brain_meshes_param)

    if (!is.null(self$geom_params$view)) {
      view <- self$geom_params$view
      invalid <- setdiff(view, unique(sf_data$view))
      if (length(invalid) > 0) {
        avail <- unique(sf_data$view)
        cli::cli_abort(
          "Invalid view(s): {.val {invalid}}. Available: {.val {avail}}"
        )
      }
      sf_data <- sf_data[sf_data$view %in% view, ]
    }

    if (class(dt)[1] != "waiver") {
      by_cols <- intersect(names(dt), c("label", "region", "hemi"))
      if (length(by_cols) > 0) {
        sf_data <- dplyr::left_join(
          sf_data,
          as.data.frame(dt),
          by = by_cols
        )
        sf_data <- sf::st_as_sf(sf_data)
      }
    }

    needs_mapping <- function(aes_name) {
      self_map <- self$computed_mapping[[aes_name]]
      plot_map <- plot$computed_mapping[[aes_name]]
      if (isTRUE(self$inherit.aes)) {
        is.null(self_map) && is.null(plot_map)
      } else {
        is.null(self_map)
      }
    }

    if (needs_mapping("geometry") && ggplot2:::is_sf(sf_data)) {
      geometry_col <- attr(sf_data, "sf_column")
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

    sf_data
  }
)


#' Expand atlas vertex indices to sf convex hull POLYGON geometry
#'
#' For each region and view (lateral/medial), looks up the 3D vertex
#' coordinates from the brain surface mesh, applies back-face culling
#' based on x-coordinate, projects to 2D (y, z), and computes the
#' convex hull as one POLYGON geometry per region.
#'
#' Vertex indices are 0-based and converted to 1-based for R subsetting.
#'
#' @param atlas_verts Data.frame from [ggseg.formats::atlas_vertices()].
#' @param surface Surface type for [ggseg.formats::get_brain_mesh()].
#' @param brain_meshes Optional custom mesh list.
#'
#' @return An sf data.frame with one row per region×view combination.
#' @keywords internal
#' @noRd
expand_atlas_vertices_to_sf <- function(
  atlas_verts,
  surface = "inflated",
  brain_meshes = NULL
) {
  hemi_to_mesh <- c(left = "lh", right = "rh", lh = "lh", rh = "rh")
  hemis <- unique(atlas_verts$hemi)

  rows <- lapply(hemis, function(h) {
    mesh_h <- hemi_to_mesh[h]
    mesh <- ggseg.formats::get_brain_mesh(
      mesh_h,
      surface = surface,
      brain_meshes = brain_meshes
    )
    if (is.null(mesh)) return(NULL)

    hv <- atlas_verts[atlas_verts$hemi == h, ]
    if (nrow(hv) == 0) return(NULL)

    center_x <- mean(mesh$vertices$x)
    is_lateral <- if (mesh_h == "lh") {
      mesh$vertices$x < center_x
    } else {
      mesh$vertices$x > center_x
    }

    x_margin <- diff(range(mesh$vertices$x)) * 0.05
    is_lateral_strict <- if (mesh_h == "lh") {
      mesh$vertices$x < (center_x - x_margin)
    } else {
      mesh$vertices$x > (center_x + x_margin)
    }

    lapply(c("lateral", "medial"), function(v) {
      visible <- if (v == "lateral") is_lateral else !is_lateral
      visible_strict <- if (v == "lateral") is_lateral_strict else !is_lateral_strict

      flip_y <- (mesh_h == "lh" && v == "lateral") |
        (mesh_h == "rh" && v == "medial")
      y_sign <- if (flip_y) -1L else 1L

      proj_y <- y_sign * mesh$vertices$y
      proj_z <- mesh$vertices$z

      geom_list <- lapply(seq_len(nrow(hv)), function(i) {
        idx <- hv$vertices[[i]] + 1L
        keep <- idx[idx >= 1L & idx <= nrow(mesh$vertices) & visible_strict[idx]]
        if (length(keep) == 0L) {
          return(sf::st_polygon())
        }
        pts <- unique(cbind(proj_y[keep], proj_z[keep]))
        if (nrow(pts) < 3L) {
          return(sf::st_polygon())
        }
        sf::st_convex_hull(sf::st_multipoint(pts))
      })

      vis_idx <- which(visible)
      bg_hull <- if (length(vis_idx) >= 3L) {
        bg_pts <- unique(cbind(proj_y[vis_idx], proj_z[vis_idx]))
        if (nrow(bg_pts) >= 3L) sf::st_convex_hull(sf::st_multipoint(bg_pts))
        else sf::st_polygon()
      } else {
        sf::st_polygon()
      }

      rbind(
        sf::st_sf(
          label = NA_character_,
          region = NA_character_,
          hemi = h,
          view = v,
          type = "cortical",
          colour = NA_character_,
          geometry = sf::st_sfc(list(bg_hull)),
          stringsAsFactors = FALSE
        ),
        sf::st_sf(
          label = hv$label,
          region = hv$region,
          hemi = h,
          view = v,
          type = "cortical",
          colour = hv$colour,
          geometry = sf::st_sfc(geom_list),
          stringsAsFactors = FALSE
        )
      )
    })
  })

  rows_flat <- Filter(Negate(is.null), unlist(rows, recursive = FALSE))
  do.call(rbind, rows_flat)
}
