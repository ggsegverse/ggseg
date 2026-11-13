# The drawn data for a brain plot's regions

[`ggplot2::layer_data()`](https://ggplot2.tidyverse.org/reference/ggplot_build.html)
takes a layer by position, and
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
adds two: the context backdrop first, so it draws underneath, then the
regions. `layer_data(p)` therefore returns the backdrop. This returns
the regions whatever the layer order, so inspecting a brain plot does
not depend on how many layers it happens to have.

## Usage

``` r
brain_layer_data(plot, context = FALSE)
```

## Arguments

- plot:

  A ggplot built with
  [`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
  or
  [`stat_brain()`](https://ggsegverse.github.io/ggseg/reference/stat_brain.md).

- context:

  When `TRUE`, return the context backdrop's data instead of the
  regions'.

## Value

A data.frame of the drawn data, as
[`ggplot2::layer_data()`](https://ggplot2.tidyverse.org/reference/ggplot_build.html)
returns.

## See also

[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)

## Examples

``` r
library(ggplot2)

p <- ggplot() + geom_brain(atlas = dk())

# the regions, whichever layer they are
head(brain_layer_data(p))
#>   PANEL         label     region hemi group     view        x        y .group
#> 1     1 lh_precentral precentral left     8 inferior 66.57283 103.3961      1
#> 2     1 lh_precentral precentral left     8 inferior 75.43627 107.7048      1
#> 3     1 lh_precentral precentral left     8 inferior 83.73107 112.1067      1
#> 4     1 lh_precentral precentral left     8 inferior 88.97667 114.1050      1
#> 5     1 lh_precentral precentral left     8 inferior 86.58294 112.3535      1
#> 6     1 lh_precentral precentral left     8 inferior 86.15597 106.5335      1
#>   subgroup    display    lobe atlas     type .feature_id    fill colour
#> 1        1 precentral frontal    dk cortical           8 #3C14DC grey35
#> 2        1 precentral frontal    dk cortical           8 #3C14DC grey35
#> 3        1 precentral frontal    dk cortical           8 #3C14DC grey35
#> 4        1 precentral frontal    dk cortical           8 #3C14DC grey35
#> 5        1 precentral frontal    dk cortical           8 #3C14DC grey35
#> 6        1 precentral frontal    dk cortical           8 #3C14DC grey35
#>   linewidth linetype alpha
#> 1       0.2        1    NA
#> 2       0.2        1    NA
#> 3       0.2        1    NA
#> 4       0.2        1    NA
#> 5       0.2        1    NA
#> 6       0.2        1    NA

# and the backdrop behind them
head(brain_layer_data(p, context = TRUE))
#>   PANEL      label region hemi group     view        x        y .group subgroup
#> 1     1 lh_unknown   <NA> left     1 inferior 59.99261 37.94643      1        1
#> 2     1 lh_unknown   <NA> left     1 inferior 59.29154 39.90608      1        1
#> 3     1 lh_unknown   <NA> left     1 inferior 62.22706 42.19811      1        1
#> 4     1 lh_unknown   <NA> left     1 inferior 58.87957 48.37019      1        1
#> 5     1 lh_unknown   <NA> left     1 inferior 58.73218 49.28655      1        1
#> 6     1 lh_unknown   <NA> left     1 inferior 61.62657 50.40204      1        1
#>   display lobe atlas     type .feature_id colour fill linewidth linetype alpha
#> 1    <NA> <NA>    dk cortical           1 grey35 grey       0.2        1    NA
#> 2    <NA> <NA>    dk cortical           1 grey35 grey       0.2        1    NA
#> 3    <NA> <NA>    dk cortical           1 grey35 grey       0.2        1    NA
#> 4    <NA> <NA>    dk cortical           1 grey35 grey       0.2        1    NA
#> 5    <NA> <NA>    dk cortical           1 grey35 grey       0.2        1    NA
#> 6    <NA> <NA>    dk cortical           1 grey35 grey       0.2        1    NA
```
