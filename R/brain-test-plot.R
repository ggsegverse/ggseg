#' Render a brain atlas with default snapshot styling
#'
#' Builds a minimal, deterministic plot of a `ggseg_atlas`: every region filled
#' by its `label`, no legend, and [ggplot2::theme_void()]. This is the canonical
#' construction used across the ggsegverse for visual-regression (`vdiffr`)
#' snapshots, so that every atlas is rendered the same way and a stray legend,
#' axis, or title cannot creep into a snapshot. It doubles as a quick way to
#' preview an atlas.
#'
#' The atlas `palette` is applied with [ggplot2::scale_fill_manual()] when it is
#' present; atlases without a palette fall back to the default `ggplot2` fill
#' scale.
#'
#' @param atlas A `ggseg_atlas` object, such as [dk()] or [aseg()].
#' @param position A `ggplot2` position adjustment arranging the brain views.
#'   Defaults to `position_brain(hemi ~ view)` for cortical atlases and
#'   `position_brain(. ~ view)` for slice-based atlases (subcortical,
#'   cerebellar, tract), whose views already contain both hemispheres.
#' @param na.value Fill colour for regions with no palette entry. Defaults to
#'   `"grey"`.
#'
#' @return A [ggplot2::ggplot()] object.
#'
#' @examples
#' brain_test_plot(dk())
#'
#' @seealso [geom_brain()]
#' @export
brain_test_plot <- function(
  atlas,
  position = NULL,
  na.value = "grey"
) {
  if (!ggseg.formats::is_ggseg_atlas(atlas)) {
    cli::cli_abort(c(
      "{.arg atlas} must be a {.cls ggseg_atlas} object.",
      "i" = "Got {.cls {class(atlas)}}."
    ))
  }

  if (is.null(position)) {
    position <- if (identical(ggseg.formats::atlas_type(atlas), "cortical")) {
      position_brain(hemi ~ view)
    } else {
      position_brain(. ~ view)
    }
  }

  p <- ggplot2::ggplot() +
    geom_brain(
      atlas = atlas,
      mapping = ggplot2::aes(fill = .data$label),
      position = position,
      show.legend = FALSE
    ) +
    ggplot2::theme_void()

  palette <- ggseg.formats::atlas_palette(atlas)
  if (!is.null(palette)) {
    p <- p +
      ggplot2::scale_fill_manual(
        values = palette,
        na.value = na.value
      )
  }

  p
}
