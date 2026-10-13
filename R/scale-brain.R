# Colour and fill ----
#' Colour and fill scales from brain atlas palettes
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Atlas palettes are now applied automatically by [geom_brain()].
#' Use [scale_fill_brain_manual()] for custom palettes.
#'
#' @param name String name of the atlas palette (e.g. `"dk"`, `"aseg"`).
#' @param na.value Colour for `NA` entries (default: `"grey"`).
#' @param aesthetics Which aesthetic to scale: `"fill"`, `"colour"`, or
#'   `"color"`.
#' @param ... Additional arguments passed to [ggseg.formats::atlas_palette()].
#'
#' @return A ggplot2 scale object.
#' @rdname scale_brain
#' @export
#'
#' @importFrom ggplot2 scale_color_manual scale_colour_manual scale_fill_manual
#' @importFrom ggseg.formats atlas_palette
#' @examples
#' \dontrun{
#' library(ggplot2)
#' ggplot() +
#'   geom_brain(atlas = dk(), aes(fill = label), show.legend = FALSE) +
#'   scale_brain("dk")
#' }
scale_brain <- function(
  name = "dk",
  na.value = "grey",
  ...,
  aesthetics = c("fill", "colour", "color")
) {
  lifecycle::deprecate_warn(
    "2.0.0",
    "scale_brain()",
    details = "Atlas palettes are now applied automatically by `geom_brain()`."
  )
  pal <- atlas_palette_by_name(name, ...)
  aesthetics <- match.arg(aesthetics)
  func <- switch(
    aesthetics,
    color = scale_color_manual,
    colour = scale_colour_manual,
    fill = scale_fill_manual
  )
  scale_warning_on_key_mismatch(
    func(values = pal, na.value = na.value),
    pal,
    if (aesthetics == "fill") "fill" else "colour"
  )
}

#' @rdname scale_brain
#' @export
scale_colour_brain <- function(name = "dk", na.value = "grey", ...) {
  lifecycle::deprecate_warn(
    "2.0.0",
    "scale_colour_brain()",
    details = "Atlas palettes are now applied automatically by `geom_brain()`."
  )
  pal <- atlas_palette_by_name(name, ...)
  scale_warning_on_key_mismatch(
    scale_colour_manual(values = pal, na.value = na.value),
    pal,
    "colour"
  )
}

#' @rdname scale_brain
#' @export
scale_color_brain <- function(name = "dk", na.value = "grey", ...) {
  lifecycle::deprecate_warn(
    "2.0.0",
    "scale_color_brain()",
    details = "Atlas palettes are now applied automatically by `geom_brain()`."
  )
  pal <- atlas_palette_by_name(name, ...)
  scale_warning_on_key_mismatch(
    scale_color_manual(values = pal, na.value = na.value),
    pal,
    "colour"
  )
}

#' @export
#' @rdname scale_brain
scale_fill_brain <- function(name = "dk", na.value = "grey", ...) {
  lifecycle::deprecate_warn(
    "2.0.0",
    "scale_fill_brain()",
    details = "Atlas palettes are now applied automatically by `geom_brain()`."
  )
  pal <- atlas_palette_by_name(name, ...)
  scale_warning_on_key_mismatch(
    scale_fill_manual(values = pal, na.value = na.value),
    pal,
    "fill"
  )
}

#' Manual colour and fill scales for brain plots
#'
#' @description
#' Apply a custom named colour palette to brain atlas plots. Use this
#' when you want to override the atlas default colours with your own
#' colour mapping.
#'
#' @param palette Named character vector mapping region names to colours.
#' @param na.value Colour for `NA` entries (default: `"grey"`).
#' @param aesthetics Which aesthetic to scale: `"fill"`, `"colour"`, or
#'   `"color"`.
#' @param ... Additional arguments (unused).
#'
#' @return A ggplot2 scale object.
#' @rdname scale_brain_manual
#' @export
#' @examples
#' library(ggplot2)
#'
#' labels <- sort(unique(ggseg.formats::atlas_labels(dk())))[1:2]
#' pal <- setNames(c("red", "blue"), labels)
#' ggplot() +
#'   geom_brain(atlas = dk(), aes(fill = label), show.legend = FALSE) +
#'   scale_fill_brain_manual(palette = pal)
#'
scale_brain_manual <- function(
  palette,
  na.value = "grey",
  ...,
  aesthetics = c("fill", "colour", "color")
) {
  aesthetics <- match.arg(aesthetics)
  func <- switch(
    aesthetics,
    color = ggplot2::scale_color_manual,
    colour = ggplot2::scale_colour_manual,
    fill = ggplot2::scale_fill_manual
  )
  func(values = palette, na.value = na.value)
}

