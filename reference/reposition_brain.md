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
#> Simple feature collection with 157 features and 9 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -12.15 ymin: -12.15 xmax: 1227.15 ymax: 592.75
#> CRS:           NA
#> First 10 features:
#>                     label    view hemi            region
#> 1                  cortex axial_3 <NA>              <NA>
#> 11             Brain-Stem axial_3 <NA>        brain stem
#> 28       CC_Mid_Posterior axial_3 <NA>  cc mid posterior
#> 36    Left-Accumbens-area axial_3 left    accumbens area
#> 40          Left-Amygdala axial_3 left          amygdala
#> 48           Left-Caudate axial_3 left           caudate
#> 54 Left-Cerebellum-Cortex axial_3 left cerebellum cortex
#> 58       Left-Hippocampus axial_3 left       hippocampus
#> 60          Left-Pallidum axial_3 left          pallidum
#> 71           Left-Putamen axial_3 left           putamen
#>                          display       structure atlas        type  colour
#> 1                           <NA>            <NA>  aseg subcortical    <NA>
#> 11                    brain stem       brainstem  aseg subcortical #779FB0
#> 28 corpus callosum mid-posterior corpus callosum  aseg subcortical #000070
#> 36                     accumbens   basal ganglia  aseg subcortical #FFA500
#> 40                      amygdala          limbic  aseg subcortical #67FFFF
#> 48                       caudate   basal ganglia  aseg subcortical #7ABADC
#> 54             cerebellum cortex      cerebellum  aseg subcortical #E69422
#> 58                   hippocampus          limbic  aseg subcortical #DCD814
#> 60                      pallidum   basal ganglia  aseg subcortical #0C30FF
#> 71                       putamen   basal ganglia  aseg subcortical #EC0DB0
#>                          geometry
#> 1  MULTIPOLYGON (((28.21102 11...
#> 11 MULTIPOLYGON (((108.1522 12...
#> 28 MULTIPOLYGON (((132 116.647...
#> 36 MULTIPOLYGON (((112.0139 17...
#> 40 MULTIPOLYGON (((82.12316 15...
#> 48 MULTIPOLYGON (((163.0132 13...
#> 54 MULTIPOLYGON (((76.07872 55...
#> 58 MULTIPOLYGON (((74.15219 11...
#> 60 MULTIPOLYGON (((169.0135 17...
#> 71 MULTIPOLYGON (((98.01321 17...
reposition_brain(aseg(), views = c("sagittal", "axial_3"))
#> Simple feature collection with 40 features and 9 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -5.67 ymin: -5.67 xmax: 572.67 ymax: 269.67
#> CRS:           NA
#> First 10 features:
#>                     label     view hemi            region
#> 7                 cortex_ sagittal <NA>              <NA>
#> 12             Brain-Stem sagittal <NA>        brain stem
#> 17            CC_Anterior sagittal <NA>       cc anterior
#> 22             CC_Central sagittal <NA>        cc central
#> 26        CC_Mid_Anterior sagittal <NA>   cc mid anterior
#> 30       CC_Mid_Posterior sagittal <NA>  cc mid posterior
#> 34           CC_Posterior sagittal <NA>      cc posterior
#> 53 Left-Cerebellum-Cortex sagittal left cerebellum cortex
#> 77          Left-Thalamus sagittal left          thalamus
#> 83         Left-VentralDC sagittal left         ventraldc
#>                          display       structure atlas        type  colour
#> 7                           <NA>            <NA>  aseg subcortical    <NA>
#> 12                    brain stem       brainstem  aseg subcortical #779FB0
#> 17      corpus callosum anterior corpus callosum  aseg subcortical #0000FF
#> 22       corpus callosum central corpus callosum  aseg subcortical #0000A0
#> 26  corpus callosum mid-anterior corpus callosum  aseg subcortical #0000D0
#> 30 corpus callosum mid-posterior corpus callosum  aseg subcortical #000070
#> 34     corpus callosum posterior corpus callosum  aseg subcortical #000040
#> 53             cerebellum cortex      cerebellum  aseg subcortical #E69422
#> 77                      thalamus   basal ganglia  aseg subcortical #00760E
#> 83          ventral diencephalon    diencephalon  aseg subcortical #A52A2A
#>                          geometry
#> 7  MULTIPOLYGON (((163.9007 11...
#> 12 MULTIPOLYGON (((86.01362 39...
#> 17 MULTIPOLYGON (((184.0132 13...
#> 22 MULTIPOLYGON (((144.0822 16...
#> 26 MULTIPOLYGON (((167.1522 16...
#> 30 MULTIPOLYGON (((119.0132 16...
#> 34 MULTIPOLYGON (((92.01345 14...
#> 53 MULTIPOLYGON (((38.01395 87...
#> 77 MULTIPOLYGON (((145 130.352...
#> 83 MULTIPOLYGON (((144.0132 10...
# }
```
