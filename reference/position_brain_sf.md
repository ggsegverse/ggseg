# Deprecated sf brain-view layout

\`r lifecycle::badge("deprecated")\`

The sf rendering path is deprecated. \`position_brain_sf()\` returns the
legacy \`PositionBrain\` ggproto for use with \[geom_brain_sf()\]. For
new code, use \[position_brain()\] (the polygon default), or convert the
atlas with \`as_sf_atlas()\` and use \[ggplot2::geom_sf()\] directly.

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
  atlases (e.g., \`hemi ~ view\`). For subcortical/tract atlases, can be
  "horizontal", "vertical", or a formula with \`type ~ .\` where type is
  extracted from view names like "axial_1" -\> "axial".

- nrow:

  Number of rows for grid layout. If NULL (default), calculated
  automatically. Only used for subcortical/tract atlases when position
  is not a formula.

- ncol:

  Number of columns for grid layout. If NULL (default), calculated
  automatically. Only used for subcortical/tract atlases when position
  is not a formula.

- views:

  Character vector specifying which views to include and their order. If
  NULL (default), all views are included in their original order. Only
  applies to subcortical/tract atlases.

## Value

A \`PositionBrain\` ggproto object.