#' @rdname scale_brain_manual
#' @export
scale_colour_brain_manual <- function(...) {
  scale_brain_manual(..., aesthetics = "colour")
}

#' @rdname scale_brain_manual
#' @export
scale_color_brain_manual <- function(...) {
  scale_brain_manual(..., aesthetics = "color")
}

#' @export
#' @rdname scale_brain_manual
scale_fill_brain_manual <- function(...) {
  scale_brain_manual(..., aesthetics = "fill")
}

# Deprecated scale_brain2 variants ----
#' @rdname scale_brain2-deprecated
#' @export
scale_brain2 <- function(...) {
  lifecycle::deprecate_warn("1.7.0", "scale_brain2()", "scale_brain_manual()")
  scale_brain_manual(...)
}

#' @rdname scale_brain2-deprecated
#' @export
scale_colour_brain2 <- function(...) {
  lifecycle::deprecate_warn(
    "1.7.0",
    "scale_colour_brain2()",
    "scale_colour_brain_manual()"
  )
  scale_colour_brain_manual(...)
}

#' @rdname scale_brain2-deprecated
#' @export
scale_color_brain2 <- function(...) {
  lifecycle::deprecate_warn(
    "1.7.0",
    "scale_color_brain2()",
    "scale_color_brain_manual()"
  )
  scale_color_brain_manual(...)
}

#' @rdname scale_brain2-deprecated
#' @export
scale_fill_brain2 <- function(...) {
  lifecycle::deprecate_warn(
    "1.7.0",
    "scale_fill_brain2()",
    "scale_fill_brain_manual()"
  )
  scale_fill_brain_manual(...)
}

#' Deprecated scale functions
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' These functions have been renamed for clarity:
#' - `scale_brain2()` -> [scale_brain_manual()]
#' - `scale_fill_brain2()` -> [scale_fill_brain_manual()]
#' - `scale_colour_brain2()` -> [scale_colour_brain_manual()]
#' - `scale_color_brain2()` -> [scale_color_brain_manual()]
#'
#' @param ... Arguments passed to the replacement function.
#'
#' @return A ggplot2 scale object.
#' @name scale_brain2-deprecated
#' @examples
#' pal <- c("transversetemporal" = "#FF0000", "insula" = "#00FF00")
#' suppressWarnings(scale_fill_brain2(palette = pal))
NULL


# Axis scales ----
#' Axis and label scales for brain atlas plots
#'
#' @description
#' Add axis labels and tick labels corresponding to brain atlas regions.
#' These scales add hemisphere or view labels to the x and y axes based on
#' the atlas layout.
#'
#' @inheritParams brain_join
#' @param position Layout style: `"dispersed"` (default) or `"stacked"`.
#' @param aesthetics Which axis to scale: `"x"`, `"y"`, or `"labs"`.
#' @param ... Additional arguments passed to `adapt_scales()`.
#'
#' @return A ggplot2 scale or labs object.
#' @rdname scale_continous_brain
#' @export
#' @examples
#' \donttest{
#' library(ggplot2)
#'
#' ggplot() +
#'   geom_brain(atlas = dk(), show.legend = FALSE) +
#'   scale_x_brain() +
#'   scale_y_brain() +
#'   scale_labs_brain()
#' }
#'
scale_continous_brain <- function(
  atlas = dk(),
  position = "dispersed",
  aesthetics = c("y", "x")
) {
  # match.arg() must run first: a vector `aesthetics` makes adapt_scales()'s
  # terminal `[[` indexing recursive, which silently yields NULL breaks.
  aesthetics <- match.arg(aesthetics)
  positions <- adapt_scales(atlas, position, aesthetics)
  func <- switch(
    aesthetics,
    y = ggplot2::scale_y_continuous,
    x = ggplot2::scale_x_continuous
  )
  func(breaks = positions$breaks, labels = positions$labels)
}

