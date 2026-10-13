# Arrange brain atlas views

Controls how an atlas's hemispheres and views are arranged in the plot –
side by side, stacked, or in a grid – and can zoom each view in on the
regions you care about. Pass the result to the `position` argument of
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
(or
[`annotate_brain()`](https://ggsegverse.github.io/ggseg/reference/annotate_brain.md)).

## Usage

``` r
position_brain(
  position = "horizontal",
  nrow = NULL,
  ncol = NULL,
  views = NULL,
  zoom = NULL,
  zoom_pad = 0.05
)
```

## Arguments

- position:

  Formula describing the rows ~ columns organisation for cortical
  atlases (e.g., `hemi ~ view`). For subcortical/tract atlases, can be
  "horizontal", "vertical", or a formula with `type ~ .` where type is
  extracted from view names like "axial_1" -\> "axial".

- nrow:

  Number of rows for grid layout, a positive whole number. If `NULL`
  (default), calculated automatically. Cannot be combined with a
  `position` formula, which a grid layout would discard. Grid cells are
  hemisphere/view pairs for a cortical atlas and views for a slice-based
  one.

- ncol:

  Number of columns for grid layout, a positive whole number. If `NULL`
  (default), calculated automatically. Cannot be combined with a
  `position` formula.

- views:

  Character vector specifying which views to include and their order. If
  `NULL` (default), all views are included in their original order.
  Names the atlas does not have are dropped with a warning.

- zoom:

  Controls per-view zoom. `NULL`/`FALSE` (default) draws each view at
  full extent. `TRUE` zooms each view onto the regions your `data`
  covers, taken from its `label` column when it has one and `region`
  otherwise; a character vector names the focus explicitly, as either
  labels or regions.

- zoom_pad:

  Fractional padding added around the focus window when `zoom` is
  active. Defaults to `0.05` (5%).

## Value

A layout specification to hand to
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)'s
`position` argument.

## Examples

``` r
library(ggplot2)

# Cortical atlas with formula
ggplot() +
  geom_brain(
    atlas = dk(), aes(fill = region),
    position = position_brain(. ~ view + hemi),
    show.legend = FALSE
  )


ggplot() +
  geom_brain(
    atlas = dk(), aes(fill = region),
    position = position_brain(view ~ hemi),
    show.legend = FALSE
  )


ggplot() +
  geom_brain(
    atlas = aseg(), aes(fill = region),
    position = position_brain(nrow = 2)
  )


ggplot() +
  geom_brain(
    atlas = aseg(), aes(fill = region),
    position = position_brain(
      views = c("sagittal", "axial_3", "coronal_2"),
      nrow = 1
    )
  )


ggplot() +
  geom_brain(
    atlas = aseg(), aes(fill = region),
    position = position_brain(type ~ .)
  )
```
