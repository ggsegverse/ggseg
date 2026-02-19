# Themes for brain atlas plots

A set of ggplot2 themes designed for brain atlas visualisations. All
themes remove axis ticks and grid lines for a clean presentation.

## Usage

``` r
theme_brain(text.size = 12, text.family = "mono")

theme_darkbrain(text.size = 12, text.family = "mono")

theme_custombrain(
  plot.background = "white",
  text.colour = "darkgrey",
  text.size = 12,
  text.family = "mono"
)

theme_brain2(
  plot.background = "white",
  text.colour = "darkgrey",
  text.size = 12,
  text.family = "mono"
)
```

## Arguments

- text.size:

  Text size in points (default: \`12\`).

- text.family:

  Font family (default: \`"mono"\`).

- plot.background:

  Background fill colour (\`theme_custombrain\` and \`theme_brain2\`
  only).

- text.colour:

  Text colour (\`theme_custombrain\` and \`theme_brain2\` only).

## Value

A \[ggplot2::theme\] object.

## Details

- \`theme_brain\`:

  Default theme. Transparent background, no axes, no grid.

- \`theme_darkbrain\`:

  Dark theme with black background and light text.

- \`theme_custombrain\`:

  Fully customisable background, text colour, size, and font.

- \`theme_brain2\`:

  Like \`theme_custombrain\` but with axis text removed entirely.

## See also

\[geom_brain()\], \[ggplot2::theme()\]

## Examples

``` r
library(ggplot2)

p <- ggplot() +
  geom_brain(atlas = dk())

p +
  theme_brain()


p +
  theme_darkbrain()

```
