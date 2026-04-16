# Deprecated scale functions

\`r lifecycle::badge("deprecated")\`

These functions have been renamed for clarity: - \`scale_brain2()\` -\>
\[scale_brain_manual()\] - \`scale_fill_brain2()\` -\>
\[scale_fill_brain_manual()\] - \`scale_colour_brain2()\` -\>
\[scale_colour_brain_manual()\] - \`scale_color_brain2()\` -\>
\[scale_color_brain_manual()\]

## Usage

``` r
scale_brain2(...)

scale_colour_brain2(...)

scale_color_brain2(...)

scale_fill_brain2(...)
```

## Arguments

- ...:

  Arguments passed to the replacement function.

## Value

A ggplot2 scale object.

## Examples

``` r
pal <- c("transverse temporal" = "#FF0000", "insula" = "#00FF00")
suppressWarnings(scale_fill_brain_manual(palette = pal))
#> <ggproto object: Class ScaleDiscrete, Scale, gg>
#>     aesthetics: fill
#>     axis_order: function
#>     break_info: function
#>     break_positions: function
#>     breaks: waiver
#>     call: call
#>     clone: function
#>     dimension: function
#>     drop: TRUE
#>     expand: waiver
#>     fallback_palette: function
#>     get_breaks: function
#>     get_breaks_minor: function
#>     get_labels: function
#>     get_limits: function
#>     get_transformation: function
#>     guide: legend
#>     is_discrete: function
#>     is_empty: function
#>     labels: waiver
#>     limits: function
#>     make_sec_title: function
#>     make_title: function
#>     map: function
#>     map_df: function
#>     minor_breaks: waiver
#>     n.breaks.cache: NULL
#>     na.translate: TRUE
#>     na.value: grey
#>     name: waiver
#>     palette: function
#>     palette.cache: NULL
#>     position: left
#>     range: environment
#>     rescale: function
#>     reset: function
#>     train: function
#>     train_df: function
#>     transform: function
#>     transform_df: function
#>     super:  <ggproto object: Class ScaleDiscrete, Scale, gg>
```
