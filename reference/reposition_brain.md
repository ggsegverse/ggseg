# Reposition brain slices

Function for repositioning pre-joined atlas data (i.e. data and atlas
already joined to a single data frame). This makes it possible for users
to reposition the geometry data for the atlas for control over final
plot layout. For even more detailed control over the positioning, the
"hemi" and "view" columns should be converted into factors and ordered
by wanted order of appearance.

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
  \`hemi ~ view\`. For subcortical/tract atlases, use "horizontal",
  "vertical", or \`type ~ .\` for type-based layout.

- nrow:

  Number of rows for grid layout (subcortical/tract only)

- ncol:

  Number of columns for grid layout (subcortical/tract only)

- views:

  Character vector specifying view order (subcortical/tract only)

## Value

sf-data.frame with re-positioned slices

## Examples

``` r
reposition_brain(dk(), hemi ~ view)
#> Simple feature collection with 191 features and 8 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -29.07095 ymin: -29.07095 xmax: 2936.166 ymax: 974.9328
#> CRS:           NA
#> # A tibble: 191 × 9
#>    label   view  hemi  region lobe                   geometry atlas type  colour
#>  * <chr>   <chr> <chr> <chr>  <chr>            <MULTIPOLYGON> <chr> <chr> <chr> 
#>  1 lh_unk… infe… left  NA     NA    (((283.0321 93.76352, 43… dk    cort… NA    
#>  2 lh_ban… infe… left  banks… temp… (((450.3846 295.7177, 47… dk    cort… #1964…
#>  3 lh_cau… infe… left  cauda… fron… (((188.6943 302.0361, 18… dk    cort… #6419…
#>  4 lh_cor… infe… left  corpu… whit… (((402.2002 121.1967, 40… dk    cort… #7846…
#>  5 lh_ent… infe… left  entor… temp… (((274.1602 156.9255, 31… dk    cort… #DC14…
#>  6 lh_fro… infe… left  front… fron… (((17.16195 122.8896, 26… dk    cort… #6400…
#>  7 lh_fus… infe… left  fusif… temp… (((559.6909 157.8355, 56… dk    cort… #B4DC…
#>  8 lh_inf… infe… left  infer… pari… (((467.6347 325.1216, 46… dk    cort… #DC3C…
#>  9 lh_inf… infe… left  infer… temp… (((245.822 185.0794, 255… dk    cort… #B428…
#> 10 lh_ins… infe… left  insula insu… (((181.2922 169.843, 191… dk    cort… #FFC0…
#> # ℹ 181 more rows
reposition_brain(dk(), view ~ hemi)
#> Simple feature collection with 191 features and 8 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -19.19707 ymin: -19.19707 xmax: 1409.547 ymax: 1938.904
#> CRS:           NA
#> # A tibble: 191 × 9
#>    label   view  hemi  region lobe                   geometry atlas type  colour
#>  * <chr>   <chr> <chr> <chr>  <chr>            <MULTIPOLYGON> <chr> <chr> <chr> 
#>  1 lh_unk… infe… left  NA     NA    (((283.0321 93.76352, 43… dk    cort… NA    
#>  2 lh_ban… infe… left  banks… temp… (((450.3846 295.7177, 47… dk    cort… #1964…
#>  3 lh_cau… infe… left  cauda… fron… (((188.6943 302.0361, 18… dk    cort… #6419…
#>  4 lh_cor… infe… left  corpu… whit… (((402.2002 121.1967, 40… dk    cort… #7846…
#>  5 lh_ent… infe… left  entor… temp… (((274.1602 156.9255, 31… dk    cort… #DC14…
#>  6 lh_fro… infe… left  front… fron… (((17.16195 122.8896, 26… dk    cort… #6400…
#>  7 lh_fus… infe… left  fusif… temp… (((559.6909 157.8355, 56… dk    cort… #B4DC…
#>  8 lh_inf… infe… left  infer… pari… (((467.6347 325.1216, 46… dk    cort… #DC3C…
#>  9 lh_inf… infe… left  infer… temp… (((245.822 185.0794, 255… dk    cort… #B428…
#> 10 lh_ins… infe… left  insula insu… (((181.2922 169.843, 191… dk    cort… #FFC0…
#> # ℹ 181 more rows
reposition_brain(dk(), hemi + view ~ .)
#> Simple feature collection with 191 features and 8 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -39.83406 ymin: -39.83406 xmax: 671.8112 ymax: 4023.24
#> CRS:           NA
#> # A tibble: 191 × 9
#>    label   view  hemi  region lobe                   geometry atlas type  colour
#>  * <chr>   <chr> <chr> <chr>  <chr>            <MULTIPOLYGON> <chr> <chr> <chr> 
#>  1 lh_unk… infe… left  NA     NA    (((283.0321 93.76352, 43… dk    cort… NA    
#>  2 lh_ban… infe… left  banks… temp… (((450.3846 295.7177, 47… dk    cort… #1964…
#>  3 lh_cau… infe… left  cauda… fron… (((188.6943 302.0361, 18… dk    cort… #6419…
#>  4 lh_cor… infe… left  corpu… whit… (((402.2002 121.1967, 40… dk    cort… #7846…
#>  5 lh_ent… infe… left  entor… temp… (((274.1602 156.9255, 31… dk    cort… #DC14…
#>  6 lh_fro… infe… left  front… fron… (((17.16195 122.8896, 26… dk    cort… #6400…
#>  7 lh_fus… infe… left  fusif… temp… (((559.6909 157.8355, 56… dk    cort… #B4DC…
#>  8 lh_inf… infe… left  infer… pari… (((467.6347 325.1216, 46… dk    cort… #DC3C…
#>  9 lh_inf… infe… left  infer… temp… (((245.822 185.0794, 255… dk    cort… #B428…
#> 10 lh_ins… infe… left  insula insu… (((181.2922 169.843, 191… dk    cort… #FFC0…
#> # ℹ 181 more rows
reposition_brain(dk(), . ~ hemi + view)
#> Simple feature collection with 191 features and 8 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -59.40585 ymin: -59.40585 xmax: 5999.991 ymax: 489.3431
#> CRS:           NA
#> # A tibble: 191 × 9
#>    label   view  hemi  region lobe                   geometry atlas type  colour
#>  * <chr>   <chr> <chr> <chr>  <chr>            <MULTIPOLYGON> <chr> <chr> <chr> 
#>  1 lh_unk… infe… left  NA     NA    (((283.0321 93.76352, 43… dk    cort… NA    
#>  2 lh_ban… infe… left  banks… temp… (((450.3846 295.7177, 47… dk    cort… #1964…
#>  3 lh_cau… infe… left  cauda… fron… (((188.6943 302.0361, 18… dk    cort… #6419…
#>  4 lh_cor… infe… left  corpu… whit… (((402.2002 121.1967, 40… dk    cort… #7846…
#>  5 lh_ent… infe… left  entor… temp… (((274.1602 156.9255, 31… dk    cort… #DC14…
#>  6 lh_fro… infe… left  front… fron… (((17.16195 122.8896, 26… dk    cort… #6400…
#>  7 lh_fus… infe… left  fusif… temp… (((559.6909 157.8355, 56… dk    cort… #B4DC…
#>  8 lh_inf… infe… left  infer… pari… (((467.6347 325.1216, 46… dk    cort… #DC3C…
#>  9 lh_inf… infe… left  infer… temp… (((245.822 185.0794, 255… dk    cort… #B428…
#> 10 lh_ins… infe… left  insula insu… (((181.2922 169.843, 191… dk    cort… #FFC0…
#> # ℹ 181 more rows

