# Manual colour and fill scales for brain plots

Apply a custom named colour palette to brain atlas plots. Use this when
you want to override the atlas default colours with your own colour
mapping.

## Usage

``` r
scale_brain_manual(
  palette,
  na.value = "grey",
  ...,
  aesthetics = c("fill", "colour", "color")
)

scale_colour_brain_manual(...)

scale_color_brain_manual(...)

scale_fill_brain_manual(...)
```

## Arguments

- palette:

  Named character vector mapping region names to colours.

- na.value:

  Colour for \`NA\` entries (default: \`"grey"\`).

- ...:

  Additional arguments (unused).

- aesthetics:

  Which aesthetic to scale: \`"fill"\`, \`"colour"\`, or \`"color"\`.

## Value

A ggplot2 scale object.

## Examples

``` r
library(ggplot2)

pal <- c("insula" = "red", "precentral" = "blue")
ggplot() +
  geom_brain(atlas = dk(), aes(fill = region), show.legend = FALSE) +
  scale_fill_brain_manual(palette = pal)

```
