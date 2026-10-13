# Working with geom_sf directly

[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
handles data joining and positioning automatically, which covers most
use cases. But because it owns the data pipeline, you can’t easily layer
other sf geoms on top – things like
[`geom_sf_label()`](https://ggplot2.tidyverse.org/reference/ggsf.html)
or [`geom_sf_text()`](https://ggplot2.tidyverse.org/reference/ggsf.html)
need direct access to the sf data.

This vignette shows how to work with brain atlases as plain sf objects,
giving you full control at the cost of a few extra lines.

This is the one workflow that needs the **sf** package, which ggseg now
treats as an optional dependency. Install it with
`install.packages("sf")` if you don’t already have it. Everywhere else,
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
plots the same atlases without sf.

``` r

library(ggseg)
library(ggplot2)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
```

## When you’d want this

Use the sf workflow when you need to:

- Add region labels with
  [`geom_sf_label()`](https://ggplot2.tidyverse.org/reference/ggsf.html)
  or
  [`geom_sf_text()`](https://ggplot2.tidyverse.org/reference/ggsf.html)
- Use `ggrepel::geom_label_repel()` for non-overlapping labels
- Layer other sf geoms on the brain
- Have full control over the data before it reaches ggplot

For everything else,
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
is simpler.

## Getting atlas data as sf

A brain atlas stores its geometry in the `data` slot. Reach it through
the accessor rather than by list indexing:

``` r

ggseg.formats::atlas_geom(dk())
#> 
#> ── brain_polygons ──
#> 
#> Labels: 72
#> Views: inferior, lateral, medial, superior
#> Total points: 5391
#>                      label       geometry
#> 1               lh_unknown <df [113 x 5]>
#> 2               rh_unknown <df [111 x 5]>
#> 3            lh_precentral <df [150 x 5]>
#> 4  lh_lateralorbitofrontal  <df [89 x 5]>
#> 5      lh_superiortemporal <df [178 x 5]>
#> 6      lh_lateraloccipital <df [114 x 5]>
#> 7  lh_rostralmiddlefrontal <df [117 x 5]>
#> 8                lh_insula <df [132 x 5]>
#> 9       lh_parsopercularis  <df [69 x 5]>
#> 10        lh_supramarginal <df [117 x 5]>
#> ... with 62 more rows
```

The `geometry` column holds the polygons. This is a standard sf object,
so any sf-compatible tool works with it.

## Joining your data

Use
[`brain_join()`](https://ggsegverse.github.io/ggseg/reference/brain_join.md)
to merge your data with the atlas. It preserves the sf geometry and
handles column detection:

``` r

some_data <- tibble(
  region = sort(unique(ggseg.formats::atlas_regions(dk())))[1:4],
  p = sample(seq(0, 0.5, 0.001), 4)
)

some_data |>
  brain_join(dk())
#> Merging atlas and data by region.
#> Simple feature collection with 185 features and 10 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 0.899055 ymin: 0.0853615 xmax: 1938.834 ymax: 146.1192
#> CRS:           NA
#> First 10 features:
#>                         label     view  hemi                  region
#> 1                  lh_unknown inferior  left                    <NA>
#> 2                  lh_unknown  lateral  left                    <NA>
#> 3                  lh_unknown   medial  left                    <NA>
#> 4                  rh_unknown inferior right                    <NA>
#> 5                  rh_unknown  lateral right                    <NA>
#> 6                  rh_unknown   medial right                    <NA>
#> 7                 lh_bankssts inferior  left                bankssts
#> 8                 lh_bankssts  lateral  left                bankssts
#> 9                 lh_bankssts superior  left                bankssts
#> 10 lh_caudalanteriorcingulate   medial  left caudalanteriorcingulate
#>                              display      lobe atlas     type  colour     p
#> 1                               <NA>      <NA>    dk cortical    <NA>    NA
#> 2                               <NA>      <NA>    dk cortical    <NA>    NA
#> 3                               <NA>      <NA>    dk cortical    <NA>    NA
#> 4                               <NA>      <NA>    dk cortical    <NA>    NA
#> 5                               <NA>      <NA>    dk cortical    <NA>    NA
#> 6                               <NA>      <NA>    dk cortical    <NA>    NA
#> 7  banks of superior temporal sulcus  temporal    dk cortical #196428 0.172
#> 8  banks of superior temporal sulcus  temporal    dk cortical #196428 0.172
#> 9  banks of superior temporal sulcus  temporal    dk cortical #196428 0.172
#> 10         caudal anterior cingulate cingulate    dk cortical #7D64A0 0.406
#>                          geometry
#> 1  MULTIPOLYGON (((59.87309 38...
#> 2  MULTIPOLYGON (((309.1881 20...
#> 3  MULTIPOLYGON (((561.9354 46...
#> 4  MULTIPOLYGON (((1056.938 47...
#> 5  MULTIPOLYGON (((1376.635 14...
#> 6  MULTIPOLYGON (((1539.551 20...
#> 7  MULTIPOLYGON (((126.4784 10...
#> 8  MULTIPOLYGON (((373.1208 44...
#> 9  MULTIPOLYGON (((888.6798 41...
#> 10 MULTIPOLYGON (((632.9766 10...
```

The result is a standard sf object you can pass to
[`geom_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html).

## Plotting with geom_sf

``` r

some_data |>
  brain_join(dk()) |>
  ggplot() +
  geom_sf(aes(fill = p))
#> Merging atlas and data by region.
```

![Brain plot using geom_sf after
brain_join.](geom-sf_files/figure-html/fig-geom-sf-1.png)

Brain plot using geom_sf after brain_join.

## Repositioning views

With
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md),
you’d use
[`position_brain()`](https://ggsegverse.github.io/ggseg/reference/position_brain.md).
In the sf workflow, use
[`reposition_brain()`](https://ggsegverse.github.io/ggseg/reference/reposition_brain.md)
instead – it transforms the geometry directly:

``` r

some_data |>
  brain_join(dk()) |>
  reposition_brain(hemi ~ view) |>
  ggplot() +
  geom_sf(aes(fill = p))
#> Merging atlas and data by region.
```

![Repositioned brain views using reposition_brain() with
geom_sf.](geom-sf_files/figure-html/fig-reposition-1.png)

Repositioned brain views using reposition_brain() with geom_sf.

Same formula syntax, same results.

## Adding labels

This is the main reason to use the sf workflow. Once you have
repositioned sf data, you can layer any sf geom:

``` r

some_data |>
  brain_join(dk()) |>
  reposition_brain(hemi ~ view) |>
  ggplot(aes(fill = p)) +
  geom_sf(show.legend = FALSE) +
  geom_sf_label(
    aes(label = ifelse(!is.na(p), region, NA)),
    alpha = 0.8,
    show.legend = FALSE
  )
#> Merging atlas and data by region.
#> Warning: Removed 171 rows containing missing values or values outside the scale range
#> (`geom_label()`).
```

![Brain regions with text labels overlaid using
geom_sf_label.](geom-sf_files/figure-html/fig-labels-1.png)

Brain regions with text labels overlaid using geom_sf_label.

For crowded plots, `ggrepel::geom_label_repel()` avoids overlapping
labels.

## Faceting with grouped data

In the sf workflow, faceting requires
[`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html)
before
[`brain_join()`](https://ggsegverse.github.io/ggseg/reference/brain_join.md).
The grouping tells the join to replicate the atlas for each group:

``` r

some_data <- tibble(
  region = rep(sort(unique(ggseg.formats::atlas_regions(dk())))[1:4], 2),
  p = sample(seq(0, 0.5, 0.001), 8),
  group = c(rep("A", 4), rep("B", 4))
)

some_data |>
  group_by(group) |>
  brain_join(dk()) |>
  reposition_brain(hemi ~ view) |>
  ggplot(aes(fill = p)) +
  geom_sf(show.legend = FALSE) +
  facet_wrap(~group)
#> Merging atlas and data by region.
```

![Faceted brain plots using the geom_sf workflow with grouped
data.](geom-sf_files/figure-html/fig-facet-grouped-1.png)

Faceted brain plots using the geom_sf workflow with grouped data.

This step is only needed in the sf workflow.
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
handles atlas replication automatically (see
[`vignette("external-data")`](https://ggsegverse.github.io/ggseg/articles/external-data.md)).
