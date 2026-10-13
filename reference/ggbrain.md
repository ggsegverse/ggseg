# Plot brain atlas regions

Colour brain regions by your own values. Give `geom_brain()` an atlas
like
[`dk()`](https://ggsegverse.github.io/ggseg.formats/reference/dk.html)
and a data frame, and it matches your values to the right regions and
lays out the brain views for you. No data? It just draws the atlas.

## Usage

``` r
geom_brain(
  mapping = aes(),
  data = NULL,
  atlas,
  hemi = NULL,
  view = NULL,
  position = position_brain(),
  context = TRUE,
  fun = mean,
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

## Details

Map neither `fill` nor `colour` and `geom_brain()` colours the atlas by
its own palette for you, by mapping `fill` to `label` – the key atlas
palettes are built on, and the ecosystem's canonical matching key. Map
either one and yours wins; your `data` then drives the colours and
regions you supply no value for stay grey.

Match your `data` to the atlas on `label` (hemisphere-qualified, unique
per atlas row) or on `region` (which repeats across hemispheres).

Regions are drawn in the order they appear in your `data`, so when
outlines overlap (e.g. mapping `colour` to a threshold with a wide
`linewidth`) the later rows draw on top. Reorder your data with
[`dplyr::arrange()`](https://dplyr.tidyverse.org/reference/arrange.html)
to control the layering; regions you supply no value for stay underneath
in atlas order.

Faceting works without any
[`dplyr::group_by()`](https://dplyr.tidyverse.org/reference/group_by.html):
the atlas geometry is drawn by StatBrain, which ggplot2 recomputes per
panel, so the complete brain appears in every facet. If your `data` has
several rows for the same region (e.g. one per subject), they are
combined with `fun` (mean by default) before drawing.

## GeomBrain ggproto

`GeomBrain` is the
[ggplot2::Geom](https://ggplot2.tidyverse.org/reference/Geom.html)
ggproto that renders brain atlas polygons. It subclasses
[ggplot2::GeomPolygon](https://ggplot2.tidyverse.org/reference/Geom.html)
and supplies the brain defaults through `default_aes` – outline `colour`
(grey35), `linewidth` (0.2), and `fill` (grey) – which apply when the
user has not mapped those aesthetics but yield to a mapping when present
(ggsegverse/ggseg#160). The grey default fill is what an atlas with no
palette of its own falls back to; otherwise `geom_brain()` maps `fill`
to `label` and applies the palette. Used internally by `geom_brain()`;
not typically called directly.

## StatBrain ggproto

`StatBrain` is the
[ggplot2::Stat](https://ggplot2.tidyverse.org/reference/Stat.html) that
powers `geom_brain()` and
[`stat_brain()`](https://ggsegverse.github.io/ggseg/reference/stat_brain.md).
Its `compute_panel()` receives one facet panel's user data, aggregates
the mapped values per atlas region with `fun`, and joins them onto the
full atlas geometry – so every region renders in every panel whether or
not you supplied a value for it. You rarely reference it directly; use
it via `geom_brain(..., stat = StatBrain)` or
[`stat_brain()`](https://ggsegverse.github.io/ggseg/reference/stat_brain.md)
when building a custom layer.

## See also

[`stat_brain()`](https://ggsegverse.github.io/ggseg/reference/stat_brain.md)
for the stat-first spelling.

## Examples

``` r
library(ggplot2)

ggplot() +
  geom_brain(atlas = dk(), show.legend = FALSE)
```
