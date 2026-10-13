# Stat-first constructor for a brain atlas layer

The stat-first spelling of
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md).
Both build the same layer – a
[StatBrain](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
that aggregates and joins your data onto the atlas geometry, drawn by
`geom`. Reach for `stat_brain()` when you want to pair
[StatBrain](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
with a different geom (e.g. a custom polygon geom); otherwise
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
is the friendlier entry point.

## Usage

``` r
stat_brain(
  mapping = aes(),
  data = NULL,
  atlas,
  hemi = NULL,
  view = NULL,
  position = position_brain(),
  context = TRUE,
  fun = mean,
  geom = GeomBrain,
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

- context:

  Keep the rest of the brain as a soft grey backdrop (`TRUE`, the
  default), or show only the regions you're plotting (`FALSE`).

- fun:

  Function used to combine multiple `data` rows that map to the same
  atlas region, applied within each facet panel. Defaults to
  [`mean()`](https://rdrr.io/r/base/mean.html). Any function reducing a
  vector to a single value works (e.g.
  [`median()`](https://rdrr.io/r/stats/median.html),
  [`max()`](https://rdrr.io/r/base/Extremes.html)). It applies to
  numeric columns only; non-numeric ones take the first value of the
  group. Up to ggseg 2.2.1 duplicate rows overplotted, so the last one
  won — `fun = dplyr::last` reproduces that.

- geom:

  The geometric object used to render the atlas. Defaults to
  [GeomBrain](https://ggsegverse.github.io/ggseg/reference/ggbrain.md).

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

## See also

[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)

## Examples

``` r
library(ggplot2)

# Equivalent to geom_brain(atlas = dk())
ggplot() +
  stat_brain(atlas = dk(), show.legend = FALSE)
```
