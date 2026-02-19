# Axis and label scales for brain atlas plots

Add axis labels and tick labels corresponding to brain atlas regions.
These scales add hemisphere or view labels to the x and y axes based on
the atlas layout.

## Usage

``` r
scale_continous_brain(
  atlas = dk(),
  position = "dispersed",
  aesthetics = c("y", "x")
)

scale_x_brain(...)

scale_y_brain(...)

scale_labs_brain(atlas = dk(), position = "dispersed", aesthetics = "labs")
```

## Arguments

- atlas:

  A \`ggseg_atlas\` object or data.frame containing atlas data.

- position:

  Layout style: \`"dispersed"\` (default) or \`"stacked"\`.

- aesthetics:

  Which axis to scale: \`"x"\`, \`"y"\`, or \`"labs"\`.

- ...:

  Additional arguments passed to \[adapt_scales()\].

## Value

A ggplot2 scale or labs object.

## Examples

``` r
# \donttest{
library(ggplot2)

ggplot() +
  geom_brain(atlas = dk()) +
  scale_x_brain() +
  scale_y_brain() +
  scale_labs_brain()

# }
```
