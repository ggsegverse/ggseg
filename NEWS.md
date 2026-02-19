# ggseg 2.0.0

This is a major release that simplifies the package architecture by moving
atlas data structures and utilities to the
[ggseg.formats](https://github.com/ggsegverse/ggseg.formats) package.

## Breaking changes

* `ggseg()` is now defunct and errors immediately. Use
  `ggplot() + geom_brain()` instead.

* Atlas data (`dk`, `aseg`) is no longer bundled in ggseg. Atlases are now
  provided by ggseg.formats and re-exported as functions: `dk()`, `aseg()`,
  `tracula()`. Code using the bare objects (e.g., `atlas = dk`) must be
  updated to `atlas = dk()`.

* The following functions have been removed and are now in ggseg.formats:
  `as_brain_atlas()`, `is_brain_atlas()`, `brain_atlas()`, `brain_regions()`,
  `brain_labels()`, `brain_pal()`, `brain_pals_info()`, `ggseg_atlas()`,
  `as_ggseg_atlas()`, `is_ggseg_atlas()`, `read_freesurfer_stats()`,
  `read_freesurfer_table()`, `read_atlas_files()`.

* `scale_brain2()`, `scale_fill_brain2()`, `scale_colour_brain2()`, and
  `scale_color_brain2()` are deprecated in favour of `scale_brain_manual()`,
  `scale_fill_brain_manual()`, `scale_colour_brain_manual()`, and
  `scale_color_brain_manual()`.

* `scale_brain()`, `scale_fill_brain()`, `scale_colour_brain()`, and
  `scale_color_brain()` are deprecated. Atlas palettes are now applied
  automatically by `geom_brain()`.

* The `side` argument in `geom_brain()` and `position_brain()` has been
  renamed to `view`.

## New features

* New `annotate_brain()` function adds view labels (e.g., "left lateral") to
  brain plots, respecting the layout from `position_brain()`.

* New `scale_brain_manual()` family for applying custom named colour palettes
  to brain plots.

* `position_brain()` gains `nrow`, `ncol`, and `views` arguments for
  grid-based layout control of subcortical and tract atlases.

* `adapt_scales()` now accepts atlas objects directly (not just pre-converted
  coordinate data frames), and handles `"tract"` atlas types alongside
  subcortical.

* `geom_brain()` now automatically applies the atlas colour palette when no
  `fill` aesthetic is mapped.

## Improvements

* Messaging uses cli for all user-facing output (`brain_join()` warnings and
  info messages).

* Rewrote and reorganised all vignettes with updated examples and renamed
  files for cleaner URLs.

* Added tracula (white matter tract) atlas as a re-export from ggseg.formats.

* Improved documentation throughout with updated roxygen2 docs.

# ggseg 1.6

### ggseg 1.6.8

* Increased C++ standard to C++17 to comply with CRAN policies

## ggseg 1.6.7

* Fixed testthat issues with latest version of testthat
* Fixed vignette build issues on CRAN
* removed sf minimum version requirement 

## ggseg 1.6.5

* Bump version to 1.6.5
* rm freesurfer dep
* rm old remnants
* update readme img
* switch cerebellum labels for wm, gm, fix #80
* fix aseg labels to original, fix #78
* add vis as categorical. fix #76
* change aseg data class , fix #56
* bump version, small CRAN fixes
* add sysreq
* fix axial to coronal in vignette
* change axial to coronal in aseg data
* re-add ggplot2 depends\n\n


## 1.6.4
* Added options `hemi` and `side` to geom
* improved `position_brain()` to accept character vector, and also support subcortical atlases
* Altered axial to coronal in aseg atlas

## 1.6.3.01
* fixed broken geom after changes to ggplot2 internals  
* fixed spelling mistakes in docs

## ggseg 1.6.3
* removed function to display ggseg palettes
* preparations for CRAN submission
    * added examples to more functions
    * updated links

## ggseg 1.6.02
* bug fixes in atlas objects and method internals
* tests in vdiffr
* vctrs class for polygon ggseg data

## ggseg 1.6.02

* No longer depends on ggplot2, but imports it.
   * as is advised practice
   * users must explicitly load ggplot2 to access further ggplot2 functions

## ggseg 1.6.01

* fixed installation issues by making sure package depends on R>3.3 for polygon holes.

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

* dkt renamed to dk  
    - the dkt (Desikan-Killiany-Tourville) atlas is not yet available  
* atlas columns `area` renamed to `region`  
    - to avoid confusion with the calculation of cortical/surface area  
* dk atlas region name "medial orbito frontal" changed to "medial orbitofrontal"  

## ggseg 1.5.3
* Split ggseg, and ggseg3d into two different packages

## ggseg 1.5.2
* Adapted to work with dplyr 0.8.1

## ggseg 1.5.1

* Changed ggseg_atlas-class to have nested columns for easier viewing and wrangling

## ggseg 1.5

* Changed atlas.info to function `atlas_info()`
* Changed brain.pal to function `brain_pal()`
* Changed atlas.info to function `atlas_info()`
* Reduced code necessary for `brain_pals_info`
* Simplified `display_brain_pal()`
* Moved palettes of ggsegExtra atlases to ggsegExtra package

* Added a `NEWS.md` file to track changes to the package.
<!-- # * Changes all `data` options to `.data` to decrease possibility of column naming overlap -->
* Added compatibility with `grouped` data.frames
* Reduced internal atlases, to improve CRAN compatibility
* Added function to install extra atlases from github easily
* Changes vignettes to comply with new functionality
