# Minimal atlases for the layout snapshots ----
#
# The `position_brain()` snapshots assert how views are *arranged*, not what the
# regions look like. Rendering the full bundled atlases made those baselines
# 7.3 MB, which pushed the source tarball past CRAN's 5 MB limit (R CMD check
# does not police it: `tests/` is not installed). The permutations therefore
# render against subsetted atlases built here at test time -- no committed
# binary fixtures, no hand-rolled geometry, so the coordinate frames and view
# structure stay those of the real atlases.
#
# Every view is retained, because views are what layout arranges. Within each
# view a couple of regions per hemisphere are kept, so each panel is populated
# and left/right stay distinguishable. The contextual silhouettes (`cortex`,
# `cortex_`) are dropped: they carry most of the vertices -- 85% of tracula's --
# and no layout information.
#
# `test-layout-fixtures.R` asserts both of those properties and that the
# permutations still render to distinct layouts, which is what keeps the
# smaller fixtures from making the snapshots vacuous.

#' Labels to keep in a layout fixture
#'
#' The first `n_per_view` labels, by sorted label, for every (view, hemisphere)
#' pair the atlas draws. Sorting makes the choice deterministic across runs.
#' Regions with no `hemi` (aseg's midline structures) form their own group.
#' Contextual geometry has no `core` row, hence no `region`, and is excluded.
#'
#' @param atlas A `ggseg_atlas`.
#' @param n_per_view Labels to keep per view per hemisphere.
#' @return Sorted character vector of labels.
layout_fixture_labels <- function(atlas, n_per_view = 2L) {
  flat <- prepare_polygon_atlas(atlas)
  key <- unique(flat[!is.na(flat$region), c("view", "hemi", "label")])
  key$hemi[is.na(key$hemi)] <- ".nohemi"
  picks <- lapply(
    split(key$label, list(key$view, key$hemi), drop = TRUE),
    function(labels) utils::head(sort(unique(labels)), n_per_view)
  )
  sort(unique(unlist(picks, use.names = FALSE)))
}

#' Escape a string for use as a literal in a regular expression
#'
#' `atlas_region_keep()` matches with [grepl()], and atlas labels carry regex
#' metacharacters (`acomm.bbr.prep`, `Left-Thalamus`). Anchoring an alternation
#' of escaped labels makes the match exact, so it cannot silently keep a region
#' the fixture did not ask for -- or match nothing and warn.
#'
#' @param x Character vector.
#' @return `x` with every non-alphanumeric character backslash-escaped.
layout_fixture_escape <- function(x) {
  gsub("([^[:alnum:]_-])", "\\\\\\1", x)
}

#' Subset an atlas to a minimal layout fixture
#'
#' @param atlas A `ggseg_atlas`.
#' @param n_per_view Regions to keep per view per hemisphere.
#' @return A `ggseg_atlas` with every view of `atlas`, a few regions in each,
#'   and no contextual geometry.
layout_fixture <- function(atlas, n_per_view = 2L) {
  labels <- layout_fixture_labels(atlas, n_per_view)
  pattern <- paste0(
    "^(",
    paste(layout_fixture_escape(labels), collapse = "|"),
    ")$"
  )
  ggseg.formats::atlas_context_remove(
    ggseg.formats::atlas_region_keep(atlas, pattern, match_on = "label")
  )
}

layout_fixture_cache <- new.env(parent = emptyenv())

#' Build a layout fixture once per session
#'
#' Subsetting walks the whole atlas geometry, and the layout snapshots ask for
#' the same three fixtures repeatedly.
#'
#' @param name Cache key.
#' @param atlas_fun Zero-argument function returning the source atlas.
#' @return The cached `ggseg_atlas`.
layout_fixture_cached <- function(name, atlas_fun) {
  if (!exists(name, envir = layout_fixture_cache, inherits = FALSE)) {
    assign(name, layout_fixture(atlas_fun()), envir = layout_fixture_cache)
  }
  get(name, envir = layout_fixture_cache, inherits = FALSE)
}