#' @export
#' @rdname scale_continous_brain
scale_x_brain <- function(...) {
  scale_continous_brain(..., aesthetics = "x")
}

#' @export
#' @rdname scale_continous_brain
scale_y_brain <- function(...) {
  scale_continous_brain(..., aesthetics = "y")
}

#' @export
#' @rdname scale_continous_brain
#' @importFrom ggplot2 labs
scale_labs_brain <- function(
  atlas = dk(),
  position = "dispersed",
  aesthetics = "labs"
) {
  aesthetics <- match.arg(aesthetics)
  positions <- adapt_scales(atlas, position, aesthetics)
  func <- switch(aesthetics, labs = labs)
  func(x = positions$x, y = positions$y)
}


#' Look up an atlas palette from the atlas's function name
#'
#' Resolves `name` to a function and insists the result is a `ggseg_atlas`, so
#' a name that happens to match some unrelated visible function (`"mean"`)
#' fails with an atlas error rather than that function's own.
#'
#' @param name Name of an atlas function, e.g. `"dk"`.
#' @param ... Passed to [ggseg.formats::atlas_palette()].
#' @return Named character vector of colours.
#' @keywords internal
#' @noRd
atlas_palette_by_name <- function(name, ...) {
  atlas <- NULL
  if (is.character(name) && length(name) == 1L) {
    fn <- tryCatch(match.fun(name), error = function(e) NULL)
    if (is.function(fn)) {
      atlas <- tryCatch(fn(), error = function(e) NULL)
    }
  }

  if (!ggseg.formats::is_ggseg_atlas(atlas)) {
    cli::cli_abort(c(
      "{.arg name} must name a brain atlas function.",
      "x" = "{.val {name}} does not resolve to a {.cls ggseg_atlas}.",
      "i" = "Atlases bundled with ggseg: \\
        {.val {c('dk', 'aseg', 'suit', 'tracula')}}.",
      "i" = "Atlas packages such as {.pkg ggsegDKT} supply more."
    ))
  }

  atlas_palette(atlas, ...)
}

#' Warn when no mapped value matches the palette's keys
#'
#' Atlas palettes are keyed by `label` -- the ecosystem's canonical join key --
#' so `aes(fill = region)` matches nothing and every region falls through to
#' `na.value`: a uniformly grey brain with no build-time signal. Say so at the
#' point where the mismatch is first visible, and name the mapping that works.
#'
#' @param x The values the scale was asked to map.
#' @param palette The named palette the scale carries.
#' @param aesthetic Name of the aesthetic, for the suggested `aes()` call.
#' @return Invisibly `NULL`; called for its side effect.
#' @keywords internal
#' @noRd
warn_palette_key_mismatch <- function(x, palette, aesthetic) {
  values <- unique(as.character(x))
  values <- values[!is.na(values)]
  if (length(values) == 0 || any(values %in% names(palette))) {
    return(invisible(NULL))
  }

  cli::cli_warn(
    c(
      "!" = "No mapped value matches the atlas palette, so every region \
        is drawn with {.arg na.value}.",
      "x" = "Mapped value{?s} {.val {utils::head(values, 3)}} \\
        {?is/are} not a palette key.",
      "i" = "Atlas palettes are keyed by {.field label}; map \
        {.code aes({aesthetic} = label)}."
    ),
    class = "ggseg_palette_key_mismatch"
  )
  invisible(NULL)
}

#' Wrap a manual scale so a key mismatch is reported at build time
#'
#' @param scale A ggplot2 discrete scale carrying `palette` as its values.
#' @param palette The named palette the scale carries.
#' @param aesthetic Name of the aesthetic, for the suggested `aes()` call.
#' @return A ggproto child of `scale` that warns before mapping.
#' @keywords internal
#' @noRd
scale_warning_on_key_mismatch <- function(scale, palette, aesthetic) {
  ggplot2::ggproto(
    NULL,
    scale,
    map = function(self, x, ...) {
      warn_palette_key_mismatch(x, palette, aesthetic)
      ggplot2::ggproto_parent(scale, self)$map(x, ...)
    }
  )
}
