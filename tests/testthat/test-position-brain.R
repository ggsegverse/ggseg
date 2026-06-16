test_that("position_formula works", {
  expect_error(
    position_formula(hemi ~ hemi, as.data.frame(dk())),
    "Cannot position brain"
  )

  expect_error(
    position_formula(bla ~ ., as.data.frame(dk())),
    "formula not correct"
  )

  k <- position_formula(hemi ~ view, as.data.frame(dk()))
  expect_true(all(c("position", "chosen") %in% names(k)))
  expect_identical(k$position, c("hemi", "view"))
  expect_identical(k$chosen, c("hemi", "view"))

  k <- position_formula(view ~ hemi, as.data.frame(dk()))
  expect_true(all(c("position", "chosen") %in% names(k)))
  expect_identical(k$position, c("view", "hemi"))
  expect_identical(k$chosen, c("view", "hemi"))

  k <- position_formula(. ~ hemi + view, as.data.frame(dk()))
  expect_true(all(c("position", "chosen") %in% names(k)))
  expect_identical(k$position, "columns")
  expect_identical(k$chosen, c("hemi", "view"))

  k <- position_formula(hemi + view ~ ., as.data.frame(dk()))
  expect_true(all(c("position", "chosen") %in% names(k)))
  expect_identical(k$position, "rows")
  expect_identical(k$chosen, c("hemi", "view"))
})

describe("reposition_brain", {
  it("converts data to data.frame", {
    skip_if_not_installed("sf")
    result <- reposition_brain(dk(), hemi ~ view)
    expect_s3_class(result, "sf")
  })

  it("works with formula position", {
    skip_if_not_installed("sf")
    result <- reposition_brain(dk(), view ~ hemi)
    expect_s3_class(result, "sf")
  })

  it("works with hemi + view formula", {
    skip_if_not_installed("sf")
    result <- reposition_brain(dk(), hemi + view ~ .)
    expect_s3_class(result, "sf")
  })
})

describe("position_brain", {
  it("returns a polygon layout spec", {
    pos <- position_brain()
    expect_s3_class(pos, "position_brain_polygon_spec")
  })

  it("accepts formula position", {
    pos <- position_brain(hemi ~ view)
    expect_s3_class(pos, "position_brain_polygon_spec")
  })

  it("accepts horizontal position string", {
    pos <- position_brain("horizontal")
    expect_s3_class(pos, "position_brain_polygon_spec")
  })

  it("accepts vertical position string", {
    pos <- position_brain("vertical")
    expect_s3_class(pos, "position_brain_polygon_spec")
  })
})

describe("position_brain_sf (deprecated)", {
  it("warns and returns a PositionBrain ggproto", {
    lifecycle::expect_deprecated(pos <- position_brain_sf(hemi ~ view))
    expect_s3_class(pos, "PositionBrain")
    expect_identical(pos$position, hemi ~ view)
  })
})

describe("split_data", {
  it("works with horizontal character position", {
    data <- as.data.frame(dk())
    result <- split_data(data, "horizontal")
    expect_type(result, "list")
    expect_named(result, c("data", "position"))
  })

  it("works with vertical character position", {
    data <- as.data.frame(dk())
    result <- split_data(data, "vertical")
    expect_type(result, "list")
    expect_identical(result$position, "rows")
  })
})

describe("default_order", {
  it("returns order for cortical data", {
    data <- as.data.frame(dk())
    result <- default_order(data)
    expect_type(result, "character")
    expect_true(any(grepl("left", result, fixed = TRUE)))
    expect_true(any(grepl("right", result, fixed = TRUE)))
  })

  it("returns views for subcortical data", {
    data <- as.data.frame(aseg())
    result <- default_order(data)
    expect_type(result, "character")
  })
})

describe("split_data with subcortical", {
  it("works with subcortical atlas positions", {
    data <- as.data.frame(aseg())
    result <- split_data(data, "horizontal")
    expect_type(result, "list")
    expect_named(result, c("data", "position"))
  })
})


describe("position_formula edge cases", {
  it("errors when formula missing '.' for single row/column", {
    data <- as.data.frame(dk())
    expect_error(
      position_formula(hemi + view ~ foo, data),
      "must contain both"
    )
  })
})


