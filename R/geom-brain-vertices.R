#' Plot brain atlas regions from mesh vertex data
#'
#' A ggplot2 geom for rendering cortical brain atlas regions as smooth
#' filled polygons derived from fsaverage surface mesh topology. Each
#' region's polygon is built by unioning the mesh triangles (faces)
#' whose vertices all belong to that region, producing boundaries that
#' follow the actual parcellation on the cortical surface.
#'
#' Requires a cortical `brain_atlas` with vertex data (e.g. [dk()]). The
#' mesh faces are projected to 2D via an orthographic projection of the
#' inflated surface (y → x, z → y). Back-face culling separates lateral
#' from medial views based on each vertex's x-coordinate relative to the
#' hemisphere centre.
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
#' brain atlas regions as polygons derived from mesh face topology.
#' Inherits polygon rendering from [GeomBrain].
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


#' @importFrom sf st_as_sf st_sfc st_polygon st_union
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


#' Build region polygons from mesh face topology
#'
#' For each region and view (lateral/medial), finds all mesh triangles
#' whose three vertices belong to that region, projects them to 2D,
#' and unions them into a single polygon. This produces boundaries
#' that follow the actual parcellation on the cortical surface.
#'
#' Vertex and face indices are 0-based and converted to 1-based for
#' R subsetting.
#'
#' @param atlas_verts Data.frame from [ggseg.formats::atlas_vertices()].
#' @param surface Surface type for [ggseg.formats::get_brain_mesh()].
#' @param brain_meshes Optional custom mesh list.
#'
#' @return An sf data.frame with one row per region x view combination.
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

    faces_1 <- data.frame(
      i = mesh$faces$i + 1L,
      j = mesh$faces$j + 1L,
      k = mesh$faces$k + 1L
    )

    vertex_to_region <- integer(nrow(mesh$vertices))
    for (r in seq_len(nrow(hv))) {
      idx <- hv$vertices[[r]] + 1L
      idx <- idx[idx >= 1L & idx <= nrow(mesh$vertices)]
      vertex_to_region[idx] <- r
    }

    face_region <- ifelse(
      vertex_to_region[faces_1$i] == vertex_to_region[faces_1$j] &
        vertex_to_region[faces_1$j] == vertex_to_region[faces_1$k] &
        vertex_to_region[faces_1$i] > 0L,
      vertex_to_region[faces_1$i],
      0L
    )

    center_x <- mean(mesh$vertices$x)

    is_lateral <- if (mesh_h == "lh") {
      mesh$vertices$x < center_x
    } else {
      mesh$vertices$x > center_x
    }

    lapply(c("lateral", "medial"), function(v) {
      visible <- if (v == "lateral") is_lateral else !is_lateral
      face_visible <- visible[faces_1$i] | visible[faces_1$j] | visible[faces_1$k]

      flip_y <- (mesh_h == "lh" && v == "lateral") |
        (mesh_h == "rh" && v == "medial")
      y_sign <- if (flip_y) -1L else 1L

      proj_y <- y_sign * mesh$vertices$y
      proj_z <- mesh$vertices$z

      vis_fi <- which(face_visible)
      if (length(vis_fi) == 0L) return(NULL)

      tri_rings <- lapply(vis_fi, function(fi) {
        list(matrix(c(
          proj_y[faces_1$i[fi]], proj_z[faces_1$i[fi]],
          proj_y[faces_1$j[fi]], proj_z[faces_1$j[fi]],
          proj_y[faces_1$k[fi]], proj_z[faces_1$k[fi]],
          proj_y[faces_1$i[fi]], proj_z[faces_1$i[fi]]
        ), ncol = 2, byrow = TRUE))
      })

      all_polys <- sf::st_sfc(lapply(tri_rings, sf::st_polygon))
      tri_regions <- face_region[vis_fi]

      tri_sf <- sf::st_sf(
        region_idx = tri_regions,
        geometry = all_polys,
        stringsAsFactors = FALSE
      )

      bg_union <- sf::st_union(all_polys)
      bg_sfg <- if (inherits(bg_union, "sfc") && length(bg_union) > 0L) {
        bg_union[[1L]]
      } else if (inherits(bg_union, "sfg")) {
        bg_union
      } else {
        sf::st_polygon()
      }

      dissolved <- dplyr::summarise(
        dplyr::group_by(tri_sf, region_idx),
        geometry = sf::st_union(geometry),
        .groups = "drop"
      )

      region_sfg <- lapply(seq_len(nrow(hv)), function(r) {
        row <- dissolved[dissolved$region_idx == r, ]
        if (nrow(row) == 0L) return(sf::st_polygon())
        g <- row$geometry[[1L]]
        if (inherits(g, "sfg")) g
        else if (inherits(g, "sfc") && length(g) > 0L) g[[1L]]
        else sf::st_polygon()
      })

      rbind(
        sf::st_sf(
          label = NA_character_,
          region = NA_character_,
          hemi = h,
          view = v,
          type = "cortical",
          colour = NA_character_,
          geometry = sf::st_sfc(bg_sfg),
          stringsAsFactors = FALSE
        ),
        sf::st_sf(
          label = hv$label,
          region = hv$region,
          hemi = h,
          view = v,
          type = "cortical",
          colour = hv$colour,
          geometry = sf::st_sfc(region_sfg),
          stringsAsFactors = FALSE
        )
      )
    })
  })

  rows_flat <- Filter(Negate(is.null), unlist(rows, recursive = FALSE))
  do.call(rbind, rows_flat)
}
