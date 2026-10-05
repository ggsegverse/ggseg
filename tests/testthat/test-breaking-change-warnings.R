describe("atlas_schema_variant()", {
  it("names the re-keyed schema when core carries `names`", {
    expect_identical(
      atlas_schema_variant(data.frame(region = "a", names = "A")),
      "schema-names"
    )
  })

  it("names the legacy schema when core carries no `names`", {
    expect_identical(
      atlas_schema_variant(data.frame(region = "a")),
      "schema-legacy"
    )
  })

  it("resolves the installed atlas to one of the two schemas", {
    expect_true(atlas_schema_variant() %in% c("schema-names", "schema-legacy"))
  })
})

describe("warn_uncoloured_atlas()", {
  bare_plot <- function(...) {
    ggplot2::ggplot_build(
      ggplot2::ggplot() + geom_brain(atlas = dk(), ...)
    )
  }

  it("warns when no fill is mapped or set", {
    rlang::reset_warning_verbosity("ggseg_uncoloured_atlas")
    expect_warning(bare_plot(), class = "ggseg_uncoloured_atlas")
  })

  it("points at plot(atlas) and scale_fill_brain()", {
    rlang::reset_warning_verbosity("ggseg_uncoloured_atlas")
    w <- expect_warning(bare_plot(), class = "ggseg_uncoloured_atlas")
    expect_match(conditionMessage(w), "plot(atlas)", fixed = TRUE)
    expect_match(conditionMessage(w), "scale_fill_brain", fixed = TRUE)
  })

  it("stays silent when fill is mapped", {
    rlang::reset_warning_verbosity("ggseg_uncoloured_atlas")
    expect_no_warning(bare_plot(mapping = ggplot2::aes(fill = region)))
  })

  it("stays silent when fill is mapped in the top-level ggplot()", {
    rlang::reset_warning_verbosity("ggseg_uncoloured_atlas")
    expect_no_warning(
      ggplot2::ggplot_build(
        ggplot2::ggplot(mapping = ggplot2::aes(fill = region)) +
          geom_brain(atlas = dk())
      )
    )
  })

  it("stays silent when fill is set as a constant", {
    rlang::reset_warning_verbosity("ggseg_uncoloured_atlas")
    expect_no_warning(bare_plot(fill = "steelblue"))
  })

  it("warns only once per session", {
    rlang::reset_warning_verbosity("ggseg_uncoloured_atlas")
    expect_warning(bare_plot(), class = "ggseg_uncoloured_atlas")
    expect_no_warning(bare_plot())
  })
})

describe("warn_collapsed_rows()", {
  duplicated_data <- function() {
    regs <- rep(sort(unique(ggseg.formats::atlas_regions(dk())))[1:2], each = 2)
    data.frame(region = regs, value = seq_along(regs))
  }

  it("warns when several data rows map to one region", {
    rlang::reset_warning_verbosity("ggseg_collapsed_rows")
    expect_warning(
      warn_collapsed_rows(duplicated_data(), "region", "value"),
      class = "ggseg_collapsed_rows"
    )
  })

  it("documents dplyr::last as the pre-3.0.0 behaviour", {
    rlang::reset_warning_verbosity("ggseg_collapsed_rows")
    w <- expect_warning(
      warn_collapsed_rows(duplicated_data(), "region", "value"),
      class = "ggseg_collapsed_rows"
    )
    expect_match(conditionMessage(w), "dplyr::last", fixed = TRUE)
    expect_match(conditionMessage(w), "Non-numeric", fixed = TRUE)
  })

  it("stays silent when every region appears once", {
    rlang::reset_warning_verbosity("ggseg_collapsed_rows")
    one_per_region <- data.frame(
      region = sort(unique(ggseg.formats::atlas_regions(dk())))[1:2],
      value = 1:2
    )
    expect_no_warning(
      warn_collapsed_rows(one_per_region, "region", "value")
    )
  })

  it("stays silent when there is no value column to collapse", {
    rlang::reset_warning_verbosity("ggseg_collapsed_rows")
    expect_no_warning(
      warn_collapsed_rows(duplicated_data(), "region", character(0))
    )
  })

  it("warns only once per session", {
    rlang::reset_warning_verbosity("ggseg_collapsed_rows")
    expect_warning(
      warn_collapsed_rows(duplicated_data(), "region", "value"),
      class = "ggseg_collapsed_rows"
    )
    expect_no_warning(
      warn_collapsed_rows(duplicated_data(), "region", "value")
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
