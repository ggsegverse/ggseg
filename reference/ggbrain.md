# Plot brain atlas regions

A ggplot2 geom for rendering brain atlas regions as filled polygons,
built on top of \[ggplot2::geom_sf()\]. Accepts a \`brain_atlas\` object
and automatically joins user data to atlas geometry for visualisation.

## Usage

``` r
geom_brain(
  mapping = aes(),
  data = NULL,
  atlas,
  hemi = NULL,
  view = NULL,
  position = position_brain(),
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
  plotted without user data.

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

  Additional arguments passed to \[ggplot2::geom_sf()\].

## Value

A list of ggplot2 layer and coord objects.

## GeomBrain ggproto

\`GeomBrain\` is a \[ggplot2::Geom\] ggproto object that handles
rendering of brain atlas polygons. It is used internally by
\[geom_brain()\] and should not typically be called directly.

## Examples

``` r
library(ggplot2)

ggplot() +
  geom_brain(atlas = dk())
```
