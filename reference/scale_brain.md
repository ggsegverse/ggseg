# Colour and fill scales from brain atlas palettes

\`r lifecycle::badge("deprecated")\`

Atlas palettes are now applied automatically by \[geom_brain()\]. Use
\[scale_fill_brain_manual()\] for custom palettes.

## Usage

``` r
scale_brain(
  name = "dk",
  na.value = "grey",
  ...,
  aesthetics = c("fill", "colour", "color")
)

scale_colour_brain(name = "dk", na.value = "grey", ...)

scale_color_brain(name = "dk", na.value = "grey", ...)

scale_fill_brain(name = "dk", na.value = "grey", ...)
```

## Arguments

- name:

  String name of the atlas palette (e.g. \`"dk"\`, \`"aseg"\`).

- na.value:

  Colour for \`NA\` entries (default: \`"grey"\`).

- ...:

  Additional arguments passed to \[ggseg.formats::atlas_palette()\].

- aesthetics:

  Which aesthetic to scale: \`"fill"\`, \`"colour"\`, or \`"color"\`.

## Value

A ggplot2 scale object.

## Examples

``` r
if (FALSE) { # \dontrun{
library(ggplot2)
ggplot() +
  geom_brain(atlas = dk(), aes(fill = region), show.legend = FALSE) +
  scale_brain("dk")
} # }
```
