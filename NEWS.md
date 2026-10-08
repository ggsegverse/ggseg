# ggseg 3.0.0

A major release. The atlas geometry now comes from the re-keyed `ggseg.formats`
atlases (`>= 0.0.4.9008`), and `geom_brain()` has been rebuilt on a `Stat` so
that faceting, inherited `data`/`aes()`, and outline aesthetics work the way
ggplot2 users expect. Several of those fixes change existing figures, so read the
breaking changes before upgrading.

## Breaking changes

- **Region keys changed.** `ggseg.formats` re-keyed the bundled atlases: the
  `region` column now holds short keys (e.g. `"superiorparietal"`,
  `"transversetemporal"`) and the fully spelled-out names moved to a new `names`
  column. **Any user data joined to an atlas by `region` must be re-keyed.**
  Passing a long name where a `region` is expected no longer matches, and
  `geom_brain()` warns that the rows were not merged. `ggseg.formats` ships a
  helper for translating old keys to new — look for `legacy_region_map()` in the
  `ggseg.formats` reference — or join by the schema-stable `label` column
  instead. `ggseg` now requires `ggseg.formats (>= 0.0.4.9008)`; the
  combination of an older `ggseg` with the re-keyed atlases is silently wrong,
  which the new floor rules out.

- **A bare `geom_brain()` no longer colours the atlas by its palette.** Up to
  2.2.1 `geom_brain()` injected `fill = .data$label` plus a matching
  `scale_fill_manual()` whenever you mapped no `fill`, so
  `ggplot() + geom_brain(atlas = dk())` came out palette-coloured. It now
  renders grey — the same grey that regions you supply no value for already
  had — and warns once per session. `geom_brain()` is for plotting *your* data
  on the brain; for a palette-coloured overview use `plot(atlas)` (from
  `ggseg.formats`), or map its key yourself with `aes(fill = label)` and
  `scale_fill_brain()`.

- **The injected discrete palette scale is gone.** A side effect of the item
  above. This *fixes* a continuous fill set in the top-level call —
  `ggplot(df, aes(fill = value)) + geom_brain(atlas = dk())` no longer errors
  with "Continuous value supplied to a discrete scale" — but any plot that
  relied on the injected scale now needs its own.

- **`GeomBrain` is a different object.** Both 2.2.1 and 3.0.0 export
  `GeomBrain`, but it is no longer the same ggproto: it is now the polygon geom
  (`GeomBrain` < `ggplot2::GeomPolygon` < `ggplot2::Geom`) that backs the
  default `geom_brain()`. The sf geom it used to be is now `GeomBrainSf`, which
  **this release also exports** so extension code doing
  `ggplot2::layer(geom = GeomBrain)` against the sf path has a migration
  target: switch to `GeomBrainSf`. Because the export name did not change, the
  failure mode in extension code is a confusing rendering error rather than an
  object-not-found error — check any package that reaches for `GeomBrain`
  directly.

- **`geom_brain()` gained a `fun` argument, positionally before
  `show.legend`.** The signature is now
  `geom_brain(mapping, data, atlas, hemi, view, position, context, fun,
  show.legend, inherit.aes, ...)`. Callers passing `show.legend` or
  `inherit.aes` positionally shift by one — name those arguments.

- **Multiple `data` rows per region are now combined, not overplotted.** `fun`
  (default `mean`) reduces them within each facet panel. Long data with several
  rows per region — one per subject, say — used to overplot, so the last row
  silently won; it is now averaged. This is a silent numeric change for anyone
  plotting an unaggregated cohort, so `geom_brain()` warns once per session when
  `fun` actually collapses rows. Pass `fun = dplyr::last` to recover the old
  last-wins behaviour. `fun` applies to numeric columns only — non-numeric
  columns take the first value of the group regardless.

- **`aes()` mappings for `x`, `y`, `group`, and `subgroup` are ignored, with a
  warning.** They are derived from the atlas geometry (`group` is the polygon
  feature id, `subgroup` marks holes), so mapping them previously corrupted the
  rendering silently — `aes(group = region)` collapsed each region's separate
  polygon pieces.

