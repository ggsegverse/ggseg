# Every fixture elsewhere in this suite is a current S7 atlas, so nothing here
# would notice a public function that only works on one. All 32 atlas packages
# still ship the plain tagged list a pre-3.0.0 ggseg.formats built, and three
# real bugs have reached users through exactly that gap. These tests drive a
# legacy list atlas through every public entry point that takes an atlas and
# insist it comes out the same as the S7 object does -- not merely that it does
# not error.

# The representation a pre-3.0.0 atlas package ships: the S7 object's
# properties as a plain tagged list, with the old S3 class vector.
legacy_atlas <- function(atlas = ggseg.formats::dk()) {
  structure(
    as.list(atlas),
    class = c(
      paste0(ggseg.formats::atlas_type(atlas), "_atlas"),
      "ggseg_atlas",
      "list"
    )
  )
}

# A legacy list whose core breaks an invariant the current class enforces
# (`hemi` is a closed vocabulary). The upgrade must reject it at the boundary.
stale_legacy_atlas <- function(atlas = ggseg.formats::dk()) {
  out <- legacy_atlas(atlas)
  out$core$hemi[1] <- "vermis"
  out
}

# One place to say "the legacy and S7 paths agree", so each entry point below
# reads as the one line it is.
expect_same_for_legacy <- function(f, atlas = ggseg.formats::dk()) {
  testthat::expect_identical(f(legacy_atlas(atlas)), f(atlas))
}

atlas_fixtures <- function() {
  list(
    cortical = ggseg.formats::dk(),
    subcortical = ggseg.formats::aseg(),
    tract = ggseg.formats::tracula()
  )
}

describe("a legacy list atlas is not already current", {
  it("needs the upgrade, so these tests exercise it", {
    # If this ever became TRUE the comparisons below would pass vacuously:
    # the two paths would be handed the same object.
    expect_false(
      ggseg.formats::atlas_schema_is_current(legacy_atlas())
    )
  })
})

describe("geom_brain() takes a legacy list atlas", {
  for (type in names(atlas_fixtures())) {
    local({
      atlas <- atlas_fixtures()[[type]]
      it(paste("draws a", type, "atlas identically to the S7 object"), {
        expect_same_for_legacy(
          function(x) {
            muffle_breaking_warnings(
              brain_layer_data(ggplot2::ggplot() + geom_brain(atlas = x))
            )
          },
          atlas
        )
      })
    })
  }

  it("draws the context backdrop identically", {
    expect_same_for_legacy(function(x) {
      brain_layer_data(
        ggplot2::ggplot() + geom_brain(atlas = x),
        context = TRUE
      )
    })
  })

  it("joins user data onto a legacy atlas identically", {
    user_data <- data.frame(
      region = sort(unique(ggseg.formats::atlas_regions(dk())))[1:4],
      p = c(0.1, 0.2, 0.3, 0.4)
    )
    expect_same_for_legacy(function(x) {
      muffle_breaking_warnings(
        brain_layer_data(
          ggplot2::ggplot() +
            geom_brain(atlas = x, data = user_data, ggplot2::aes(fill = p))
        )
      )
    })
  })

  it("upgrades silently", {
    expect_no_message(geom_brain(atlas = legacy_atlas()))
    expect_no_warning(geom_brain(atlas = legacy_atlas()))
  })
})

describe("stat_brain() takes a legacy list atlas", {
  it("draws identically to the S7 object", {
    expect_same_for_legacy(function(x) {
      muffle_breaking_warnings(
        brain_layer_data(ggplot2::ggplot() + stat_brain(atlas = x))
      )
    })
  })
})

describe("brain_test_plot() takes a legacy list atlas", {
  for (type in names(atlas_fixtures())) {
    local({
      atlas <- atlas_fixtures()[[type]]
      it(paste("renders a", type, "atlas identically"), {
        expect_same_for_legacy(
          function(x) brain_layer_data(brain_test_plot(x)),
          atlas
        )
      })
    })
  }
})

describe("annotate_brain() takes a legacy list atlas", {
  it("places the polygon-path labels identically", {
    # The returned ggproto Layer is never `identical()` to another instance,
    # so the comparison is on what the function actually computed: the label
    # text and positions, and the fixed aesthetics around them.
    expect_same_for_legacy(function(x) {
      layer <- annotate_brain(x)
      list(data = layer$data, aes_params = layer$aes_params)
    })
  })

  it("places the sf-path labels identically", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    position <- position_brain_sf()
    expect_same_for_legacy(function(x) {
      layer <- annotate_brain(x, position = position)
      list(data = layer$data, aes_params = layer$aes_params)
    })
  })
})