describe("position_brain with nrow/ncol", {
  it("accepts nrow parameter", {
    pos <- position_brain(nrow = 2)
    expect_s3_class(pos, "position_brain_polygon_spec")
    expect_identical(pos$nrow, 2)
  })

  it("accepts ncol parameter", {
    pos <- position_brain(ncol = 3)
    expect_s3_class(pos, "position_brain_polygon_spec")
    expect_identical(pos$ncol, 3)
  })

  it("accepts both nrow and ncol", {
    pos <- position_brain(nrow = 2, ncol = 3)
    expect_s3_class(pos, "position_brain_polygon_spec")
    expect_identical(pos$nrow, 2)
    expect_identical(pos$ncol, 3)
  })

  it("accepts views parameter", {
    pos <- position_brain(views = c("axial_3", "sagittal"))
    expect_s3_class(pos, "position_brain_polygon_spec")
    expect_identical(pos$views, c("axial_3", "sagittal"))
  })
})


describe("split_data_grid", {
  it("creates grid layout for subcortical data", {
    data <- as.data.frame(aseg())
    result <- split_data_grid(data, nrow = 2)
    expect_type(result, "list")
    expect_named(result, c("data", "position"))
    expect_identical(result$position, c(".grid_row", ".grid_col"))
  })

  it("respects ncol parameter", {
    data <- as.data.frame(aseg())
    result <- split_data_grid(data, ncol = 3)
    expect_type(result, "list")
    expect_identical(result$position, c(".grid_row", ".grid_col"))
  })
})


describe("reposition_brain with subcortical", {
  it("works with nrow parameter", {
    skip_if_not_installed("sf")
    data <- as.data.frame(aseg())
    result <- reposition_brain(data, nrow = 2)
    expect_s3_class(result, "sf")
  })

  it("works with views parameter", {
    skip_if_not_installed("sf")
    data <- as.data.frame(aseg())
    views <- unique(data$view)[1:3]
    result <- reposition_brain(data, views = views)
    expect_s3_class(result, "sf")
    expect_true(all(result$view %in% views))
  })

  it("respects view order", {
    skip_if_not_installed("sf")
    data <- as.data.frame(aseg())
    views <- rev(unique(data$view)[1:3])
    result <- reposition_brain(data, views = views)
    result_views <- unique(result$view)
    expect_identical(result_views, views)
  })
})


describe("position_formula with subcortical", {
  it("handles type ~ . formula", {
    data <- as.data.frame(aseg())
    k <- position_formula(type ~ ., data)
    expect_true("position" %in% names(k))
    expect_identical(k$position, "rows")
  })

  it("handles . ~ type formula", {
    data <- as.data.frame(aseg())
    k <- position_formula(. ~ type, data)
    expect_true("position" %in% names(k))
    expect_identical(k$position, "columns")
  })

  it("handles view ~ . formula for subcortical", {
    data <- as.data.frame(aseg())
    k <- position_formula(view ~ ., data)
    expect_identical(k$position, "rows")
  })

  it("handles . ~ view formula for subcortical", {
    data <- as.data.frame(aseg())
    k <- position_formula(. ~ view, data)
    expect_identical(k$position, "columns")
  })
})

describe("split_data_grid with defaults", {
  it("auto-calculates nrow and ncol when both NULL", {
    data <- as.data.frame(aseg())
    result <- split_data_grid(data)
    expect_type(result, "list")
    expect_identical(result$position, c(".grid_row", ".grid_col"))
  })
})

describe("reposition_brain subcortical formula", {
  it("works with type ~ . formula", {
    skip_if_not_installed("sf")
    data <- as.data.frame(aseg())
    result <- reposition_brain(data, type ~ .)
    expect_s3_class(result, "sf")
  })

  it("works with . ~ type formula", {
    skip_if_not_installed("sf")
    data <- as.data.frame(aseg())
    result <- reposition_brain(data, . ~ type)
    expect_s3_class(result, "sf")
  })
})

describe("position_formula subcortical multi-var", {
  it("handles two-variable formula for subcortical", {
    data <- as.data.frame(aseg())
    data$hemi <- "left"
    k <- position_formula(view ~ hemi, data)
    expect_identical(k$position, c("view", "hemi"))
  })
})

describe("stack_grid numeric sorting", {
  it("works with numeric grid positions", {
    skip_if_not_installed("sf")
    data <- as.data.frame(aseg())
    result <- reposition_brain(data, nrow = 2, ncol = 4)
    expect_s3_class(result, "sf")
  })
})

