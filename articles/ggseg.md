# Getting started with ggseg

If you work with neuroimaging data, you’ve probably spent time wrestling
region-level results into brain plots. ggseg handles that plumbing for
you. It stores brain atlas geometries and plots them as ggplot2 layers,
so you get brain figures with the same code you’d use for any other
ggplot.

``` r

library(ggseg)
library(ggplot2)
```

## What’s in a brain atlas

A `ggseg_atlas` object bundles four things: a name, a type (cortical,
subcortical, or tract), region geometry, and an optional colour palette.

``` r

dk()
#> 
#> ── dk ggseg atlas ──────────────────────────────────────────────────────────────
#> Type: cortical
#> Regions: 35
#> Hemispheres: left, right
#> Views: inferior, lateral, medial, superior
#> Palette: ✔
#> Rendering: ✔ ggseg
#> ✔ ggseg3d (vertices)
#> ────────────────────────────────────────────────────────────────────────────────
#>    hemi                  region                      label
#> 1  left                bankssts                lh_bankssts
#> 2  left caudalanteriorcingulate lh_caudalanteriorcingulate
#> 3  left     caudalmiddlefrontal     lh_caudalmiddlefrontal
#> 4  left          corpuscallosum          lh_corpuscallosum
#> 5  left                  cuneus                  lh_cuneus
#> 6  left              entorhinal              lh_entorhinal
#> 7  left                fusiform                lh_fusiform
#> 8  left        inferiorparietal        lh_inferiorparietal
#> 9  left        inferiortemporal        lh_inferiortemporal
#> 10 left        isthmuscingulate        lh_isthmuscingulate
#>                              display         lobe
#> 1  banks of superior temporal sulcus     temporal
#> 2          caudal anterior cingulate    cingulate
#> 3              caudal middle frontal      frontal
#> 4                    corpus callosum white matter
#> 5                             cuneus    occipital
#> 6                         entorhinal     temporal
#> 7                           fusiform     temporal
#> 8                  inferior parietal     parietal
#> 9                  inferior temporal     temporal
#> 10                 isthmus cingulate    cingulate
#> ... with 60 more rows
```

