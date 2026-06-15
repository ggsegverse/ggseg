# Keep brain shapes undistorted

Fixes the aspect ratio so brains aren't stretched by the shape of the
plotting window. \[geom_brain()\] adds \`coord_brain()\` for you, so you
rarely need to call it yourself – reach for it only to adjust the
\`ratio\` or \`clip\` behaviour. You can safely add your own coord or
stack several \`geom_brain()\` layers; it steps aside cleanly.

## Usage

``` r
coord_brain(ratio = 1, clip = "off", ...)
```

## Arguments

- ratio:

  Aspect ratio, expressed as \`y / x\`. Defaults to \`1\`, which keeps
  brain polygons undistorted.

- clip:

  Should drawing be clipped to the panel extent (\`"on"\`) or allowed to
  overflow (\`"off"\`)? Defaults to \`"off"\` so region outlines at the
  panel edge are not cut.

- ...:

  Additional arguments passed to \[ggplot2::coord_fixed()\].

## Value

A ggplot2 coordinate system that registers as a default.

## Examples

``` r
library(ggplot2)
if (FALSE) { # \dontrun{
poly <- ggseg.formats::as_polygon_atlas(dk())
# Equivalent to the default; shown explicitly:
ggplot() +
  geom_brain(atlas = poly) +
  coord_brain()
} # }
```
