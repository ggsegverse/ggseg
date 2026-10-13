# Deprecated sf brain-view layout

**\[deprecated\]**

The sf rendering path is deprecated. `position_brain_sf()` returns the
legacy `PositionBrain` ggproto for use with
[`geom_brain_sf()`](https://ggsegverse.github.io/ggseg/reference/geom_brain_sf.md).
For new code, use
[`position_brain()`](https://ggsegverse.github.io/ggseg/reference/position_brain.md)
(the polygon default), or convert the atlas with `as_sf_atlas()` and use
[`ggplot2::geom_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html)
directly.

## Usage

``` r
position_brain_sf(
  position = "horizontal",
  nrow = NULL,
  ncol = NULL,
  views = NULL
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

## Value

A `PositionBrain` ggproto object.

## Examples

``` r
if (FALSE) { # \dontrun{
# Deprecated: prefer position_brain(). Shown for reference only.
position_brain_sf("horizontal")
} # }
```