The `dk` atlas (Desikan-Killiany) ships with the package. Call
[`plot()`](https://rdrr.io/r/graphics/plot.default.html) for a quick
look:

``` r

plot(dk())
```

![Quick overview of the Desikan-Killiany cortical
atlas.](ggseg_files/figure-html/fig-dk-plot-1.png)

Quick overview of the Desikan-Killiany cortical atlas.

Two helpers pull out the names you’ll need for matching data:

``` r

library(ggseg.formats)

sort(unique(atlas_regions(dk())))
#>  [1] "bankssts"                 "caudalanteriorcingulate" 
#>  [3] "caudalmiddlefrontal"      "corpuscallosum"          
#>  [5] "cuneus"                   "entorhinal"              
#>  [7] "frontalpole"              "fusiform"                
#>  [9] "inferiorparietal"         "inferiortemporal"        
#> [11] "insula"                   "isthmuscingulate"        
#> [13] "lateraloccipital"         "lateralorbitofrontal"    
#> [15] "lingual"                  "medialorbitofrontal"     
#> [17] "middletemporal"           "paracentral"             
#> [19] "parahippocampal"          "parsopercularis"         
#> [21] "parsorbitalis"            "parstriangularis"        
#> [23] "pericalcarine"            "postcentral"             
#> [25] "posteriorcingulate"       "precentral"              
#> [27] "precuneus"                "rostralanteriorcingulate"
#> [29] "rostralmiddlefrontal"     "superiorfrontal"         
#> [31] "superiorparietal"         "superiortemporal"        
#> [33] "supramarginal"            "temporalpole"            
#> [35] "transversetemporal"
sort(unique(atlas_labels(dk())))
#>  [1] "lh_bankssts"                 "lh_caudalanteriorcingulate" 
#>  [3] "lh_caudalmiddlefrontal"      "lh_corpuscallosum"          
#>  [5] "lh_cuneus"                   "lh_entorhinal"              
#>  [7] "lh_frontalpole"              "lh_fusiform"                
#>  [9] "lh_inferiorparietal"         "lh_inferiortemporal"        
#> [11] "lh_insula"                   "lh_isthmuscingulate"        
#> [13] "lh_lateraloccipital"         "lh_lateralorbitofrontal"    
#> [15] "lh_lingual"                  "lh_medialorbitofrontal"     
#> [17] "lh_middletemporal"           "lh_paracentral"             
#> [19] "lh_parahippocampal"          "lh_parsopercularis"         
#> [21] "lh_parsorbitalis"            "lh_parstriangularis"        
#> [23] "lh_pericalcarine"            "lh_postcentral"             
#> [25] "lh_posteriorcingulate"       "lh_precentral"              
#> [27] "lh_precuneus"                "lh_rostralanteriorcingulate"
#> [29] "lh_rostralmiddlefrontal"     "lh_superiorfrontal"         
#> [31] "lh_superiorparietal"         "lh_superiortemporal"        
#> [33] "lh_supramarginal"            "lh_temporalpole"            
#> [35] "lh_transversetemporal"       "rh_bankssts"                
#> [37] "rh_caudalanteriorcingulate"  "rh_caudalmiddlefrontal"     
#> [39] "rh_corpuscallosum"           "rh_cuneus"                  
#> [41] "rh_entorhinal"               "rh_frontalpole"             
#> [43] "rh_fusiform"                 "rh_inferiorparietal"        
#> [45] "rh_inferiortemporal"         "rh_insula"                  
#> [47] "rh_isthmuscingulate"         "rh_lateraloccipital"        
#> [49] "rh_lateralorbitofrontal"     "rh_lingual"                 
#> [51] "rh_medialorbitofrontal"      "rh_middletemporal"          
#> [53] "rh_paracentral"              "rh_parahippocampal"         
#> [55] "rh_parsopercularis"          "rh_parsorbitalis"           
#> [57] "rh_parstriangularis"         "rh_pericalcarine"           
#> [59] "rh_postcentral"              "rh_posteriorcingulate"      
#> [61] "rh_precentral"               "rh_precuneus"               
#> [63] "rh_rostralanteriorcingulate" "rh_rostralmiddlefrontal"    
#> [65] "rh_superiorfrontal"          "rh_superiorparietal"        
#> [67] "rh_superiortemporal"         "rh_supramarginal"           
#> [69] "rh_temporalpole"             "rh_transversetemporal"
```

## Your first brain plot

[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
works like any ggplot2 geom. Pass it an atlas and it draws the regions:

``` r

ggplot() +
  geom_brain(atlas = dk(), show.legend = FALSE)
```

![A bare atlas: geom_brain() fills by \`label\` from the
palette.](ggseg_files/figure-html/fig-basic-brain-1.png)

A bare atlas: geom_brain() fills by `label` from the palette.

## Arranging views

Brain atlases have multiple views (lateral, medial) and hemispheres.
[`position_brain()`](https://ggsegverse.github.io/ggseg/reference/position_brain.md)
controls how they’re laid out, using formula syntax borrowed from
[`facet_grid()`](https://ggplot2.tidyverse.org/reference/facet_grid.html):

``` r

ggplot() +
  geom_brain(
    atlas = dk(),
    position = position_brain(hemi ~ view),
    show.legend = FALSE
  )
```

![Brain views arranged using formula syntax in
position_brain().](ggseg_files/figure-html/fig-position-formula-1.png)

Brain views arranged using formula syntax in position_brain().

Or reorder views with a character vector:

``` r

ggplot() +
  geom_brain(
    atlas = dk(),
    position = position_brain(c(
      "right lateral",
      "right medial",
      "left lateral",
      "left medial"
    )),
    show.legend = FALSE
  )
```

![Brain views arranged using a character vector to specify
order.](ggseg_files/figure-html/fig-position-character-1.png)

Brain views arranged using a character vector to specify order.

See
[`vignette("positioning-views")`](https://ggsegverse.github.io/ggseg/articles/positioning-views.md)
for the full set of layout options, including grid layouts for
subcortical and tract atlases and per-view zoom.

## Showing only certain hemispheres or views

``` r

ggplot() +
  geom_brain(atlas = dk(), view = "lateral", show.legend = FALSE)
```

![Brain plot showing only lateral
views.](ggseg_files/figure-html/fig-filter-lateral-1.png)

Brain plot showing only lateral views.

``` r

ggplot() +
  geom_brain(atlas = dk(), hemi = "left", show.legend = FALSE)
```

![Brain plot showing only the left
hemisphere.](ggseg_files/figure-html/fig-filter-left-1.png)

Brain plot showing only the left hemisphere.

For subcortical atlases, views are slice identifiers. Check what’s
available with
[`ggseg.formats::atlas_views()`](https://ggsegverse.github.io/ggseg.formats/reference/atlas_views.html):

``` r

atlas_views(aseg())
#> [1] "axial_3"   "axial_4"   "axial_5"   "axial_6"   "coronal_1" "coronal_2"
#> [7] "sagittal"
```

## Plotting your own data

Create a data frame with at least one column that matches the atlas
(typically `region` or `label`). Pass it to
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
through the `data` argument and it joins to the atlas automatically:

``` r

library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

some_data <- tibble(
  region = sort(unique(atlas_regions(dk())))[1:4],
  p = sample(seq(0, 0.5, 0.001), 4)
)

ggplot() +
  geom_brain(
    atlas = dk(),
    data = some_data,
    position = position_brain(hemi ~ view),
    aes(fill = p)
  ) +
  scale_fill_viridis_c(option = "cividis", direction = -1) +
  theme_void()
```

![Brain plot coloured by external p-values using a viridis
scale.](ggseg_files/figure-html/fig-external-data-1.png)

Brain plot coloured by external p-values using a viridis scale.

See
[`vignette("external-data")`](https://ggsegverse.github.io/ggseg/articles/external-data.md)
for more on data preparation and matching.

## Faceting

ggplot2 faceting works as you’d expect. Group your data by the faceting
variable and
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
replicates the full atlas in each panel:

``` r

some_data <- tibble(
  region = rep(sort(unique(atlas_regions(dk())))[1:4], 2),
  p = sample(seq(0, 0.5, 0.001), 8),
  group = c(rep("A", 4), rep("B", 4))
)

ggplot() +
  geom_brain(
    atlas = dk(),
    data = group_by(some_data, group),
    position = position_brain(hemi ~ view),
    aes(fill = p)
  ) +
  facet_wrap(~group)
```

![Brain plots faceted by group, each panel showing the full
atlas.](ggseg_files/figure-html/fig-faceting-1.png)

Brain plots faceted by group, each panel showing the full atlas.

## Highlighting specific regions

To colour a few regions with their atlas colours, use two columns: one
for the join (`region`) and one for the fill aesthetic:

``` r

data <- data.frame(
  region = sort(unique(atlas_regions(dk())))[1:3],
  reg_col = sort(unique(atlas_labels(dk())))[1:3]
)

palette <- atlas_palette(dk())[1:3]

ggplot() +
  geom_brain(atlas = dk(), data = data, aes(fill = reg_col)) +
  scale_fill_brain_manual(palette)
```

![Highlighting selected regions using the atlas colour
palette.](ggseg_files/figure-html/fig-highlighting-1.png)

Highlighting selected regions using the atlas colour palette.

## Scales and themes

With neither `fill` nor `colour` mapped,
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
applies the atlas palette for you, keyed on `label`. For custom
palettes, use
[`scale_fill_brain_manual()`](https://ggsegverse.github.io/ggseg/reference/scale_brain_manual.md).

Built-in themes strip axes and grids for cleaner figures:

``` r

ggplot() +
  geom_brain(atlas = dk(), show.legend = FALSE) +
  theme_brain()
```

## Going further

For full control over the data before it reaches ggplot2 — adding region
labels, layering other sf geoms, or using
[`geom_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html)
directly — see
[`vignette("geom-sf")`](https://ggsegverse.github.io/ggseg/articles/geom-sf.md).

## Finding more atlases

ggseg ships with
[`dk()`](https://ggsegverse.github.io/ggseg.formats/reference/dk.html)
(cortical),
[`aseg()`](https://ggsegverse.github.io/ggseg.formats/reference/aseg.html)
(subcortical),
[`suit()`](https://ggsegverse.github.io/ggseg.formats/reference/suit.html)
(cerebellar flamap), and
[`tracula()`](https://ggsegverse.github.io/ggseg.formats/reference/tracula.html)
(white matter tracts). Many more are available through the [ggsegverse
r-universe](https://ggsegverse.r-universe.dev):

``` r

install.packages("ggsegYeo2011", repos = "https://ggsegverse.r-universe.dev")
```
