# Render a brain atlas with default snapshot styling

Builds a minimal, deterministic plot of a `ggseg_atlas`: every region
filled by its `label`, no legend, and
[`ggplot2::theme_void()`](https://ggplot2.tidyverse.org/reference/ggtheme.html).
This is the canonical construction used across the ggsegverse for
visual-regression (`vdiffr`) snapshots, so that every atlas is rendered
the same way and a stray legend, axis, or title cannot creep into a
snapshot. It doubles as a quick way to preview an atlas.

## Usage

``` r
brain_test_plot(atlas, position = NULL, na.value = "grey")
```

## Arguments

- atlas:

  A `ggseg_atlas` object, such as
  [`dk()`](https://ggsegverse.github.io/ggseg.formats/reference/dk.html)
  or
  [`aseg()`](https://ggsegverse.github.io/ggseg.formats/reference/aseg.html).

- position:

  A `ggplot2` position adjustment arranging the brain views. Defaults to
  `position_brain(hemi ~ view)` for cortical atlases and
  `position_brain(. ~ view)` for slice-based atlases (subcortical,
  cerebellar, tract), whose views already contain both hemispheres.

- na.value:

  Fill colour for regions with no palette entry. Defaults to `"grey"`.

## Value

A
[`ggplot2::ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html)
object.

## Details

The atlas `palette` is applied with
[`ggplot2::scale_fill_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html)
when it is present; atlases without a palette fall back to the default
`ggplot2` fill scale.

## See also

[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)

## Examples

``` r
brain_test_plot(dk())

```
