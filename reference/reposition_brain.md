# Reposition brain slices

Repositions pre-joined sf atlas data (i.e. data and atlas already joined
to a single sf data frame) for control over final plot layout. For even
more detailed control, convert the "hemi" and "view" columns into
factors ordered by wanted order of appearance.

## Usage

``` r
reposition_brain(
  data,
  position = "horizontal",
  nrow = NULL,
  ncol = NULL,
  views = NULL
)
```

## Arguments

- data:

  sf-data.frame of joined brain atlas and data

- position:

  Position formula for slices. For cortical atlases, use formulas like
  `hemi ~ view`. For subcortical/tract atlases, use "horizontal",
  "vertical", or `type ~ .` for type-based layout.

- nrow:

  Number of rows for grid layout; cannot be combined with a `position`
  formula.

- ncol:

  Number of columns for grid layout; cannot be combined with a
  `position` formula.

- views:

  Character vector specifying view order. Names the data does not have
  are dropped with a warning.

## Value

sf-data.frame with re-positioned slices

## Details

This is the sf layout helper. It requires the `sf` package (an optional
dependency); for the sf-free default, build a layout with
[`position_brain()`](https://ggsegverse.github.io/ggseg/reference/position_brain.md)
and pass it to
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md).

## Examples

``` r
reposition_brain(dk(), hemi ~ view)
#> Simple feature collection with 185 features and 9 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -9.87923 ymin: -9.87923 xmax: 997.8023 ymax: 330.8408
#> CRS:           NA
#> # A tibble: 185 × 10
#>    label  view  hemi  region display lobe                   geometry atlas type 
#>  * <chr>  <chr> <chr> <chr>  <chr>   <chr>            <MULTIPOLYGON> <chr> <chr>
#>  1 lh_un… infe… left  NA     NA      NA    (((59.99261 37.94643, 59… dk    cort…
#>  2 lh_ba… infe… left  banks… banks … temp… (((126.5979 103.297, 126… dk    cort…
#>  3 lh_en… infe… left  entor… entorh… temp… (((79.70127 56.104, 80.4… dk    cort…
#>  4 lh_fr… infe… left  front… fronta… fron… (((1.03798 49.56677, 3.0… dk    cort…
#>  5 lh_fu… infe… left  fusif… fusifo… temp… (((83.15177 62.54241, 86… dk    cort…
#>  6 lh_in… infe… left  infer… inferi… pari… (((151.7233 108.3418, 15… dk    cort…
#>  7 lh_in… infe… left  infer… inferi… temp… (((80.94362 71.36742, 83… dk    cort…
#>  8 lh_in… infe… left  insula insula  insu… (((53.29654 77.0285, 56.… dk    cort…
#>  9 lh_is… infe… left  isthm… isthmu… cing… (((145.3998 46.10819, 14… dk    cort…
#> 10 lh_la… infe… left  later… latera… occi… (((176.5752 91.63246, 17… dk    cort…
#> # ℹ 175 more rows
#> # ℹ 1 more variable: colour <chr>
reposition_brain(dk(), view ~ hemi)
#> Simple feature collection with 185 features and 9 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -6.514223 ymin: -6.514223 xmax: 478.9786 ymax: 657.9366
#> CRS:           NA
#> # A tibble: 185 × 10
#>    label  view  hemi  region display lobe                   geometry atlas type 
#>  * <chr>  <chr> <chr> <chr>  <chr>   <chr>            <MULTIPOLYGON> <chr> <chr>
#>  1 lh_un… infe… left  NA     NA      NA    (((59.99261 37.94643, 59… dk    cort…
#>  2 lh_ba… infe… left  banks… banks … temp… (((126.5979 103.297, 126… dk    cort…
#>  3 lh_en… infe… left  entor… entorh… temp… (((79.70127 56.104, 80.4… dk    cort…
#>  4 lh_fr… infe… left  front… fronta… fron… (((1.03798 49.56677, 3.0… dk    cort…
#>  5 lh_fu… infe… left  fusif… fusifo… temp… (((83.15177 62.54241, 86… dk    cort…
#>  6 lh_in… infe… left  infer… inferi… pari… (((151.7233 108.3418, 15… dk    cort…
#>  7 lh_in… infe… left  infer… inferi… temp… (((80.94362 71.36742, 83… dk    cort…
#>  8 lh_in… infe… left  insula insula  insu… (((53.29654 77.0285, 56.… dk    cort…
#>  9 lh_is… infe… left  isthm… isthmu… cing… (((145.3998 46.10819, 14… dk    cort…
#> 10 lh_la… infe… left  later… latera… occi… (((176.5752 91.63246, 17… dk    cort…
#> # ℹ 175 more rows
#> # ℹ 1 more variable: colour <chr>
reposition_brain(dk(), hemi + view ~ .)
#> Simple feature collection with 185 features and 9 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -13.51702 ymin: -13.51702 xmax: 228.3476 ymax: 1365.219
#> CRS:           NA
#> # A tibble: 185 × 10
#>    label  view  hemi  region display lobe                   geometry atlas type 
#>  * <chr>  <chr> <chr> <chr>  <chr>   <chr>            <MULTIPOLYGON> <chr> <chr>
#>  1 lh_un… infe… left  NA     NA      NA    (((59.99261 37.94643, 59… dk    cort…
#>  2 lh_ba… infe… left  banks… banks … temp… (((126.5979 103.297, 126… dk    cort…
#>  3 lh_en… infe… left  entor… entorh… temp… (((79.70127 56.104, 80.4… dk    cort…
#>  4 lh_fr… infe… left  front… fronta… fron… (((1.03798 49.56677, 3.0… dk    cort…
#>  5 lh_fu… infe… left  fusif… fusifo… temp… (((83.15177 62.54241, 86… dk    cort…
#>  6 lh_in… infe… left  infer… inferi… pari… (((151.7233 108.3418, 15… dk    cort…
#>  7 lh_in… infe… left  infer… inferi… temp… (((80.94362 71.36742, 83… dk    cort…
#>  8 lh_in… infe… left  insula insula  insu… (((53.29654 77.0285, 56.… dk    cort…
#>  9 lh_is… infe… left  isthm… isthmu… cing… (((145.3998 46.10819, 14… dk    cort…
#> 10 lh_la… infe… left  later… latera… occi… (((176.5752 91.63246, 17… dk    cort…
#> # ℹ 175 more rows
#> # ℹ 1 more variable: colour <chr>
reposition_brain(dk(), . ~ hemi + view)
#> Simple feature collection with 185 features and 9 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -20.18904 ymin: -20.18904 xmax: 2039.093 ymax: 166.0807
#> CRS:           NA
#> # A tibble: 185 × 10
#>    label  view  hemi  region display lobe                   geometry atlas type 
#>  * <chr>  <chr> <chr> <chr>  <chr>   <chr>            <MULTIPOLYGON> <chr> <chr>
#>  1 lh_un… infe… left  NA     NA      NA    (((59.99261 37.94643, 59… dk    cort…
#>  2 lh_ba… infe… left  banks… banks … temp… (((126.5979 103.297, 126… dk    cort…
#>  3 lh_en… infe… left  entor… entorh… temp… (((79.70127 56.104, 80.4… dk    cort…
#>  4 lh_fr… infe… left  front… fronta… fron… (((1.03798 49.56677, 3.0… dk    cort…
#>  5 lh_fu… infe… left  fusif… fusifo… temp… (((83.15177 62.54241, 86… dk    cort…
#>  6 lh_in… infe… left  infer… inferi… pari… (((151.7233 108.3418, 15… dk    cort…
#>  7 lh_in… infe… left  infer… inferi… temp… (((80.94362 71.36742, 83… dk    cort…
#>  8 lh_in… infe… left  insula insula  insu… (((53.29654 77.0285, 56.… dk    cort…
#>  9 lh_is… infe… left  isthm… isthmu… cing… (((145.3998 46.10819, 14… dk    cort…
#> 10 lh_la… infe… left  later… latera… occi… (((176.5752 91.63246, 17… dk    cort…
#> # ℹ 175 more rows
#> # ℹ 1 more variable: colour <chr>

# \donttest{
reposition_brain(aseg(), nrow = 2)
#> Simple feature collection with 78 features and 9 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -3.606703 ymin: -3.606703 xmax: 359.6442 ymax: 364.277
#> CRS:           NA
#> First 10 features:
#>                  label    view    hemi           region
#> 1               cortex axial_2    <NA>             <NA>
#> 4           Brain-Stem axial_2 midline       brain stem
#> 7          CC_Anterior axial_2 midline      cc anterior
#> 9           CC_Central axial_2 midline       cc central
#> 12     CC_Mid_Anterior axial_2 midline  cc mid anterior
#> 15    CC_Mid_Posterior axial_2 midline cc mid posterior
#> 18        CC_Posterior axial_2 midline     cc posterior
#> 21 Left-Accumbens-area axial_2    left   accumbens area
#> 24       Left-Amygdala axial_2    left         amygdala
#> 27        Left-Caudate axial_2    left          caudate
#>                          display       structure atlas        type  colour
#> 1                           <NA>            <NA>  aseg subcortical    <NA>
#> 4                     brain stem       brainstem  aseg subcortical #779FB0
#> 7       corpus callosum anterior corpus callosum  aseg subcortical #0000FF
#> 9        corpus callosum central corpus callosum  aseg subcortical #0000A0
#> 12  corpus callosum mid-anterior corpus callosum  aseg subcortical #0000D0
#> 15 corpus callosum mid-posterior corpus callosum  aseg subcortical #000070
#> 18     corpus callosum posterior corpus callosum  aseg subcortical #000040
#> 21                     accumbens   basal ganglia  aseg subcortical #FFA500
#> 24                      amygdala          limbic  aseg subcortical #67FFFF
#> 27                       caudate   basal ganglia  aseg subcortical #7ABADC
#>                          geometry
#> 1  MULTIPOLYGON (((55.09375 16...
#> 4  MULTIPOLYGON (((76.54613 63...
#> 7  MULTIPOLYGON (((85.28125 13...
#> 9  MULTIPOLYGON (((83.53125 99...
#> 12 MULTIPOLYGON (((84.09375 10...
#> 15 MULTIPOLYGON (((86.40625 92...
#> 18 MULTIPOLYGON (((89.53125 60...
#> 21 MULTIPOLYGON (((74.71875 12...
#> 24 MULTIPOLYGON (((58.09375 88...
#> 27 MULTIPOLYGON (((77 103.9062...
reposition_brain(aseg(), views = c("sagittal_left", "axial_2"))
#> Simple feature collection with 51 features and 9 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -3.630688 ymin: -3.630688 xmax: 366.6994 ymax: 172.5682
#> CRS:           NA
#> First 10 features:
#>                  label          view    hemi           region
#> 3               cortex sagittal_left    <NA>             <NA>
#> 6           Brain-Stem sagittal_left midline       brain stem
#> 8          CC_Anterior sagittal_left midline      cc anterior
#> 11          CC_Central sagittal_left midline       cc central
#> 14     CC_Mid_Anterior sagittal_left midline  cc mid anterior
#> 17    CC_Mid_Posterior sagittal_left midline cc mid posterior
#> 20        CC_Posterior sagittal_left midline     cc posterior
#> 23 Left-Accumbens-area sagittal_left    left   accumbens area
#> 26       Left-Amygdala sagittal_left    left         amygdala
#> 29        Left-Caudate sagittal_left    left          caudate
#>                          display       structure atlas        type  colour
#> 3                           <NA>            <NA>  aseg subcortical    <NA>
#> 6                     brain stem       brainstem  aseg subcortical #779FB0
#> 8       corpus callosum anterior corpus callosum  aseg subcortical #0000FF
#> 11       corpus callosum central corpus callosum  aseg subcortical #0000A0
#> 14  corpus callosum mid-anterior corpus callosum  aseg subcortical #0000D0
#> 17 corpus callosum mid-posterior corpus callosum  aseg subcortical #000070
#> 20     corpus callosum posterior corpus callosum  aseg subcortical #000040
#> 23                     accumbens   basal ganglia  aseg subcortical #FFA500
#> 26                      amygdala          limbic  aseg subcortical #67FFFF
#> 29                       caudate   basal ganglia  aseg subcortical #7ABADC
#>                          geometry
#> 3  MULTIPOLYGON (((75.625 49.9...
#> 6  MULTIPOLYGON (((102.4375 79...
#> 8  MULTIPOLYGON (((49.4375 92....
#> 11 MULTIPOLYGON (((78 111.3828...
#> 14 MULTIPOLYGON (((62.125 108....
#> 17 MULTIPOLYGON (((81.76562 10...
#> 20 MULTIPOLYGON (((106.3333 88...
#> 23 MULTIPOLYGON (((65 66.94531...
#> 26 MULTIPOLYGON (((80.5625 65....
#> 29 MULTIPOLYGON (((43 74.94531...
# }
```
