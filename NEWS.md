# ggseg 2.2.0 (development)

## Polygon is now the default renderer

- **`geom_brain()`, `position_brain()`, and `annotate_brain()` now use the
  sf-free polygon renderer.** `geom_brain()` plots the same atlases without
  needing sf, `position_brain()` returns the polygon layout spec (and gains
  per-view `zoom`), and `annotate_brain()` follows whichever `position` you
  give it. The `*_polygon()` names remain as aliases.
- **The sf rendering path is deprecated.** `geom_brain_sf()` and
  `position_brain_sf()` keep the previous sf behaviour for now but warn. For
  an sf workflow, convert the atlas with `as_sf_atlas()` and use
  `ggplot2::geom_sf()` directly (region labels, layering other sf geoms) —
  see `vignette("geom-sf")`.

## Other changes

- Compatibility with the current `ggseg.formats` `atlas_palette()`, which now
  takes an atlas object rather than an atlas name. The deprecated
  `scale_brain()` / `scale_fill_brain()` / `scale_colour_brain()` family
  resolves the atlas name internally so it keeps returning the atlas palette.
- `geom_brain()` now colours by `label` rather than `region` when no `fill`
  aesthetic is supplied. As `atlas$palette` is keyed by label, the no-data
  default is now the atlas's colours (previously all grey), and a spurious
  "No shared levels" scale warning that appeared when filtering by `hemi`
  or `view` no longer occurs.

## sf-optional renderer (experimental)

