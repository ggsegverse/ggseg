# Colour and fill scales from brain atlas palettes

**\[deprecated\]**

Atlas palettes are now applied automatically by
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md).
Use
[`scale_fill_brain_manual()`](https://ggsegverse.github.io/ggseg/reference/scale_brain_manual.md)
for custom palettes.

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

  String name of the atlas palette (e.g. `"dk"`, `"aseg"`).

- na.value:

  Colour for `NA` entries (default: `"grey"`).

- ...:

  Additional arguments passed to
  [`ggseg.formats::atlas_palette()`](https://ggsegverse.github.io/ggseg.formats/reference/atlas_palette.html).

- aesthetics:

  Which aesthetic to scale: `"fill"`, `"colour"`, or `"color"`.

## Value

A ggplot2 scale object.

## Examples

``` r
if (FALSE) { # \dontrun{
library(ggplot2)
ggplot() +
  geom_brain(atlas = dk(), aes(fill = label), show.legend = FALSE) +
  scale_brain("dk")
} # }
```
