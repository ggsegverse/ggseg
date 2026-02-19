# Plotting external data

Most of the time, you’re not plotting empty atlases. You have results –
p-values, cortical thickness, whatever – and you want them on a brain.
This vignette covers how to get your data into the right shape for
ggseg.

``` r
library(ggseg)
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library(ggplot2)
```

## How matching works

[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
joins your data to the atlas by any columns they share. That means your
data needs at least one column with names that match the atlas. The two
columns you’ll use most:

- **region** – human-readable names like “insula” or “precentral”
- **label** – FreeSurfer labels like “lh_bankssts”

Check what’s available:

``` r
ggseg.formats::atlas_regions(dk())
```

    ##  [1] "banks of superior temporal sulcus" "caudal anterior cingulate"        
    ##  [3] "caudal middle frontal"             "corpus callosum"                  
    ##  [5] "cuneus"                            "entorhinal"                       
    ##  [7] "frontal pole"                      "fusiform"                         
    ##  [9] "inferior parietal"                 "inferior temporal"                
    ## [11] "insula"                            "isthmus cingulate"                
    ## [13] "lateral occipital"                 "lateral orbitofrontal"            
    ## [15] "lingual"                           "medial orbitofrontal"             
    ## [17] "middle temporal"                   "paracentral"                      
    ## [19] "parahippocampal"                   "pars opercularis"                 
    ## [21] "pars orbitalis"                    "pars triangularis"                
    ## [23] "pericalcarine"                     "postcentral"                      
    ## [25] "posterior cingulate"               "precentral"                       
    ## [27] "precuneus"                         "rostral anterior cingulate"       
    ## [29] "rostral middle frontal"            "superior frontal"                 
    ## [31] "superior parietal"                 "superior temporal"                
    ## [33] "supramarginal"                     "temporal pole"                    
    ## [35] "transverse temporal"

``` r
ggseg.formats::atlas_labels(dk())
```

    ##  [1] "lh_bankssts"                 "lh_caudalanteriorcingulate" 
    ##  [3] "lh_caudalmiddlefrontal"      "lh_corpuscallosum"          
    ##  [5] "lh_cuneus"                   "lh_entorhinal"              
    ##  [7] "lh_frontalpole"              "lh_fusiform"                
    ##  [9] "lh_inferiorparietal"         "lh_inferiortemporal"        
    ## [11] "lh_insula"                   "lh_isthmuscingulate"        
    ## [13] "lh_lateraloccipital"         "lh_lateralorbitofrontal"    
    ## [15] "lh_lingual"                  "lh_medialorbitofrontal"     
    ## [17] "lh_middletemporal"           "lh_paracentral"             
    ## [19] "lh_parahippocampal"          "lh_parsopercularis"         
    ## [21] "lh_parsorbitalis"            "lh_parstriangularis"        
    ## [23] "lh_pericalcarine"            "lh_postcentral"             
    ## [25] "lh_posteriorcingulate"       "lh_precentral"              
    ## [27] "lh_precuneus"                "lh_rostralanteriorcingulate"
    ## [29] "lh_rostralmiddlefrontal"     "lh_superiorfrontal"         
    ## [31] "lh_superiorparietal"         "lh_superiortemporal"        
    ## [33] "lh_supramarginal"            "lh_temporalpole"            
    ## [35] "lh_transversetemporal"       "rh_bankssts"                
    ## [37] "rh_caudalanteriorcingulate"  "rh_caudalmiddlefrontal"     
    ## [39] "rh_corpuscallosum"           "rh_cuneus"                  
    ## [41] "rh_entorhinal"               "rh_frontalpole"             
    ## [43] "rh_fusiform"                 "rh_inferiorparietal"        
    ## [45] "rh_inferiortemporal"         "rh_insula"                  
    ## [47] "rh_isthmuscingulate"         "rh_lateraloccipital"        
    ## [49] "rh_lateralorbitofrontal"     "rh_lingual"                 
    ## [51] "rh_medialorbitofrontal"      "rh_middletemporal"          
    ## [53] "rh_paracentral"              "rh_parahippocampal"         
    ## [55] "rh_parsopercularis"          "rh_parsorbitalis"           
    ## [57] "rh_parstriangularis"         "rh_pericalcarine"           
    ## [59] "rh_postcentral"              "rh_posteriorcingulate"      
    ## [61] "rh_precentral"               "rh_precuneus"               
    ## [63] "rh_rostralanteriorcingulate" "rh_rostralmiddlefrontal"    
    ## [65] "rh_superiorfrontal"          "rh_superiorparietal"        
    ## [67] "rh_superiortemporal"         "rh_supramarginal"           
    ## [69] "rh_temporalpole"             "rh_transversetemporal"

Names must match exactly, including case and spacing.

## A minimal example

Three regions, three p-values:

``` r
some_data <- tibble(
  region = c("superior temporal", "precentral", "lateral orbitofrontal"),
  p = c(.03, .6, .05)
)
some_data
```

    ## # A tibble: 3 × 2
    ##   region                    p
    ##   <chr>                 <dbl>
    ## 1 superior temporal      0.03
    ## 2 precentral             0.6 
    ## 3 lateral orbitofrontal  0.05

Pass the data to
[`ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html) and
map `fill` to your variable:

``` r
ggplot(some_data) +
  geom_brain(atlas = dk(), mapping = aes(fill = p))
```

    ## Merging atlas and data by region.

![Brain plot with three regions coloured by
p-value.](external-data_files/figure-html/fig-minimal-plot-1.png)

Brain plot with three regions coloured by p-value.

Regions not in your data appear as `NA` (grey by default). Regions in
your data that don’t match the atlas are silently dropped, so watch your
spelling.

## Constraining matches with extra columns

If your data is hemisphere-specific, add a `hemi` column. The join will
use both `region` and `hemi`, so values only land on the correct side:

``` r
some_data$hemi <- "left"

ggplot(some_data) +
  geom_brain(atlas = dk(), mapping = aes(fill = p))
```

    ## Merging atlas and data by region and hemi.

![Brain plot restricted to the left hemisphere using a hemi
column.](external-data_files/figure-html/fig-hemi-constraint-1.png)

Brain plot restricted to the left hemisphere using a hemi column.

The same works for any atlas column – adding `view`, for instance, would
restrict matches to specific views.

## Faceting across groups

If your data has a grouping variable,
[`facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html)
and
[`facet_grid()`](https://ggplot2.tidyverse.org/reference/facet_grid.html)
work as you’d expect.
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
detects the faceting variables and replicates the full atlas in each
panel:

``` r
some_data <- tibble(
  region = rep(
    c(
      "transverse temporal",
      "insula",
      "precentral",
      "superior parietal"
    ),
    2
  ),
  p = sample(seq(0, .5, .001), 8),
  group = c(rep("Young", 4), rep("Old", 4))
)

ggplot(some_data) +
  geom_brain(atlas = dk(), colour = "white", mapping = aes(fill = p)) +
  facet_wrap(~group, ncol = 1) +
  theme(legend.position = "bottom") +
  scale_fill_gradientn(
    colours = c("royalblue", "firebrick", "goldenrod"),
    na.value = "grey"
  )
```

    ## Merging atlas and data by region.

![Brain plots faceted by age group with a custom colour
gradient.](external-data_files/figure-html/fig-facet-groups-1.png)

Brain plots faceted by age group with a custom colour gradient.

No need to call
[`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html)
first – the geom handles atlas replication automatically. (Explicit
[`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html)
still works for backward compatibility.)

## The pre-merged workflow

For full control over faceting or when you need to combine brain data
with other sf layers, convert the atlas to a data frame and join
manually:

``` r
atlas_df <- as.data.frame(dk())
names(atlas_df)
```

    ## [1] "label"    "view"     "hemi"     "region"   "lobe"     "geometry" "atlas"   
    ## [8] "type"     "colour"

Then use a standard join and
[`geom_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html):

``` r
some_data <- tibble(
  region = c("superior temporal", "precentral", "lateral orbitofrontal"),
  p = c(.03, .6, .05)
)

atlas_df |>
  left_join(some_data, by = "region") |>
  ggplot() +
  geom_sf(aes(fill = p), colour = "white") +
  facet_grid(hemi ~ view) +
  theme_void()
```

![Brain plot using a manual left_join and geom_sf for full
control.](external-data_files/figure-html/fig-pre-merged-1.png)

Brain plot using a manual left_join and geom_sf for full control.

See
[`vignette("geom-sf")`](https://ggsegverse.github.io/ggseg/articles/geom-sf.md)
for more on this approach.

## Troubleshooting

**Regions don’t show up.** Check spelling and case.
`ggseg.formats::atlas_regions(dk())` gives you the exact strings the
atlas expects.

**Data lands on both hemispheres.** Add a `hemi` column with `"left"` or
`"right"` to constrain the match.

**Extra facet panels appear.** This is handled automatically by
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md).
If you’re using the
[`brain_join()`](https://ggsegverse.github.io/ggseg/reference/brain_join.md) +
[`geom_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html)
workflow directly,
[`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html) your
data by the faceting variable before joining.
