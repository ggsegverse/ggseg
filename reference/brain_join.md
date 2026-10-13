# Join user data with a brain atlas

Matches your data to a brain atlas by a shared column (usually
`region`), keeping every atlas region whether or not you have a value
for it. Grouped data (via
[`dplyr::group_by()`](https://dplyr.tidyverse.org/reference/group_by.html))
gives one complete atlas per group. You rarely need this directly –
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
joins your data for you; reach for `brain_join()` when you want the
joined sf object yourself.

## Usage

``` r
brain_join(data, atlas, by = NULL)
```

## Arguments

- data:

  A data.frame with a column matching an atlas column (typically
  `"region"`). Can be grouped with
  [`dplyr::group_by()`](https://dplyr.tidyverse.org/reference/group_by.html).

- atlas:

  A `ggseg_atlas` object or data.frame containing atlas data.

- by:

  Character vector of column names to join by. If `NULL` (default),
  columns are detected automatically.

## Value

An `sf` object if the atlas contains geometry, otherwise a tibble.

## Examples

``` r
someData <- data.frame(
  region = sort(unique(ggseg.formats::atlas_regions(dk())))[1:4],
  p = sample(seq(0, .5, .001), 4),
  stringsAsFactors = FALSE
)

brain_join(someData, dk())
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
brain_join(someData, dk(), "region")
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