#' @rdname layout_fixture
dk_fixture <- function() {
  layout_fixture_cached("dk", ggseg.formats::dk)
}

#' @rdname layout_fixture
aseg_fixture <- function() {
  layout_fixture_cached("aseg", ggseg.formats::aseg)
}

#' @rdname layout_fixture
tracula_fixture <- function() {
  layout_fixture_cached("tracula", ggseg.formats::tracula)
}

#' Where a layout puts each hemisphere/view group
#'
#' `layout_cell_offsets()` centres every group inside a uniform cell, so a
#' group's centre is exactly its cell's centre -- unlike its minimum
#' coordinates, which also carry the group's own size. Keying the centres by
#' group makes the signature sensitive to the order groups are placed in as
#' well as to the shape of the grid, so two permutations with the same
#' signature would render the same snapshot. The groups are the ones the layout
#' itself uses: hemisphere/view pairs for a cortical atlas, views alone for a
#' slice-based one, whose views already hold both hemispheres.
#'
#' @param atlas A `ggseg_atlas`.
#' @param position A `position_brain()` spec.
#' @return A data.frame of `group`, `x` and `y` cell centres, ordered by group.
layout_cells <- function(atlas, position) {
  flat <- prepare_polygon_atlas(atlas, position = position)
  flat$.cell <- if (identical(flat$type[1], "cortical")) {
    paste(flat$hemi, flat$view)
  } else {
    flat$view
  }
  cells <- lapply(split(flat, flat$.cell), function(d) {
    data.frame(
      group = d$.cell[1],
      x = round((min(d$x) + max(d$x)) / 2, 4),
      y = round((min(d$y) + max(d$y)) / 2, 4)
    )
  })
  cells <- do.call(rbind, cells)
  cells[order(cells$group), , drop = FALSE]
}

#' @rdname layout_cells
layout_signature <- function(atlas, position) {
  cells <- layout_cells(atlas, position)
  paste(sprintf("%s:%s,%s", cells$group, cells$x, cells$y), collapse = "|")
}

#' The `position_brain()` permutations the snapshots cover, per layout family
#'
#' Two families, because `position_formula()` and `split_data_string()` branch
#' on `cortical` versus everything else; subcortical, tract and cerebellar
#' atlases share one path.
#'
#' @return A named list of `position_brain()` specs.
cortical_layout_permutations <- function() {
  list(
    "default horizontal" = position_brain("horizontal"),
    "hemi ~ view" = position_brain(hemi ~ view),
    "view ~ hemi" = position_brain(view ~ hemi),
    "rows hemi+view" = position_brain(hemi + view ~ .),
    "cols hemi+view" = position_brain(. ~ hemi + view),
    "vertical" = position_brain("vertical"),
    "custom view order" = position_brain(c(
      "right lateral",
      "right medial",
      "left lateral",
      "left medial"
    ))
  )
}

#' @param ncol Columns for the `ncol` permutation. `split_data_grid()` derives
#'   the missing dimension, so `nrow = 2` and `ncol = 3` describe the same grid
#'   whenever the atlas has 5 or 6 views -- tracula has 5. Each atlas therefore
#'   needs an `ncol` that does not collapse onto `nrow = 2` for its view count,
#'   or the two permutations assert nothing (see `test-layout-fixtures.R`).
#' @rdname cortical_layout_permutations
slice_layout_permutations <- function(ncol = 3) {
  permutations <- list(
    position_brain("horizontal"),
    position_brain("vertical"),
    position_brain(nrow = 2),
    position_brain(ncol = ncol),
    position_brain(type ~ .)
  )
  stats::setNames(
    permutations,
    c(
      "default horizontal",
      "vertical",
      "nrow 2",
      paste("ncol", ncol),
      "type rows"
    )
  )
}

#' @rdname cortical_layout_permutations
tract_layout_permutations <- function() {
  slice_layout_permutations(ncol = 2)
}
