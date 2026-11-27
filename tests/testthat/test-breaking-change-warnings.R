describe("atlas_schema_variant()", {
  it("names the re-keyed schema when core carries `names`", {
    expect_identical(
      atlas_schema_variant(data.frame(region = "a", display = "A")),
      "schema-display"
    )
  })

  it("names the legacy schema when core carries no `names`", {
    expect_identical(
      atlas_schema_variant(data.frame(region = "a")),
      "schema-legacy"
    )
  })

  it("resolves the installed atlas to one of the two schemas", {
    expect_true(
      atlas_schema_variant() %in% c("schema-display", "schema-legacy")
    )
  })
})

describe("require_snapshot_baselines()", {
  it("passes when the variant has committed baselines", {
    expect_true(require_snapshot_baselines(atlas_schema_variant()))
  })

  it("fails rather than letting visual tests write fresh baselines", {
    expect_failure(
      require_snapshot_baselines("schema-that-was-never-committed"),
      "No committed snapshot baselines"
    )
  })
})

describe("the collapse warning through a built plot", {
  duplicated_data <- function() {
    regs <- rep(sort(unique(ggseg.formats::atlas_regions(dk())))[1:2], each = 2)
    data.frame(region = regs, value = seq_along(regs))
  }

  it("stays silent for a bare atlas plot", {
    # The atlas identity rows that drive the stat are not unique on
    # region/hemi, so the `has_data = FALSE` guard is what keeps a bare
    # geom_brain() from warning. Without it every atlas plot would warn.
    flat <- prepare_polygon_atlas(dk())
    identity_rows <- unique(flat[, atlas_metadata_cols(flat), drop = FALSE])
    expect_gt(anyDuplicated(identity_rows[, c("region", "hemi")]), 0)

    rlang::reset_warning_verbosity("ggseg_collapsed_rows")
    expect_no_warning(
      ggplot2::ggplot_build(ggplot2::ggplot() + geom_brain(atlas = dk())),
      class = "ggseg_collapsed_rows"
    )
  })

  it("fires through a built plot with duplicate region rows", {
    rlang::reset_warning_verbosity("ggseg_collapsed_rows")
    expect_warning(
      ggplot2::ggplot_build(
        ggplot2::ggplot(duplicated_data(), ggplot2::aes(fill = value)) +
          geom_brain(atlas = dk())
      ),
      class = "ggseg_collapsed_rows"
    )
  })
})