describe("brain_join() takes a legacy list atlas", {
  user_data <- data.frame(
    region = sort(unique(ggseg.formats::atlas_regions(ggseg.formats::dk())))[
      1:4
    ],
    p = c(0.1, 0.2, 0.3, 0.4)
  )

  it("joins identically to the S7 object", {
    skip_if_not_installed("sf")
    expect_same_for_legacy(function(x) {
      suppressMessages(brain_join(user_data, x))
    })
  })

  it("joins grouped data identically", {
    skip_if_not_installed("sf")
    grouped <- dplyr::group_by(
      rbind(
        cbind(user_data, grp = "G1"),
        cbind(user_data, grp = "G2")
      ),
      grp
    )
    expect_same_for_legacy(function(x) {
      suppressMessages(brain_join(grouped, x))
    })
  })
})

describe("reposition_brain() takes a legacy list atlas", {
  it("lays the views out identically", {
    skip_if_not_installed("sf")
    expect_same_for_legacy(function(x) reposition_brain(x, hemi ~ view))
  })

  it("lays a slice-based atlas out identically", {
    skip_if_not_installed("sf")
    expect_same_for_legacy(
      function(x) reposition_brain(x, nrow = 2),
      ggseg.formats::aseg()
    )
  })
})

describe("geom_brain_sf() takes a legacy list atlas", {
  it("draws identically to the S7 object", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    expect_same_for_legacy(function(x) {
      ggplot2::layer_data(ggplot2::ggplot() + geom_brain_sf(atlas = x))
    })
  })
})

describe("the axis scales take a legacy list atlas", {
  it("gives scale_x_brain() the same breaks", {
    expect_same_for_legacy(function(x) {
      scale <- scale_x_brain(atlas = x)
      list(breaks = scale$breaks, labels = scale$labels)
    })
  })

  it("gives scale_y_brain() the same breaks", {
    expect_same_for_legacy(function(x) {
      scale <- scale_y_brain(atlas = x)
      list(breaks = scale$breaks, labels = scale$labels)
    })
  })

  it("gives scale_labs_brain() the same labels", {
    expect_same_for_legacy(function(x) scale_labs_brain(atlas = x))
  })

  it("gives a slice-based atlas the same scales", {
    expect_same_for_legacy(
      function(x) adapt_scales(x, aesthetics = "x"),
      ggseg.formats::aseg()
    )
  })
})

describe("the boundary errors survive the upgrade", {
  entry_points <- list(
    geom_brain = function(x) geom_brain(atlas = x),
    stat_brain = function(x) stat_brain(atlas = x),
    brain_test_plot = function(x) brain_test_plot(x),
    annotate_brain = function(x) annotate_brain(x),
    brain_join = function(x) brain_join(data.frame(region = "insula"), x),
    reposition_brain = function(x) reposition_brain(x),
    scale_x_brain = function(x) scale_x_brain(atlas = x),
    scale_labs_brain = function(x) scale_labs_brain(atlas = x)
  )

  for (name in names(entry_points)) {
    local({
      f <- entry_points[[name]]
      it(paste(name, "rejects a non-atlas"), {
        skip_if_not_installed("sf")
        expect_error(f(1), class = "ggseg.formats_not_atlas")
      })

      it(paste(name, "rejects a legacy atlas with a stale core"), {
        skip_if_not_installed("sf")
        expect_error(
          f(stale_legacy_atlas()),
          class = "ggseg.formats_invalid_atlas"
        )
        expect_error(f(stale_legacy_atlas()), "vermis")
      })
    })
  }

  it("geom_brain_sf() keeps both boundary errors", {
    skip_if_not_installed("sf")
    withr::local_options(lifecycle_verbosity = "quiet")
    expect_error(
      geom_brain_sf(atlas = 1),
      class = "ggseg.formats_not_atlas"
    )
    expect_error(
      geom_brain_sf(atlas = stale_legacy_atlas()),
      class = "ggseg.formats_invalid_atlas"
    )
  })
})

describe("the atlas-or-data.frame boundaries still accept a data.frame", {
  it("brain_join() keeps taking a flat atlas data.frame", {
    skip_if_not_installed("sf")
    atlas_df <- as.data.frame(ggseg.formats::dk())
    expect_identical(
      suppressMessages(brain_join(
        data.frame(region = "insula", p = 1),
        atlas_df
      )),
      suppressMessages(brain_join(
        data.frame(region = "insula", p = 1),
        ggseg.formats::dk()
      ))
    )
  })

  it("adapt_scales() keeps taking a flattened data.frame", {
    expect_identical(
      adapt_scales(atlas_scale_coords(ggseg.formats::dk())),
      adapt_scales(legacy_atlas())
    )
  })

  it("reposition_brain() keeps taking a joined sf data.frame", {
    skip_if_not_installed("sf")
    expect_identical(
      reposition_brain(as.data.frame(ggseg.formats::dk()), hemi ~ view),
      reposition_brain(legacy_atlas(), hemi ~ view)
    )
  })
})