describe("extract_view_type", {
  it("extracts type from view names", {
    views <- c("axial_1", "axial_2", "coronal_1", "sagittal")
    types <- extract_view_type(views)
    expect_identical(types, c("axial", "axial", "coronal", "sagittal"))
  })

  it("handles views without underscore", {
    views <- c("sagittal", "coronal")
    types <- extract_view_type(views)
    expect_identical(types, c("sagittal", "coronal"))
  })
})

describe("parse_formula_vars", {
  it("extracts variable names from a formula", {
    expect_identical(parse_formula_vars(hemi ~ view), c("hemi", "view"))
  })

  it("excludes dot placeholder", {
    expect_identical(parse_formula_vars(hemi + view ~ .), c("hemi", "view"))
    expect_identical(parse_formula_vars(. ~ hemi + view), c("hemi", "view"))
  })

  it("errors on duplicate variables", {
    expect_error(parse_formula_vars(hemi ~ hemi), "Cannot position brain")
  })
})

describe("stacking_direction", {
  it("returns rows when dot is on RHS", {
    expect_identical(stacking_direction(hemi + view ~ .), "rows")
  })

  it("returns columns when dot is on LHS", {
    expect_identical(stacking_direction(. ~ hemi + view), "columns")
  })
})

describe("validate_stacking_formula", {
  it("passes silently for grid positions", {
    expect_invisible(validate_stacking_formula(hemi ~ view, c("hemi", "view")))
  })

  it("passes for valid stacking formula", {
    expect_silent(validate_stacking_formula(hemi + view ~ ., "rows"))
  })

  it("errors when dot or tilde is missing", {
    expect_error(
      validate_stacking_formula(hemi + view ~ foo, "rows"),
      "must contain both"
    )
  })
})

describe("position_cortical", {
  it("returns variable names for two-var formula", {
    expect_identical(
      position_cortical(hemi ~ view, c("hemi", "view")),
      c("hemi", "view")
    )
  })

  it("detects stacking direction with plus", {
    expect_identical(
      position_cortical(hemi + view ~ ., c("hemi", "view")),
      "rows"
    )
    expect_identical(
      position_cortical(. ~ hemi + view, c("hemi", "view")),
      "columns"
    )
  })

  it("errors with fewer than two variables", {
    expect_error(position_cortical(hemi ~ ., "hemi"), "formula not correct")
  })
})

describe("position_subcortical", {
  it("remaps type to .view_type", {
    data <- as.data.frame(aseg())
    result <- position_subcortical(type ~ ., "type", data)
    expect_identical(result$chosen, ".view_type")
    expect_true(".view_type" %in% names(result$data))
  })

  it("detects stacking direction for single var", {
    data <- as.data.frame(aseg())
    result <- position_subcortical(view ~ ., "view", data)
    expect_identical(result$position, "rows")
  })

  it("returns chosen vars for two-var formula", {
    data <- as.data.frame(aseg())
    data$hemi <- "left"
    result <- position_subcortical(view ~ hemi, c("view", "hemi"), data)
    expect_identical(result$position, c("view", "hemi"))
  })
})

describe("grid_lookup", {
  it("extracts row and column values from split data", {
    data <- as.data.frame(aseg())
    split_result <- split_data_grid(data, nrow = 2)
    lookup <- grid_lookup(split_result$data, ".grid_row", ".grid_col")
    expect_named(lookup, c("df_rows", "df_cols", "row_vals", "col_vals"))
    expect_length(lookup$df_rows, length(split_result$data))
    expect_length(lookup$df_cols, length(split_result$data))
  })

  it("coerces numeric values to character", {
    data <- as.data.frame(aseg())
    split_result <- split_data_grid(data, nrow = 2)
    lookup <- grid_lookup(split_result$data, ".grid_row", ".grid_col")
    expect_type(lookup$df_rows, "character")
    expect_type(lookup$df_cols, "character")
  })
})

describe("drop_temp_columns", {
  it("removes temporary grid columns", {
    df <- data.frame(
      x = 1:3,
      .grid_row = 1:3,
      .grid_col = 1:3,
      .view_type = "a"
    )
    result <- drop_temp_columns(df)
    expect_named(result, "x")
  })

  it("leaves data unchanged when no temp columns present", {
    df <- data.frame(x = 1:3, y = 4:6)
    result <- drop_temp_columns(df)
    expect_identical(result, df)
  })
})
