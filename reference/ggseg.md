# ggseg: Visualise brain atlas data with ggplot2

Provides a ggplot2 geom and position for visualising brain region data
on cortical, subcortical, and white matter tract atlases. Brain atlas
geometries are stored as simple features (sf), enabling seamless
integration with the ggplot2 ecosystem including faceting, custom
scales, and themes.

\`ggseg()\` is defunct as of version 2.0.0. Use \`ggplot() +
geom_brain()\` instead.

## Usage

``` r
ggseg(...)
```

## Arguments

- ...:

  Ignored.

## Value

Does not return; always raises an error.

## Details

The main entry point is \[geom_brain()\], which accepts a
\`ggseg_atlas\` object and optional user data. Use \[position_brain()\]
to control the layout of brain slices/views.

## See also

Useful links:

- <https://ggsegverse.github.io/ggseg/>

- <https://github.com/ggsegverse/ggseg>

- Report bugs at <https://github.com/ggsegverse/ggseg/issues>

\[geom_brain()\] for the replacement API.

## Author

**Maintainer**: Athanasia Mo Mowinckel <a.m.mowinckel@psykologi.uio.no>
([ORCID](https://orcid.org/0000-0002-5756-0223))

Authors:

- Didac Vidal-Piñeiro <d.v.pineiro@psykologi.uio.no>
  ([ORCID](https://orcid.org/0000-0001-9997-9156))

- Ramiro Magno <ramiro.magno@gmail.com>
  ([ORCID](https://orcid.org/0000-0001-5226-3441))

## Examples

``` r
if (FALSE) { # \dontrun{
ggseg()
} # }
```
