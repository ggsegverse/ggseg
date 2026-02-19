# Join user data with a brain atlas

Performs a full join between user data and a brain atlas. Grouped data
is handled automatically, producing one complete atlas per group.

## Usage

``` r
brain_join(data, atlas, by = NULL)
```

## Arguments

- data:

  A data.frame with a column matching an atlas column (typically
  \`"region"\`). Can be grouped with \[dplyr::group_by()\].

- atlas:

  A \`ggseg_atlas\` object or data.frame containing atlas data.

- by:

  Character vector of column names to join by. If \`NULL\` (default),
  columns are detected automatically.

## Value

An \`sf\` object if the atlas contains geometry, otherwise a tibble.

## Examples

``` r
someData <- data.frame(
  region = c(
    "transverse temporal", "insula",
    "precentral", "superior parietal"
  ),
  p = sample(seq(0, .5, .001), 4),
  stringsAsFactors = FALSE
)

brain_join(someData, dk())
#> Merging atlas and data by region.
#> Simple feature collection with 191 features and 9 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 84.2049 ymin: 0 xmax: 5359.689 ymax: 429.9372
#> CRS:           NA
#> First 10 features:
#>                         label     view  hemi                            region
#> 1                  lh_unknown   medial  left                              <NA>
#> 2                  lh_unknown  lateral  left                              <NA>
#> 3                  lh_unknown inferior  left                              <NA>
#> 4                  rh_unknown  lateral right                              <NA>
#> 5                  rh_unknown inferior right                              <NA>
#> 6                  rh_unknown   medial right                              <NA>
#> 7                 lh_bankssts inferior  left banks of superior temporal sulcus
#> 8                 lh_bankssts  lateral  left banks of superior temporal sulcus
#> 9                 lh_bankssts superior  left banks of superior temporal sulcus
#> 10 lh_caudalanteriorcingulate   medial  left         caudal anterior cingulate
#>         lobe atlas     type  colour  p                       geometry
#> 1       <NA>    dk cortical    <NA> NA MULTIPOLYGON (((1782.84 18....
#> 2       <NA>    dk cortical    <NA> NA MULTIPOLYGON (((926.5936 60...
#> 3       <NA>    dk cortical    <NA> NA MULTIPOLYGON (((367.1256 13...
#> 4       <NA>    dk cortical    <NA> NA MULTIPOLYGON (((3849.766 60...
#> 5       <NA>    dk cortical    <NA> NA MULTIPOLYGON (((3190.519 5....
#> 6       <NA>    dk cortical    <NA> NA MULTIPOLYGON (((4318.844 20...
#> 7   temporal    dk cortical #196428 NA MULTIPOLYGON (((534.4782 21...
#> 8   temporal    dk cortical #196428 NA MULTIPOLYGON (((1121.478 12...
#> 9   temporal    dk cortical #196428 NA MULTIPOLYGON (((2448.464 20...
#> 10 cingulate    dk cortical #7D64A0 NA MULTIPOLYGON (((1921.971 20...
brain_join(someData, dk(), "region")
#> Simple feature collection with 191 features and 9 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 84.2049 ymin: 0 xmax: 5359.689 ymax: 429.9372
#> CRS:           NA
#> First 10 features:
#>                         label     view  hemi                            region
#> 1                  lh_unknown   medial  left                              <NA>
#> 2                  lh_unknown  lateral  left                              <NA>
#> 3                  lh_unknown inferior  left                              <NA>
#> 4                  rh_unknown  lateral right                              <NA>
#> 5                  rh_unknown inferior right                              <NA>
#> 6                  rh_unknown   medial right                              <NA>
#> 7                 lh_bankssts inferior  left banks of superior temporal sulcus
#> 8                 lh_bankssts  lateral  left banks of superior temporal sulcus
#> 9                 lh_bankssts superior  left banks of superior temporal sulcus
#> 10 lh_caudalanteriorcingulate   medial  left         caudal anterior cingulate
#>         lobe atlas     type  colour  p                       geometry
#> 1       <NA>    dk cortical    <NA> NA MULTIPOLYGON (((1782.84 18....
#> 2       <NA>    dk cortical    <NA> NA MULTIPOLYGON (((926.5936 60...
#> 3       <NA>    dk cortical    <NA> NA MULTIPOLYGON (((367.1256 13...
#> 4       <NA>    dk cortical    <NA> NA MULTIPOLYGON (((3849.766 60...
#> 5       <NA>    dk cortical    <NA> NA MULTIPOLYGON (((3190.519 5....
#> 6       <NA>    dk cortical    <NA> NA MULTIPOLYGON (((4318.844 20...
#> 7   temporal    dk cortical #196428 NA MULTIPOLYGON (((534.4782 21...
#> 8   temporal    dk cortical #196428 NA MULTIPOLYGON (((1121.478 12...
#> 9   temporal    dk cortical #196428 NA MULTIPOLYGON (((2448.464 20...
#> 10 cingulate    dk cortical #7D64A0 NA MULTIPOLYGON (((1921.971 20...
```
