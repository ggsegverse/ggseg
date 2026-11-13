# Changelog

## ggseg (development version)

A major release. The atlas geometry now comes from the re-keyed
`ggseg.formats` atlases (`>= 0.0.4.9008`), and
[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
has been rebuilt on a `Stat` so that faceting, inherited
`data`/[`aes()`](https://ggplot2.tidyverse.org/reference/aes.html), and
outline aesthetics work the way ggplot2 users expect. Several of those
fixes change existing figures, so read the breaking changes before
upgrading.

### Breaking changes

- **[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
  adds two layers.** The context backdrop is drawn by a layer of its
  own, underneath the regions, so a mapped `fill` cannot reach it and it
  claims no legend key
  ([\#182](https://github.com/ggsegverse/ggseg/issues/182)).
  `layer_data(p)` and `p$layers[[1]]` therefore return the backdrop; use
  [`brain_layer_data()`](https://ggsegverse.github.io/ggseg/reference/brain_layer_data.md)
  for the regions.

- **`na.value` no longer sets the backdrop colour.** It now means what
  it says on a fill scale – the colour of regions your data has no value
  for – and the backdrop takes `context_fill` instead. Previously one
  setting did both, so reddening `na.value` to find your data’s gaps
  also reddened the whole silhouette. Code that set `na.value` to style
  the backdrop wants `context_fill`.

- **Region keys changed.** The `region` column now holds short keys
  (e.g. `"superiorparietal"`) and the spelled-out names moved to
  `display`. **Any user data joined by `region` must be re-keyed**;
  [`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
  warns that the rows were not merged. Use
  [`ggseg.formats::legacy_region_map()`](https://ggsegverse.github.io/ggseg.formats/reference/legacy_region_map.html)
  to translate, or join by the schema-stable `label` instead. Requires
  `ggseg.formats (>= 0.0.4.9008)`.

- **`GeomBrain` is a different object**: the polygon geom backing the
  default
  [`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md).
  The sf geom it used to be is now `GeomBrainSf`, which this release
  exports as a migration target. The export name did not change, so
  extension code reaching for `GeomBrain` fails as a rendering error
  rather than an object-not-found error.

- **[`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
  gained `fun`, positionally before `show.legend`.** Callers passing
  `show.legend` or `inherit.aes` positionally shift by one – name those
  arguments.

- **Multiple `data` rows per region are combined, not overplotted.**
  `fun` (default `mean`) reduces them within each panel; it used to be
  last-wins.
  [`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
  warns once per session when `fun` collapses rows. Pass
  `fun = dplyr::last` for the old numeric behaviour. Non-numeric columns
  take the first value regardless of `fun`.

- **[`aes()`](https://ggplot2.tidyverse.org/reference/aes.html) mappings
  for `x`, `y`, `group` and `subgroup` are ignored, with a warning.**
  They are derived from the atlas geometry, so mapping them corrupted
  the rendering silently.

- **Polygon draw order follows your data’s row order** (later rows on
  top); regions you supply no value for stay underneath in atlas order.
  [`arrange()`](https://dplyr.tidyverse.org/reference/arrange.html) your
  data to control layering. Visual-only, but it restacks overlapping
  outlines ([\#162](https://github.com/ggsegverse/ggseg/issues/162)).

- **[`position_brain()`](https://ggsegverse.github.io/ggseg/reference/position_brain.md)
  ignores the `hemi` term for slice-based atlases** (subcortical,
  cerebellar, tract), with a warning. Those views are whole slices
  containing both hemispheres. Plots using `hemi ~ view` lay out
  differently.

- A `"wm"` atlas gets the same axis scales as a subcortical one,
  labelled by view rather than hemisphere.

### New features

- [`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
  and
  [`stat_brain()`](https://ggsegverse.github.io/ggseg/reference/stat_brain.md)
  gain `context_fill`, the colour of the context backdrop (default
  `"grey"`).

- New
  [`brain_layer_data()`](https://ggsegverse.github.io/ggseg/reference/brain_layer_data.md)
  returns a brain plot’s region data whatever the layer order, with
  `context = TRUE` for the backdrop.

- The read-only atlas accessors from `ggseg.formats` are re-exported, so
  [`atlas_palette()`](https://ggsegverse.github.io/ggseg.formats/reference/atlas_palette.html),
  [`atlas_regions()`](https://ggsegverse.github.io/ggseg.formats/reference/atlas_regions.html)
  and their siblings work after
  [`library(ggseg)`](https://ggsegverse.github.io/ggseg/) without
  attaching `ggseg.formats`. The atlas-editing verbs stay in
  `ggseg.extra`. Requires `ggseg.formats (>= 0.0.4.9015)`
  ([\#183](https://github.com/ggsegverse/ggseg/issues/183)).

- [`stat_brain()`](https://ggsegverse.github.io/ggseg/reference/stat_brain.md)
  and `StatBrain`: the stat-first spelling of
  [`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md).

- [`brain_test_plot()`](https://ggsegverse.github.io/ggseg/reference/brain_test_plot.md)
  builds a minimal, deterministic atlas plot – the canonical
  construction for `vdiffr` snapshots across the ggsegverse.

- `GeomBrainSf` is exported.

### Bug fixes

- A mapped `fill` no longer colours the context backdrop.
  `aes(fill = label)` used to paint the whole silhouette as one enormous
  parcel, because context rows carry a `label` but no `region`
  ([\#182](https://github.com/ggsegverse/ggseg/issues/182)).

- [`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
  draws an atlas’s context behind its structures, whatever order the
  atlas stores its geometry in. An atlas built with its context last hid
  every structure under a grey silhouette
  ([\#181](https://github.com/ggsegverse/ggseg/issues/181)).

- Colour is resolved when the atlas is drawn, not read from what it
  stores, via
  [`ggseg.formats::atlas_plot_palette()`](https://ggsegverse.github.io/ggseg.formats/reference/atlas_plot_palette.html).
  An atlas shipping no palette drew every region in the same ink.

- A bare
  [`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
  colours the atlas by its palette, keyed on `label`. The default is
  installed at build time, so a top-level `aes(fill = value)` wins
  instead of erroring.

- Faceting no longer needs
  [`dplyr::group_by()`](https://dplyr.tidyverse.org/reference/group_by.html):
  the geometry is drawn by `StatBrain`, which ggplot2 recomputes per
  panel.

- [`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
  respects `data` and aesthetics set in the top-level
  [`ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html) call
  ([\#158](https://github.com/ggsegverse/ggseg/issues/158)), maps
  `aes(colour = )` and `aes(linewidth = )` to region outlines
  ([\#160](https://github.com/ggsegverse/ggseg/issues/160)), and warns
  when rows of your `data` match no region
  ([\#121](https://github.com/ggsegverse/ggseg/issues/121)).

- [`scale_x_brain()`](https://ggsegverse.github.io/ggseg/reference/scale_continous_brain.md),
  [`scale_y_brain()`](https://ggsegverse.github.io/ggseg/reference/scale_continous_brain.md)
  and
  [`scale_labs_brain()`](https://ggsegverse.github.io/ggseg/reference/scale_continous_brain.md)
  no longer require the optional `sf`; they read coordinates from the
  polygon representation. Breaks and labels are unchanged.

- `geom_brain(position = )` applies a layout string or formula;
  previously only a
  [`position_brain()`](https://ggsegverse.github.io/ggseg/reference/position_brain.md)
  spec took effect and anything else was silently dropped.

- Axis scales work for cerebellar atlases such as
  [`suit()`](https://ggsegverse.github.io/ggseg.formats/reference/suit.html);
  unsupported types now error rather than producing empty scales.

- [`scale_continous_brain()`](https://ggsegverse.github.io/ggseg/reference/scale_continous_brain.md)
  returns a scale with breaks at its default `aesthetics`.

- `position_brain(views = )` and `reposition_brain(views = )` error with
  the atlas’s available views when none of the requested views exist,
  and warn on individual views the atlas lacks.
  `position_brain(zoom = )` warns on regions the atlas lacks;
  `zoom = TRUE` resolves its focus from `label` before `region`.

- `position_brain(hemi ~ view, nrow = 2)` errors instead of silently
  discarding the formula, and `nrow`/`ncol` must be positive whole
  numbers. A `nrow`/`ncol` grid on a cortical atlas gives each
  hemisphere/view pair its own cell.

- A layout formula variable containing a dot (e.g. `my.col ~ view`) is
  no longer dropped.

- [`annotate_brain()`](https://ggsegverse.github.io/ggseg/reference/annotate_brain.md)
  accepts a layout string or formula without requiring `sf`.

- [`scale_brain()`](https://ggsegverse.github.io/ggseg/reference/scale_brain.md)
  and friends error with the available atlas names when `name` is not an
  atlas.

- The deprecated `scale_*_brain()` scales warn at build time when no
  mapped value is a palette key.

- [`brain_test_plot()`](https://ggsegverse.github.io/ggseg/reference/brain_test_plot.md)
  reports why an atlas it rejects is invalid.

- Laying out a data frame that mixes atlas types errors with an
  explanation.

### Documentation and internals

- Roxygen documentation uses markdown.

- Tests, examples and vignettes resolve region names through
  [`ggseg.formats::atlas_regions()`](https://ggsegverse.github.io/ggseg.formats/reference/atlas_regions.html)
  and the schema-stable `label` rather than hard-coding them;
  `positioning-views.Rmd` no longer uses names no atlas has.

- `vdiffr` snapshots are keyed by atlas schema through testthat’s
  `variant` mechanism.

- The test helpers no longer attach Suggests packages unconditionally,
  so the suite degrades to skips under `_R_CHECK_DEPENDS_ONLY_=true`.

## ggseg 2.2.1

CRAN release: 2026-07-03

- The test suite now builds its `sf` fixtures through the public atlas
  accessors instead of reaching into atlas internals, so tests no longer
  break when the internal atlas layout changes.

## ggseg 2.2.0

CRAN release: 2026-06-22

This release makes the **`sf` package optional**. ggseg now draws brains
from a lightweight polygon representation by default, so it installs and
plots even on systems where `sf` (and its GDAL / GEOS / PROJ system
libraries) is unavailable — including WebAssembly and air-gapped setups.

### sf is now optional

- **Your plotting code keeps working, without sf.**
  [`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md),
  [`position_brain()`](https://ggsegverse.github.io/ggseg/reference/position_brain.md),
  and
  [`annotate_brain()`](https://ggsegverse.github.io/ggseg/reference/annotate_brain.md)
  produce the same figures as before, now drawn without `sf`. `sf` has
  moved from Imports to Suggests.
- **Need the full sf toolkit?** To add region labels with
  [`geom_sf_label()`](https://ggplot2.tidyverse.org/reference/ggsf.html),
  layer other sf geoms, or wrangle the geometry directly, convert an
  atlas with
  [`as_sf_atlas()`](https://ggsegverse.github.io/ggseg.formats/reference/as_sf_atlas.html)
  and use
  [`ggplot2::geom_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html).
  See
  [`vignette("geom-sf")`](https://ggsegverse.github.io/ggseg/articles/geom-sf.md).
- The sf-backed
  [`geom_brain_sf()`](https://ggsegverse.github.io/ggseg/reference/geom_brain_sf.md)
  and
  [`position_brain_sf()`](https://ggsegverse.github.io/ggseg/reference/position_brain_sf.md)
  remain for a transition period but are deprecated and will be removed
  in a future release.

### New plotting features

- **Zoom in on regions of interest.** `position_brain(zoom = ...)` crops
  each view onto the regions you’re highlighting so they fill the panel,
  with the surrounding brain reduced to a tidy grey frame. Use
  `zoom = TRUE` to follow the regions in your data, or name them
  explicitly; `zoom_pad` sets the margin. Especially handy for focus
  atlases where only a few structures carry values.
- **Readable view labels.**
  [`annotate_brain()`](https://ggsegverse.github.io/ggseg/reference/annotate_brain.md)
  now places labels clear of the brain instead of on top of it. The new
  `padding` argument (5% of the plot height by default) controls the
  gap.
- **One annotation function.**
  [`annotate_brain()`](https://ggsegverse.github.io/ggseg/reference/annotate_brain.md)
  works with whichever `position` you gave the geom — there’s no
  separate labelling function to remember.
- **Hide context regions.** `geom_brain(context = FALSE)` drops the
  grey, unlabelled regions and tightens the layout around the regions
  you’re plotting.
- **Faceting.** Group your data with
  [`dplyr::group_by()`](https://dplyr.tidyverse.org/reference/group_by.html)
  and
  [`facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html)
  /
  [`facet_grid()`](https://ggplot2.tidyverse.org/reference/facet_grid.html)
  draw the full atlas in every panel.
- **FreeSurfer labels.** Data keyed by `label` (e.g. `"lh_bankssts"`)
  now joins to the atlas directly, in addition to `region`.

### Other changes

- When no `fill` is mapped,
  [`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
  fills regions with the atlas’s own colours, and the stray “No shared
  levels” warning that appeared when filtering by hemisphere or view is
  gone.
- New
  [`coord_brain()`](https://ggsegverse.github.io/ggseg/reference/coord_brain.md)
  keeps brain proportions undistorted;
  [`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
  applies it automatically, so you rarely need to add it yourself.
- The deprecated
  [`scale_brain()`](https://ggsegverse.github.io/ggseg/reference/scale_brain.md)
  family keeps working with the current `ggseg.formats`.
- The `suit` cerebellar atlas is re-exported alongside
  [`dk()`](https://ggsegverse.github.io/ggseg.formats/reference/dk.html),
  [`aseg()`](https://ggsegverse.github.io/ggseg.formats/reference/aseg.html),
  and
  [`tracula()`](https://ggsegverse.github.io/ggseg.formats/reference/tracula.html).

## ggseg 2.1.1

CRAN release: 2026-04-16

- Fix minor bug with ggproto

## ggseg 2.1.0

CRAN release: 2026-04-03

- Support cerebellar atlas type in 2D view stacking. Cerebellar atlases
  now use the same stacking layout as subcortical atlases in
  [`position_brain()`](https://ggsegverse.github.io/ggseg/reference/position_brain.md).

## ggseg 2.0.0

CRAN release: 2026-02-19

This is a major release that simplifies the package architecture by
moving atlas data structures and utilities to the
[ggseg.formats](https://github.com/ggsegverse/ggseg.formats) package.

### Breaking changes

- [`ggseg()`](https://ggsegverse.github.io/ggseg/reference/ggseg.md) is
  now defunct and errors immediately. Use `ggplot() + geom_brain()`
  instead.

- Atlas data (`dk`, `aseg`) is no longer bundled in ggseg. Atlases are
  now provided by ggseg.formats and re-exported as functions:
  [`dk()`](https://ggsegverse.github.io/ggseg.formats/reference/dk.html),
  [`aseg()`](https://ggsegverse.github.io/ggseg.formats/reference/aseg.html),
  [`tracula()`](https://ggsegverse.github.io/ggseg.formats/reference/tracula.html).
  Code using the bare objects (e.g., `atlas = dk`) must be updated to
  `atlas = dk()`.

- The following functions have been removed and are now in
  ggseg.formats:
  [`as_brain_atlas()`](https://ggsegverse.github.io/ggseg.formats/reference/as_ggseg_atlas.html),
  [`is_brain_atlas()`](https://ggsegverse.github.io/ggseg.formats/reference/is_ggseg_atlas.html),
  [`brain_atlas()`](https://ggsegverse.github.io/ggseg.formats/reference/ggseg_atlas.html),
  [`brain_regions()`](https://ggsegverse.github.io/ggseg.formats/reference/atlas_regions.html),
  [`brain_labels()`](https://ggsegverse.github.io/ggseg.formats/reference/atlas_labels.html),
  `brain_pal()`, `brain_pals_info()`,
  [`ggseg_atlas()`](https://ggsegverse.github.io/ggseg.formats/reference/ggseg_atlas.html),
  [`as_ggseg_atlas()`](https://ggsegverse.github.io/ggseg.formats/reference/as_ggseg_atlas.html),
  [`is_ggseg_atlas()`](https://ggsegverse.github.io/ggseg.formats/reference/is_ggseg_atlas.html),
  [`read_freesurfer_stats()`](https://ggsegverse.github.io/ggseg.formats/reference/read_freesurfer_stats.html),
  [`read_freesurfer_table()`](https://ggsegverse.github.io/ggseg.formats/reference/read_freesurfer_table.html),
  [`read_atlas_files()`](https://ggsegverse.github.io/ggseg.formats/reference/read_atlas_files.html).

- [`scale_brain2()`](https://ggsegverse.github.io/ggseg/reference/scale_brain2-deprecated.md),
  [`scale_fill_brain2()`](https://ggsegverse.github.io/ggseg/reference/scale_brain2-deprecated.md),
  [`scale_colour_brain2()`](https://ggsegverse.github.io/ggseg/reference/scale_brain2-deprecated.md),
  and
  [`scale_color_brain2()`](https://ggsegverse.github.io/ggseg/reference/scale_brain2-deprecated.md)
  are deprecated in favour of
  [`scale_brain_manual()`](https://ggsegverse.github.io/ggseg/reference/scale_brain_manual.md),
  [`scale_fill_brain_manual()`](https://ggsegverse.github.io/ggseg/reference/scale_brain_manual.md),
  [`scale_colour_brain_manual()`](https://ggsegverse.github.io/ggseg/reference/scale_brain_manual.md),
  and
  [`scale_color_brain_manual()`](https://ggsegverse.github.io/ggseg/reference/scale_brain_manual.md).

- [`scale_brain()`](https://ggsegverse.github.io/ggseg/reference/scale_brain.md),
  [`scale_fill_brain()`](https://ggsegverse.github.io/ggseg/reference/scale_brain.md),
  [`scale_colour_brain()`](https://ggsegverse.github.io/ggseg/reference/scale_brain.md),
  and
  [`scale_color_brain()`](https://ggsegverse.github.io/ggseg/reference/scale_brain.md)
  are deprecated. Atlas palettes are now applied automatically by
  [`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md).

- The `side` argument in
  [`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
  and
  [`position_brain()`](https://ggsegverse.github.io/ggseg/reference/position_brain.md)
  has been renamed to `view`.

### New features

- New
  [`annotate_brain()`](https://ggsegverse.github.io/ggseg/reference/annotate_brain.md)
  function adds view labels (e.g., “left lateral”) to brain plots,
  respecting the layout from
  [`position_brain()`](https://ggsegverse.github.io/ggseg/reference/position_brain.md).

- New
  [`scale_brain_manual()`](https://ggsegverse.github.io/ggseg/reference/scale_brain_manual.md)
  family for applying custom named colour palettes to brain plots.

- [`position_brain()`](https://ggsegverse.github.io/ggseg/reference/position_brain.md)
  gains `nrow`, `ncol`, and `views` arguments for grid-based layout
  control of subcortical and tract atlases.

- `adapt_scales()` now accepts atlas objects directly (not just
  pre-converted coordinate data frames), and handles `"tract"` atlas
  types alongside subcortical.

- [`geom_brain()`](https://ggsegverse.github.io/ggseg/reference/ggbrain.md)
  now automatically applies the atlas colour palette when no `fill`
  aesthetic is mapped.

### Improvements

- Messaging uses cli for all user-facing output
  ([`brain_join()`](https://ggsegverse.github.io/ggseg/reference/brain_join.md)
  warnings and info messages).

- Rewrote and reorganised all vignettes with updated examples and
  renamed files for cleaner URLs.

- Added tracula (white matter tract) atlas as a re-export from
  ggseg.formats.

- Improved documentation throughout with updated roxygen2 docs.

## ggseg 1.6

#### ggseg 1.6.8

- Increased C++ standard to C++17 to comply with CRAN policies

### ggseg 1.6.7

- Fixed testthat issues with latest version of testthat
- Fixed vignette build issues on CRAN
- removed sf minimum version requirement

### ggseg 1.6.5

- Bump version to 1.6.5
- rm freesurfer dep
- rm old remnants
- update readme img
- switch cerebellum labels for wm, gm, fix
  [\#80](https://github.com/ggsegverse/ggseg/issues/80)
- fix aseg labels to original, fix
  [\#78](https://github.com/ggsegverse/ggseg/issues/78)
- add vis as categorical. fix
  [\#76](https://github.com/ggsegverse/ggseg/issues/76)
- change aseg data class , fix
  [\#56](https://github.com/ggsegverse/ggseg/issues/56)
- bump version, small CRAN fixes
- add sysreq
- fix axial to coronal in vignette
- change axial to coronal in aseg data
- re-add ggplot2 depends

### 1.6.4

- Added options `hemi` and `side` to geom
- improved
  [`position_brain()`](https://ggsegverse.github.io/ggseg/reference/position_brain.md)
  to accept character vector, and also support subcortical atlases
- Altered axial to coronal in aseg atlas

### 1.6.3.01

- fixed broken geom after changes to ggplot2 internals
- fixed spelling mistakes in docs

### ggseg 1.6.3

- removed function to display ggseg palettes
- preparations for CRAN submission
  - added examples to more functions
  - updated links

### ggseg 1.6.02

- bug fixes in atlas objects and method internals
- tests in vdiffr
- vctrs class for polygon ggseg data

### ggseg 1.6.02

- No longer depends on ggplot2, but imports it.
  - as is advised practice
  - users must explicitly load ggplot2 to access further ggplot2
    functions

### ggseg 1.6.01

- fixed installation issues by making sure package depends on R\>3.3 for
  polygon holes.

### ggseg 1.6.00

New large update, many new features. Of particular note is the
introduction of the brain sf geom, which improved speed, and
adaptability of the plots.

- [`ggseg()`](https://ggsegverse.github.io/ggseg/reference/ggseg.md)
  will stay for a while, but is superseded by a simple features geom
- `geom_brain` introduced as a new function to plot the atlas data
  - an sf geom provides a lot of new features to the package
  - more control over display of the slices through
    [`position_brain()`](https://ggsegverse.github.io/ggseg/reference/position_brain.md)
  - improved capabilities for atlases with regions that have holes
- new atlas class `brain_atlas` which contains simple features data
- new functions to allow compatibility between sf and polygon data
- utility functions to use on the atlas data for easy access to
  information
  - [`plot()`](https://rdrr.io/r/graphics/plot.default.html) functions
    for ggseg_atlas and brain_atlas classes for a quick look at atlases
  - `brain_regions` functions to easily extract the unique names of
    regions for an atlas
  - improved `print` method for atlases classes ggseg_atlas and
    brain_atlas

## ggseg 1.5

### ggseg 1.5.5

- dk atlas regions renamed to better reflect correct naming
  - pre central and post central are precentral and postcentral
- dk atlas now also includes the corpus callosum, as the original atlas
  contains

## ggseg 1.5

## ggseg 1.5.4

- dkt renamed to dk
  - the dkt (Desikan-Killiany-Tourville) atlas is not yet available
- atlas columns `area` renamed to `region`
  - to avoid confusion with the calculation of cortical/surface area
- dk atlas region name “medial orbito frontal” changed to “medial
  orbitofrontal”

### ggseg 1.5.3

- Split ggseg, and ggseg3d into two different packages

### ggseg 1.5.2

- Adapted to work with dplyr 0.8.1

### ggseg 1.5.1

- Changed ggseg_atlas-class to have nested columns for easier viewing
  and wrangling

### ggseg 1.5

- Changed atlas.info to function `atlas_info()`

- Changed brain.pal to function `brain_pal()`

- Changed atlas.info to function `atlas_info()`

- Reduced code necessary for `brain_pals_info`

- Simplified `display_brain_pal()`

- Moved palettes of ggsegExtra atlases to ggsegExtra package

- Added a `NEWS.md` file to track changes to the package.

&nbsp;

- Added compatibility with `grouped` data.frames
- Reduced internal atlases, to improve CRAN compatibility
- Added function to install extra atlases from github easily
- Changes vignettes to comply with new functionality