# \donttest{
reposition_brain(aseg(), nrow = 2)
#> Simple feature collection with 262 features and 8 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -12.14948 ymin: -12.14948 xmax: 1227.097 ymax: 611.2467
#> CRS:           NA
#> First 10 features:
#>                   label      view hemi         region     structure atlas
#> 256             cortex_ coronal_2 <NA>           <NA>          <NA>  aseg
#> 1            Brain-Stem coronal_2 <NA>     Brain Stem     brainstem  aseg
#> 10          CC_Anterior coronal_2 <NA>    cc anterior          <NA>  aseg
#> 15           CC_Central coronal_2 <NA>     cc central          <NA>  aseg
#> 31  Left-Accumbens-area coronal_2 left accumbens area          <NA>  aseg
#> 34        Left-Amygdala coronal_2 left       Amygdala        limbic  aseg
#> 35        Left-Amygdala coronal_2 left       Amygdala        limbic  aseg
#> 52         Left-Caudate coronal_2 left        Caudate basal ganglia  aseg
#> 53         Left-Caudate coronal_2 left        Caudate basal ganglia  aseg
#> 70     Left-Hippocampus coronal_2 left    Hippocampus        limbic  aseg
#>            type  colour                       geometry
#> 256 subcortical    <NA> MULTIPOLYGON (((144.4187 21...
#> 1   subcortical #779FB0 MULTIPOLYGON (((125.55 58.9...
#> 10  subcortical #0000FF MULTIPOLYGON (((133.3539 14...
#> 15  subcortical #0000A0 MULTIPOLYGON (((132.344 150...
#> 31  subcortical #FFA500 MULTIPOLYGON (((125.2612 12...
#> 34  subcortical #67FFFF MULTIPOLYGON (((89.67841 68...
#> 35  subcortical #67FFFF MULTIPOLYGON (((89.67841 68...
#> 52  subcortical #7ABADC MULTIPOLYGON (((115.2978 12...
#> 53  subcortical #7ABADC MULTIPOLYGON (((115.2978 12...
#> 70  subcortical #DCD814 MULTIPOLYGON (((91.13218 68...
reposition_brain(aseg(), views = c("sagittal", "axial_3"))
#> Simple feature collection with 61 features and 8 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -5.66502 ymin: -5.66502 xmax: 572.167 ymax: 262.8586
#> CRS:           NA
#> First 10 features:
#>                                  label     view hemi           region
#> X.sagittal..257                cortex_ sagittal <NA>             <NA>
#> X.sagittal..6               Brain-Stem sagittal <NA>       Brain Stem
#> X.sagittal..7              CC_Anterior sagittal <NA>      cc anterior
#> X.sagittal..12              CC_Central sagittal <NA>       cc central
#> X.sagittal..18         CC_Mid_Anterior sagittal <NA>  cc mid anterior
#> X.sagittal..20        CC_Mid_Posterior sagittal <NA> cc mid posterior
#> X.sagittal..25            CC_Posterior sagittal <NA>     cc posterior
#> X.sagittal..54  Left-Cerebellum-Cortex sagittal left       Cerebellum
#> X.sagittal..55  Left-Cerebellum-Cortex sagittal left       Cerebellum
#> X.sagittal..120          Left-Thalamus sagittal left         Thalamus
#>                     structure atlas        type  colour
#> X.sagittal..257          <NA>  aseg subcortical    <NA>
#> X.sagittal..6       brainstem  aseg subcortical #779FB0
#> X.sagittal..7            <NA>  aseg subcortical #0000FF
#> X.sagittal..12           <NA>  aseg subcortical #0000A0
#> X.sagittal..18           <NA>  aseg subcortical #0000D0
#> X.sagittal..20           <NA>  aseg subcortical #000070
#> X.sagittal..25           <NA>  aseg subcortical #000040
#> X.sagittal..54     cerebellum  aseg subcortical #E69422
#> X.sagittal..55     cerebellum  aseg subcortical #E69422
#> X.sagittal..120 basal ganglia  aseg subcortical #00760E
#>                                       geometry
#> X.sagittal..257 MULTIPOLYGON (((65.44853 20...
#> X.sagittal..6   MULTIPOLYGON (((92.93022 12...
#> X.sagittal..7   MULTIPOLYGON (((189.3959 11...
#> X.sagittal..12  MULTIPOLYGON (((164.3167 15...
#> X.sagittal..18  MULTIPOLYGON (((188.9379 14...
#> X.sagittal..20  MULTIPOLYGON (((123.7356 15...
#> X.sagittal..25  MULTIPOLYGON (((95.71832 13...
#> X.sagittal..54  MULTIPOLYGON (((62.23099 10...
#> X.sagittal..55  MULTIPOLYGON (((62.23099 10...
#> X.sagittal..120 MULTIPOLYGON (((140.0147 13...
# }
```
