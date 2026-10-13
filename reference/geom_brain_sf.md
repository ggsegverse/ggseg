# Deprecated sf brain geom

**\[deprecated\]**

The sf rendering path is deprecated. `geom_brain_sf()` renders an atlas
via
[`ggplot2::geom_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html)
and [coord_sf()](https://ggplot2.tidyverse.org/reference/ggsf.html). For
new code, use
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
(the polygon default), or convert the atlas with `as_sf_atlas()` and use
[`ggplot2::geom_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html)
directly for the full sf toolkit (labels, other sf layers).

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

  Set of aesthetic mappings created by
  [`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html).

- data:

  A data.frame containing variables to map. If `NULL`, the atlas is
  plotted without user data. Add a facet with
  [`ggplot2::facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html)
  to draw one brain per group.

- atlas:

  A `ggseg_atlas` object (e.g.
  [`dk()`](https://ggsegverse.github.io/ggseg.formats/reference/dk.html),
  [`aseg()`](https://ggsegverse.github.io/ggseg.formats/reference/aseg.html),
  [`tracula()`](https://ggsegverse.github.io/ggseg.formats/reference/tracula.html)).

- hemi:

  Character vector of hemispheres to include (e.g. `"left"`, `"right"`).
  Defaults to all hemispheres in the atlas.

- view:

  Character vector of views to include, as recorded in the atlas data.
  For cortical atlases: `"lateral"`, `"medial"`. For subcortical/tract
  atlases: slice identifiers like `"axial_3"`. Defaults to all views.

- position:

  Brain-view layout: the result of a call to
  [`position_brain()`](https://ggsegverse.github.io/ggseg/reference/position_brain.md),
  a layout string (e.g. `"horizontal"`, `"vertical"`), or a layout
  formula (e.g. `hemi ~ view`). Strings and formulas are passed to
  [`position_brain()`](https://ggsegverse.github.io/ggseg/reference/position_brain.md).
  Use `"identity"` to keep the atlas polygons' raw coordinates. Per-view
  zoom is set through
  [`position_brain()`](https://ggsegverse.github.io/ggseg/reference/position_brain.md)'s
  `zoom`.

- show.legend:

  Logical. Should this layer be included in the legends?

- inherit.aes:

  Logical. If `FALSE`, overrides the default aesthetics rather than
  combining with them.

- ...:

  Additional arguments passed to
  [`ggplot2::geom_polygon()`](https://ggplot2.tidyverse.org/reference/geom_polygon.html).

## Value

A list of ggplot2 layer and coord objects.

## GeomBrainSf ggproto

`GeomBrainSf` is the
[ggplot2::Geom](https://ggplot2.tidyverse.org/reference/Geom.html)
backing the deprecated `geom_brain_sf()` sf path. It renders atlas
geometry via
[`sf::st_as_grob()`](https://r-spatial.github.io/sf/reference/st_as_grob.html)
and requires
[coord_sf()](https://ggplot2.tidyverse.org/reference/ggsf.html). Up to
ggseg 2.2.1 this object was the exported `GeomBrain`; `GeomBrain` is now
the polygon geom that backs the default
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md),
so extension code doing `ggplot2::layer(geom = GeomBrain)` against the
sf path must switch to `GeomBrainSf`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Deprecated: prefer geom_brain(). Shown for reference only.
library(ggplot2)
ggplot() +
  geom_brain_sf(atlas = dk())
} # }
```
