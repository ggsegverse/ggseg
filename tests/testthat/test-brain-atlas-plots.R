# The permutations render against the minimal fixtures from
# helper-layout-fixtures.R rather than the full atlases: layout is about where
# views land, and the full geometry only made the baselines big enough to push
# the source tarball over CRAN's limit.

describe("position_brain visual", {
  snapshot_each_permutation <- function(atlas_name, atlas_fun, permutations) {
    for (label in names(permutations)) {
      local({
        this_label <- label
        this_position <- permutations[[label]]
        it(paste(atlas_name, this_label), {
          testthat::skip_on_cran()
          expect_brain_doppelganger(
            paste(atlas_name, this_label),
            ggplot() +
              geom_brain(
                atlas = atlas_fun(),
                position = this_position,
                show.legend = FALSE
              )
          )
        })
      })
    }
  }

  snapshot_each_permutation("dk", dk_fixture, cortical_layout_permutations())
  snapshot_each_permutation("aseg", aseg_fixture, slice_layout_permutations())
  snapshot_each_permutation(
    "tracula",
    tracula_fixture,
    tract_layout_permutations()
  )
})