- **Polygon draw order now follows your data's row order.** The renderer used to
  force alphabetical order, so when you mapped a variable to `colour` the
  outlines stacked in an order unrelated to it. Regions now draw in the order
  they appear in your `data` (later rows on top); regions you supply no value for
  stay underneath in atlas order. `arrange()` your data to control layering.
  Visual-only, but it restacks overlapping outlines (#162).

- **`position_brain()` ignores the `hemi` term for slice-based atlases**
  (subcortical, cerebellar, tract), with a warning. Those views are whole slices
  already containing both hemispheres, so `hemi ~ view` no longer splits the grey
  context into its own row away from the structures. Each view now renders with
  its anatomical context integrated, matching `plot()`. Subcortical and tract
  plots using `hemi ~ view` lay out differently (correctly).

- **Faceting is handled by `StatBrain`, not grouped data frames.** Pre-grouped
  data still works, but `dplyr::group_by()` is no longer needed — see below.

## New features

- New `stat_brain()` and exported `StatBrain` ggproto: the stat-first spelling
  of `geom_brain()`. Both build the same layer; use `stat_brain()` to pair
  `StatBrain` with a different geom.

- New `brain_test_plot()` builds a minimal, deterministic atlas plot (regions
  filled by `label`, no legend, `theme_void()`) — the canonical construction for
  `vdiffr` snapshots across the ggsegverse, so a stray legend or title cannot
  creep into a snapshot and every atlas renders identically. It defaults to
  `position_brain(. ~ view)` for slice-based atlases and
  `position_brain(hemi ~ view)` for cortical ones.

- `GeomBrainSf` is now exported (see above).

## Bug fixes

- Faceting no longer needs `dplyr::group_by()`. The atlas geometry is drawn by
  `StatBrain`, which ggplot2 recomputes per panel, so `facet_wrap()` /
  `facet_grid()` work directly from your data. Faceting on a variable of your own
  draws the complete brain in every panel; faceting on an atlas column (`hemi`,
  `view`) draws that slice in each panel, as before.

- `geom_brain()` again respects `data` and aesthetics set in the top-level
  `ggplot()` call. The polygon renderer built the atlas eagerly, before the plot
  existed, so it never saw inherited `data`/`aes()` (#158).

- `geom_brain()` again maps `aes(colour = ...)` and `aes(linewidth = ...)` to
  region outlines. The defaults (`grey35`, `0.2`) were injected as fixed geom
  parameters, which silently overrode any mapping; they are now `default_aes` on
  `GeomBrain` (#160).

- `geom_brain()` again warns when rows of your `data` match no atlas region. The
  polygon renderer's left join dropped unmatched rows silently (#121).

- `scale_x_brain()`, `scale_y_brain()` and `scale_labs_brain()` no longer
  require the optional `sf` package. They derived their axis breaks by
  converting the atlas to `sf` and reading coordinates back out, so on a system
  without `sf` they errored instead of working -- even though `sf` moved to
  Suggests in 2.2.0 and everything else on the default path had been made
  sf-free. They now read the coordinates from the polygon representation
  (`ggseg.formats::atlas_polygons()`). The breaks and labels are unchanged for
  `dk()`, `aseg()` and `tracula()`; a test pins them to the sf-derived values.

- `geom_brain(position = )` again applies a layout string or formula.
  Previously only a `position_brain()` spec took effect; everything else,
  including an invalid value, was silently dropped. Strings and formulas are
  now coerced, `"identity"` opts out, and anything else errors.

- Axis scales work for cerebellar atlases such as `suit()`. `adapt_scales()`
  returned `NULL` for any type outside cortical/subcortical/tract, so
  `scale_x_brain()` and friends produced empty scales. Unsupported types now
  error.

- `scale_continous_brain()` no longer returns a scale without breaks at its
  default `aesthetics = c("y", "x")`; the argument was matched after it was
  used.

- `position_brain(hemi ~ view, nrow = 2)` now errors instead of silently
  discarding the formula, and `nrow`/`ncol` must be positive whole numbers
  (`ncol = 0` produced `Inf` grid indices).

- A `nrow`/`ncol` grid on a cortical atlas now gives each hemisphere/view pair
  its own cell; it split on `view` alone, putting both hemispheres in every
  cell.

- `position_brain(views = )` warns when a named view is not in the atlas, and
  `zoom = ` warns when a named region is not, instead of silently dropping it.

- A layout formula variable containing a dot (e.g. `my.col ~ view`) is no
  longer dropped along with the `.` placeholder.

- `annotate_brain()` accepts a layout string or formula without requiring the
  optional `sf`; it routed every non-spec `position` into the sf
  implementation.

- `scale_brain()` and friends error with the available atlas names when `name`
  is not an atlas; `match.fun()` resolved any visible function.

- The deprecated `scale_*_brain()` scales warn at build time when no mapped
  value is a palette key. Atlas palettes are keyed by `label`, so
  `aes(fill = region)` drew every region in `na.value` with no signal.

- Laying out a data frame that mixes atlas types now errors with an explanation
  rather than R's "condition has length > 1".

## Documentation and internals

- Roxygen documentation now uses markdown.

- `positioning-views.Rmd` used region and view names no atlas has
  (`"Thalamus Proper"`, `coronal_3`), so three zoom figures and two
  view-selection figures demonstrated nothing.

- Tests, examples, and vignettes resolve region names dynamically through
  `ggseg.formats::atlas_regions()` and the schema-stable `label` column instead
  of hard-coding region strings.

- `vdiffr` snapshots are keyed by atlas schema through testthat's `variant`
  mechanism, so one snapshot set per `ggseg.formats` schema can be committed
  side by side.

- The test helpers no longer attach Suggests packages unconditionally, so the
  suite degrades to skips rather than erroring under
  `_R_CHECK_DEPENDS_ONLY_=true`.

# ggseg 2.2.1

- The test suite now builds its `sf` fixtures through the public atlas
  accessors instead of reaching into atlas internals, so tests no longer
  break when the internal atlas layout changes.

# ggseg 2.2.0

This release makes the **`sf` package optional**. ggseg now draws brains from a
lightweight polygon representation by default, so it installs and plots even on
systems where `sf` (and its GDAL / GEOS / PROJ system libraries) is unavailable
— including WebAssembly and air-gapped setups.

## sf is now optional

- **Your plotting code keeps working, without sf.** `geom_brain()`,
  `position_brain()`, and `annotate_brain()` produce the same figures as
  before, now drawn without `sf`. `sf` has moved from Imports to Suggests.
- **Need the full sf toolkit?** To add region labels with `geom_sf_label()`,
  layer other sf geoms, or wrangle the geometry directly, convert an atlas
  with `as_sf_atlas()` and use `ggplot2::geom_sf()`. See `vignette("geom-sf")`.
- The sf-backed `geom_brain_sf()` and `position_brain_sf()` remain for a
  transition period but are deprecated and will be removed in a future
  release.

## New plotting features

- **Zoom in on regions of interest.** `position_brain(zoom = ...)` crops each
  view onto the regions you're highlighting so they fill the panel, with the
  surrounding brain reduced to a tidy grey frame. Use `zoom = TRUE` to follow
  the regions in your data, or name them explicitly; `zoom_pad` sets the
  margin. Especially handy for focus atlases where only a few structures
  carry values.
- **Readable view labels.** `annotate_brain()` now places labels clear of the
  brain instead of on top of it. The new `padding` argument (5% of the plot
  height by default) controls the gap.
- **One annotation function.** `annotate_brain()` works with whichever
  `position` you gave the geom — there's no separate labelling function to
  remember.
- **Hide context regions.** `geom_brain(context = FALSE)` drops the grey,
  unlabelled regions and tightens the layout around the regions you're
  plotting.
- **Faceting.** Group your data with `dplyr::group_by()` and `facet_wrap()` /
  `facet_grid()` draw the full atlas in every panel.
- **FreeSurfer labels.** Data keyed by `label` (e.g. `"lh_bankssts"`) now joins
  to the atlas directly, in addition to `region`.

## Other changes

- When no `fill` is mapped, `geom_brain()` fills regions with the atlas's own
  colours, and the stray "No shared levels" warning that appeared when
  filtering by hemisphere or view is gone.
- New `coord_brain()` keeps brain proportions undistorted; `geom_brain()`
  applies it automatically, so you rarely need to add it yourself.
- The deprecated `scale_brain()` family keeps working with the current
  `ggseg.formats`.
- The `suit` cerebellar atlas is re-exported alongside `dk()`, `aseg()`, and
  `tracula()`.

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
