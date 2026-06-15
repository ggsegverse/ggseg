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
joins your data to the atlas by `region` (and by `hemi` too, when both
your data and the atlas carry it). That means your data needs at least
one column with names that match the atlas. The two columns you’ll use
most:

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
  p = c(0.03, 0.6, 0.05)
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
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
through its `data` argument and map `fill` to your variable:

``` r

ggplot() +
  geom_brain(atlas = dk(), data = some_data, mapping = aes(fill = p))
```

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

ggplot() +
  geom_brain(atlas = dk(), data = some_data, mapping = aes(fill = p))
```

![Brain plot restricted to the left hemisphere using a hemi
column.](external-data_files/figure-html/fig-hemi-constraint-1.png)

Brain plot restricted to the left hemisphere using a hemi column.

The same works for any atlas column – adding `view`, for instance, would
restrict matches to specific views.

## Faceting across groups

If your data has a grouping variable, group by it and
[`facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html)
/
[`facet_grid()`](https://ggplot2.tidyverse.org/reference/facet_grid.html)
work as you’d expect.
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
replicates the full atlas – context regions included – in each panel:

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
  p = sample(seq(0, 0.5, 0.001), 8),
  group = c(rep("Young", 4), rep("Old", 4))
)

ggplot() +
  geom_brain(
    atlas = dk(),
    data = group_by(some_data, group),
    colour = "white",
    mapping = aes(fill = p)
  ) +
  facet_wrap(~group, ncol = 1) +
  theme(legend.position = "bottom") +
  scale_fill_gradientn(
    colours = c("royalblue", "firebrick", "goldenrod"),
    na.value = "grey"
  )
```

![Brain plots faceted by age group with a custom colour
gradient.](external-data_files/figure-html/fig-facet-groups-1.png)

Brain plots faceted by age group with a custom colour gradient.

Grouping the data is what tells the geom how many copies of the atlas to
make – one per group.

## Troubleshooting

**Regions don’t show up.** Check spelling and case.
`ggseg.formats::atlas_regions(dk())` gives you the exact strings the
atlas expects.

**Data lands on both hemispheres.** Add a `hemi` column with `"left"` or
`"right"` to constrain the match.

**A facet panel is missing context.** Group your data by the faceting
variable before plotting (`data = my_data |> group_by(group)`) so the
full atlas is replicated in every panel.

## Full control with sf

When you need to layer brain data with other sf geoms, or join the atlas
manually before plotting, work with the atlas as an sf object instead.
See
[`vignette("geom-sf")`](https://ggsegverse.github.io/ggseg/articles/geom-sf.md)
for that workflow.
