# Deprecated sf brain geom

\`r lifecycle::badge("deprecated")\`

The sf rendering path is deprecated. \`geom_brain_sf()\` renders an
atlas via \[ggplot2::geom_sf()\] and
\[coord_sf()\]\[ggplot2::coord_sf\]. For new code, use \[geom_brain()\]
(the polygon default), or convert the atlas with \`as_sf_atlas()\` and
use \[ggplot2::geom_sf()\] directly for the full sf toolkit (labels,
other sf layers).

## Usage

``` r
geom_brain_sf(
  mapping = aes(),
  data = NULL,
  atlas,
  hemi = NULL,
  view = NULL,
  position = NULL,
  show.legend = NA,
  inherit.aes = TRUE,
  ...
)
```

## Arguments

- mapping:

  Set of aesthetic mappings created by \[ggplot2::aes()\].

- data:

  A data.frame containing variables to map. If \`NULL\`, the atlas is
  plotted without user data. Group it with \[dplyr::group_by()\] to
  facet.

- atlas:

  A \`ggseg_atlas\` object (e.g. \`dk()\`, \`aseg()\`, \`tracula()\`).

- hemi:

  Character vector of hemispheres to include (e.g. \`"left"\`,
  \`"right"\`). Defaults to all hemispheres in the atlas.

- view:

  Character vector of views to include, as recorded in the atlas data.
  For cortical atlases: \`"lateral"\`, \`"medial"\`. For
  subcortical/tract atlases: slice identifiers like \`"axial_3"\`.
  Defaults to all views.

- position:

  Position adjustment, either as a string or the result of a call to
  \[position_brain()\].

- show.legend:

  Logical. Should this layer be included in the legends?

- inherit.aes:

  Logical. If \`FALSE\`, overrides the default aesthetics rather than
  combining with them.

- ...:

  Additional arguments passed to \[ggplot2::geom_polygon()\].

## Value

A list of ggplot2 layer and coord objects.
