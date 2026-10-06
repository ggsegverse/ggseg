describe("layout fixtures", {
  fixture_views <- function(atlas) {
    sort(unique(prepare_polygon_atlas(atlas)$view))
  }

  regions_per_view <- function(atlas) {
    flat <- prepare_polygon_atlas(atlas)
    key <- unique(flat[!is.na(flat$region), c("view", "label")])
    table(key$view)
  }

  it("keeps every view of the source atlas", {
    for (source in list(dk(), aseg(), tracula())) {
      expect_identical(
        fixture_views(layout_fixture(source)),
        fixture_views(source)
      )
    }
  })

  it("keeps at least two regions in every view", {
    for (fixture in list(dk_fixture(), aseg_fixture(), tracula_fixture())) {
      expect_true(all(regions_per_view(fixture) >= 2))
    }
  })

  it("keeps both hemispheres where the source atlas has them", {
    for (fixture in list(dk_fixture(), aseg_fixture(), tracula_fixture())) {
      hemis <- unique(prepare_polygon_atlas(fixture)$hemi)
      expect_true(all(c("left", "right") %in% hemis))
    }
  })

  it("selects labels deterministically", {
    expect_identical(
      layout_fixture_labels(dk()),
      layout_fixture_labels(dk())
    )
    expect_identical(
      ggseg.formats::atlas_labels(dk_fixture()),
      layout_fixture_labels(dk())
    )
  })

  it("drops the contextual silhouettes", {
    flat <- prepare_polygon_atlas(tracula_fixture())
    expect_false(any(is.na(flat$region)))
  })

  it("is a fraction of the source atlas's geometry", {
    for (source in list(dk(), aseg(), tracula())) {
      full <- nrow(prepare_polygon_atlas(source))
      small <- nrow(prepare_polygon_atlas(layout_fixture(source)))
      expect_lt(small, full / 2)
    }
  })

  it("escapes regex metacharacters in labels", {
    expect_identical(
      layout_fixture_escape(c("acomm.bbr.prep", "Left-Thalamus")),
      c("acomm\\.bbr\\.prep", "Left-Thalamus")
    )
  })
})

describe("layout fixtures still discriminate between permutations", {
  # The point of the subsetted fixtures is smaller snapshots, not weaker ones.
  # If two permutations placed the views identically their snapshots would be
  # identical too, and the permutation matrix would be testing nothing.
  signatures <- function(atlas, permutations) {
    vapply(
      permutations,
      function(position) layout_signature(atlas, position),
      character(1)
    )
  }

  it("cortical permutations all lay out differently", {
    sigs <- signatures(dk_fixture(), cortical_layout_permutations())
    expect_identical(anyDuplicated(sigs), 0L)
  })

  it("subcortical permutations all lay out differently", {
    sigs <- signatures(aseg_fixture(), slice_layout_permutations())
    expect_identical(anyDuplicated(sigs), 0L)
  })

  it("tract permutations all lay out differently", {
    sigs <- signatures(tracula_fixture(), tract_layout_permutations())
    expect_identical(anyDuplicated(sigs), 0L)
  })

  it("rejects an ncol that collapses onto nrow = 2", {
    # tracula has 5 views, so `ncol = 3` would describe the same 2x3 grid as
    # `nrow = 2`: the pair that used to be snapshotted asserted nothing.
    sigs <- signatures(tracula_fixture(), slice_layout_permutations(ncol = 3))
    expect_gt(anyDuplicated(sigs), 0L)
  })

  it("renders every permutation to a distinct SVG", {
    testthat::skip_if_not_installed("vdiffr")
    testthat::skip_if_not_installed("withr")
    testthat::skip_on_cran()
    render <- function(atlas, position) {
      path <- withr::local_tempfile(fileext = ".svg")
      muffle_breaking_warnings(
        suppressWarnings(
          vdiffr::write_svg(
            ggplot() +
              geom_brain(
                atlas = atlas,
                position = position,
                show.legend = FALSE
              ),
            path,
            "discrimination"
          )
        )
      )
      paste(readLines(path, warn = FALSE), collapse = "\n")
    }
    cases <- list(
      list(dk_fixture(), cortical_layout_permutations()),
      list(aseg_fixture(), slice_layout_permutations()),
      list(tracula_fixture(), tract_layout_permutations())
    )
    for (case in cases) {
      svgs <- vapply(
        case[[2]],
        function(position) render(case[[1]], position),
        character(1)
      )
      expect_identical(anyDuplicated(svgs), 0L)
    }
  })

  it("lays a cortical atlas out differently from a slice-based one", {
    cortical <- layout_signature(dk_fixture(), position_brain(hemi ~ view))
    slice <- suppressWarnings(
      layout_signature(aseg_fixture(), position_brain(hemi ~ view))
    )
    expect_false(identical(cortical, slice))
  })

  it("warns that hemi is ignored for a slice-based atlas", {
    expect_warning(
      layout_signature(aseg_fixture(), position_brain(hemi ~ view)),
      "ignored for slice-based atlases"
    )
  })

  it("places a cortical atlas in a grid for hemi ~ view", {
    cells <- layout_cells(dk_fixture(), position_brain(hemi ~ view))
    expect_length(unique(cells$y), 2)
    expect_length(unique(cells$x), 4)
  })

  it("places a slice-based atlas in one row for hemi ~ view", {
    cells <- suppressWarnings(
      layout_cells(aseg_fixture(), position_brain(hemi ~ view))
    )
    expect_length(unique(cells$y), 1)
    expect_length(unique(cells$x), 7)
  })
})