First step toward making sf an opt-in dependency — see the
[sf-optional milestone](https://github.com/ggsegverse/ggseg/milestone/1)
and [Epic #128](https://github.com/ggsegverse/ggseg/issues/128).

- New `geom_brain_polygon()` renders a brain atlas without `sf`, building
  on `ggplot2::geom_polygon()` over the polygon representation in
  `atlas$data$polygons` (introduced in `ggseg.formats` 0.0.3). Holes
  round-trip through the `subgroup` aesthetic (`grid::pathGrob` even-odd
  fill).
- Renders correctly when paired with `ggseg.formats::as_polygon_atlas()`
  or any atlas carrying a `$data$polygons` slot. The bundled `dk`,
  `aseg`, and `tracula` atlases ship with both `sf` and `polygons` slots,
  so existing `geom_brain()` usage is unchanged.
- Naming convention introduced for the sf-optional milestone: the
  sf-backed family stays `geom_brain()` / `position_brain()` for
  backwards compatibility; the new polygon family is suffixed
  `_polygon`. A follow-up step in the epic will unify under a single
  `geom_brain()` with backend dispatch.
- New `position_brain_polygon()` mirrors `position_brain()` for the
  polygon path. Layouts are applied inside `prepare_polygon_atlas()`
  (not via a ggproto Position) so the `type`/`view`/`hemi` columns the
  layout needs don't get stripped by ggplot2's aesthetic machinery.
  Supports the same `position`/`nrow`/`ncol`/`views` interface — string
  shortcuts (`"horizontal"`, `"vertical"`), formula layouts
  (`hemi ~ view`), and grid sizing.
- New `annotate_brain_polygon()` mirrors `annotate_brain()` for the
  polygon path. Same interface, sf-free implementation.
- New `coord_brain()` fixes the aspect ratio so brain polygons aren't
  stretched by the plotting window, mirroring the role `coord_sf()` plays
  for `geom_brain()`. `geom_brain_polygon()` adds it automatically. Like
  `coord_sf(default = TRUE)`, it registers as a default coord, so a
  user-supplied coord (or several stacked `geom_brain_polygon()` layers)
  replaces it without the "Coordinate system already present" message.
- `position_brain_polygon()` gains a `zoom` argument for per-view zoom —
  useful for focus atlases (e.g. a thalamus atlas where only the thalamus
  carries labels). `zoom = TRUE` crops each view onto its focus regions
  (the regions present in the user `data`, or the atlas's labelled regions
  when no data is supplied); a character vector names them explicitly.
  Context regions become a clean rectangular frame around the focus.
  Cropping uses an sf-free Sutherland–Hodgman polygon clip and a common
  window size, so every view keeps the same allotted cell. `zoom_pad`
  (default 5%) controls the margin.
- `geom_brain_polygon()` gains a `context` argument. With `context = FALSE`
  the grey context regions (atlas rows with no `region` label) are dropped
  and the remaining atlas regions are re-gathered into a tighter layout.
- `geom_brain_polygon()` now colours by `label` (the cross-section merge
  key) when no `fill` aesthetic is supplied, matching the label-keyed
  `atlas$palette`. This removes a spurious "No shared levels" scale warning
  that previously surfaced whenever filtering left no unlabelled rows.
- `geom_brain_polygon()` now supports faceting. Pass grouped data
  (`data = my_data |> dplyr::group_by(group)`) and the full atlas — context
  regions included — is replicated in each `facet_wrap()` panel, mirroring
  `geom_brain()`. The internal polygon-ring grouping was renamed to `.group`
  so a user data column named `group` no longer collides on join.
- `geom_brain_polygon()` data joins now match on `label` as well as
  `region` (and `hemi`), so FreeSurfer label-keyed data (e.g.
  `"lh_bankssts"`) plots without first deriving a `region` column.
- `annotate_brain()` is now a single entry point that picks the renderer
  from its `position`: a `position_brain_polygon()` (the default) labels the
  sf-free polygon path, a `position_brain()` labels the sf path. You no
  longer choose between `annotate_brain()` and `annotate_brain_polygon()` —
  pass the same `position` you gave the geom and labels line up.
- `annotate_brain()` and `annotate_brain_polygon()` gain a `padding`
  argument (fraction of plot height, default 5%) and bottom-anchor their
  labels (`vjust = 0`), so view labels sit clear of the geometry instead of
  overlapping it.

## sf moves to Suggests

- **`sf` moves from Imports to Suggests.** The package can now be
  installed without GDAL / GEOS / PROJ system libraries, enabling
  wasm builds and air-gapped installs.
- `SystemRequirements` dropped from DESCRIPTION (those entries were
  sf's C++17 / GDAL / GEOS / PROJ requirements).
- New internal helper `require_sf()` guards `geom_brain()`,
  `position_brain()`, and `annotate_brain()` at entry. Without sf
  installed, calls to these functions error with a pointer to the
  polygon-path equivalent (`geom_brain_polygon()` etc.).
- Bundled atlases continue to carry both `$data$sf` and
  `$data$polygons`. Users with sf installed see no behavioural change.
- Implicit dispatch: users hitting `geom_brain()` without sf get a
  clear error naming the polygon alternative; polygon-path users are
  unaffected either way.

# ggseg 2.1.1

- Fix minor bug with ggproto

# ggseg 2.1.0

- Support cerebellar atlas type in 2D view stacking. Cerebellar atlases
  now use the same stacking layout as subcortical atlases in
  `position_brain()`.

# ggseg 2.0.0

This is a major release that simplifies the package architecture by moving
atlas data structures and utilities to the
[ggseg.formats](https://github.com/ggsegverse/ggseg.formats) package.

## Breaking changes

- `ggseg()` is now defunct and errors immediately. Use
  `ggplot() + geom_brain()` instead.

- Atlas data (`dk`, `aseg`) is no longer bundled in ggseg. Atlases are now
  provided by ggseg.formats and re-exported as functions: `dk()`, `aseg()`,
  `tracula()`. Code using the bare objects (e.g., `atlas = dk`) must be
  updated to `atlas = dk()`.

- The following functions have been removed and are now in ggseg.formats:
  `as_brain_atlas()`, `is_brain_atlas()`, `brain_atlas()`, `brain_regions()`,
  `brain_labels()`, `brain_pal()`, `brain_pals_info()`, `ggseg_atlas()`,
  `as_ggseg_atlas()`, `is_ggseg_atlas()`, `read_freesurfer_stats()`,
  `read_freesurfer_table()`, `read_atlas_files()`.

- `scale_brain2()`, `scale_fill_brain2()`, `scale_colour_brain2()`, and
  `scale_color_brain2()` are deprecated in favour of `scale_brain_manual()`,
  `scale_fill_brain_manual()`, `scale_colour_brain_manual()`, and
  `scale_color_brain_manual()`.

- `scale_brain()`, `scale_fill_brain()`, `scale_colour_brain()`, and
  `scale_color_brain()` are deprecated. Atlas palettes are now applied
  automatically by `geom_brain()`.

- The `side` argument in `geom_brain()` and `position_brain()` has been
  renamed to `view`.

## New features

- New `annotate_brain()` function adds view labels (e.g., "left lateral") to
  brain plots, respecting the layout from `position_brain()`.

- New `scale_brain_manual()` family for applying custom named colour palettes
  to brain plots.

- `position_brain()` gains `nrow`, `ncol`, and `views` arguments for
  grid-based layout control of subcortical and tract atlases.

- `adapt_scales()` now accepts atlas objects directly (not just pre-converted
  coordinate data frames), and handles `"tract"` atlas types alongside
  subcortical.

- `geom_brain()` now automatically applies the atlas colour palette when no
  `fill` aesthetic is mapped.

## Improvements

- Messaging uses cli for all user-facing output (`brain_join()` warnings and
  info messages).

- Rewrote and reorganised all vignettes with updated examples and renamed
  files for cleaner URLs.

- Added tracula (white matter tract) atlas as a re-export from ggseg.formats.

- Improved documentation throughout with updated roxygen2 docs.

# ggseg 1.6

### ggseg 1.6.8

- Increased C++ standard to C++17 to comply with CRAN policies

## ggseg 1.6.7

- Fixed testthat issues with latest version of testthat
- Fixed vignette build issues on CRAN
- removed sf minimum version requirement

## ggseg 1.6.5

- Bump version to 1.6.5
- rm freesurfer dep
- rm old remnants
- update readme img
- switch cerebellum labels for wm, gm, fix #80
- fix aseg labels to original, fix #78
- add vis as categorical. fix #76
- change aseg data class , fix #56
- bump version, small CRAN fixes
- add sysreq
- fix axial to coronal in vignette
- change axial to coronal in aseg data
- re-add ggplot2 depends\n\n

## 1.6.4

- Added options `hemi` and `side` to geom
- improved `position_brain()` to accept character vector, and also support subcortical atlases
- Altered axial to coronal in aseg atlas

## 1.6.3.01

- fixed broken geom after changes to ggplot2 internals
- fixed spelling mistakes in docs

## ggseg 1.6.3

- removed function to display ggseg palettes
- preparations for CRAN submission
  - added examples to more functions
  - updated links

## ggseg 1.6.02

- bug fixes in atlas objects and method internals
- tests in vdiffr
- vctrs class for polygon ggseg data

## ggseg 1.6.02

- No longer depends on ggplot2, but imports it.
  - as is advised practice
  - users must explicitly load ggplot2 to access further ggplot2 functions

## ggseg 1.6.01

- fixed installation issues by making sure package depends on R>3.3 for polygon holes.

## ggseg 1.6.00

New large update, many new features.
Of particular note is the introduction of the brain sf geom, which improved speed,
and adaptability of the plots.

- `ggseg()` will stay for a while, but is superseded by a simple features geom
- `geom_brain` introduced as a new function to plot the atlas data
  - an sf geom provides a lot of new features to the package
  - more control over display of the slices through `position_brain()`
  - improved capabilities for atlases with regions that have holes
- new atlas class `brain_atlas` which contains simple features data
- new functions to allow compatibility between sf and polygon data
- utility functions to use on the atlas data for easy access to information
  - `plot()` functions for ggseg_atlas and brain_atlas classes for a quick look at atlases
  - `brain_regions` functions to easily extract the unique names of regions for an atlas
  - improved `print` method for atlases classes ggseg_atlas and brain_atlas

# ggseg 1.5

## ggseg 1.5.5

- dk atlas regions renamed to better reflect correct naming
  - pre central and post central are precentral and postcentral
- dk atlas now also includes the corpus callosum, as the original atlas contains

# ggseg 1.5

# ggseg 1.5.4

- dkt renamed to dk
  - the dkt (Desikan-Killiany-Tourville) atlas is not yet available
- atlas columns `area` renamed to `region`
  - to avoid confusion with the calculation of cortical/surface area
- dk atlas region name "medial orbito frontal" changed to "medial orbitofrontal"

## ggseg 1.5.3

- Split ggseg, and ggseg3d into two different packages

## ggseg 1.5.2

- Adapted to work with dplyr 0.8.1

## ggseg 1.5.1

- Changed ggseg_atlas-class to have nested columns for easier viewing and wrangling

## ggseg 1.5

- Changed atlas.info to function `atlas_info()`
- Changed brain.pal to function `brain_pal()`
- Changed atlas.info to function `atlas_info()`
- Reduced code necessary for `brain_pals_info`
- Simplified `display_brain_pal()`
- Moved palettes of ggsegExtra atlases to ggsegExtra package

- Added a `NEWS.md` file to track changes to the package.
<!-- # * Changes all `data` options to `.data` to decrease possibility of column naming overlap -->
- Added compatibility with `grouped` data.frames
- Reduced internal atlases, to improve CRAN compatibility
- Added function to install extra atlases from github easily
- Changes vignettes to comply with new functionality
