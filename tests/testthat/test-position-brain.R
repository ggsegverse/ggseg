test_that("position_formula works", {
  expect_error(
    position_formula(hemi ~ hemi, as.data.frame(dk)),
    "Cannot position brain"
  )

  expect_error(
    position_formula(bla ~ ., as.data.frame(dk)),
    "formula not correct"
  )

  k <- position_formula(hemi ~ view, as.data.frame(dk))
  expect_true(all(c("position", "chosen") %in% names(k)))
  expect_equal(k$position, c("hemi", "view"))
  expect_equal(k$chosen, c("hemi", "view"))

  k <- position_formula(view ~ hemi, as.data.frame(dk))
  expect_true(all(c("position", "chosen") %in% names(k)))
  expect_equal(k$position, c("view", "hemi"))
  expect_equal(k$chosen, c("view", "hemi"))

  k <- position_formula(. ~ hemi + view, as.data.frame(dk))
  expect_true(all(c("position", "chosen") %in% names(k)))
  expect_equal(k$position, c("columns"))
  expect_equal(k$chosen, c("hemi", "view"))

  k <- position_formula(hemi + view ~ ., as.data.frame(dk))
  expect_true(all(c("position", "chosen") %in% names(k)))
  expect_equal(k$position, c("rows"))
  expect_equal(k$chosen, c("hemi", "view"))
})

describe("reposition_brain", {
  it("converts data to data.frame", {
    result <- reposition_brain(dk, hemi ~ view)
    expect_s3_class(result, "sf")
  })

  it("works with formula position", {
    result <- reposition_brain(dk, view ~ hemi)
    expect_s3_class(result, "sf")
  })

  it("works with hemi + view formula", {
    result <- reposition_brain(dk, hemi + view ~ .)
    expect_s3_class(result, "sf")
  })
})

describe("position_brain", {
  it("returns PositionBrain ggproto object", {
    pos <- position_brain()
    expect_s3_class(pos, "PositionBrain")
  })

  it("accepts formula position", {
    pos <- position_brain(hemi ~ view)
    expect_s3_class(pos, "PositionBrain")
  })

  it("accepts horizontal position string", {
    pos <- position_brain("horizontal")
    expect_s3_class(pos, "PositionBrain")
  })

  it("accepts vertical position string", {
    pos <- position_brain("vertical")
    expect_s3_class(pos, "PositionBrain")
  })
})

describe("split_data", {
  it("works with horizontal character position", {
    data <- as.data.frame(dk)
    result <- split_data(data, "horizontal")
    expect_type(result, "list")
    expect_named(result, c("data", "position"))
  })

  it("works with vertical character position", {
    data <- as.data.frame(dk)
    result <- split_data(data, "vertical")
    expect_type(result, "list")
    expect_equal(result$position, "rows")
  })
})

describe("default_order", {
  it("returns order for cortical data", {
    data <- as.data.frame(dk)
    result <- default_order(data)
    expect_type(result, "character")
    expect_true(any(grepl("left", result)))
    expect_true(any(grepl("right", result)))
  })

  it("returns views for subcortical data", {
    data <- as.data.frame(aseg)
    result <- default_order(data)
    expect_type(result, "character")
  })
})

describe("split_data with subcortical", {
  it("works with subcortical atlas positions", {
    data <- as.data.frame(aseg)
    result <- split_data(data, "horizontal")
    expect_type(result, "list")
    expect_named(result, c("data", "position"))
  })
})

describe("stack_vertical", {
  it("stacks data frames vertically", {
    data <- as.data.frame(dk)
    split_result <- split_data(data, "vertical")
    gathered <- lapply(split_result$data, gather_geometry)
    result <- stack_vertical(gathered)
    expect_type(result, "list")
    expect_named(result, c("df", "box"))
  })
})

describe("position_formula edge cases", {
  it("errors when formula missing '.' for single row/column", {
    data <- as.data.frame(dk)
    expect_error(
      position_formula(hemi + view ~ foo, data),
      "must contain both"
    )
  })
})


describe("position_brain with nrow/ncol", {
  it("accepts nrow parameter", {
    pos <- position_brain(nrow = 2)
    expect_s3_class(pos, "PositionBrain")
    expect_equal(pos$nrow, 2)
  })

  it("accepts ncol parameter", {
    pos <- position_brain(ncol = 3)
    expect_s3_class(pos, "PositionBrain")
    expect_equal(pos$ncol, 3)
  })

  it("accepts both nrow and ncol", {
    pos <- position_brain(nrow = 2, ncol = 3)
    expect_s3_class(pos, "PositionBrain")
    expect_equal(pos$nrow, 2)
    expect_equal(pos$ncol, 3)
  })

  it("accepts views parameter", {
    pos <- position_brain(views = c("axial_3", "sagittal"))
    expect_s3_class(pos, "PositionBrain")
    expect_equal(pos$views, c("axial_3", "sagittal"))
  })
})


describe("split_data_grid", {
  it("creates grid layout for subcortical data", {
    data <- as.data.frame(aseg)
    result <- split_data_grid(data, nrow = 2)
    expect_type(result, "list")
    expect_named(result, c("data", "position"))
    expect_equal(result$position, c(".grid_row", ".grid_col"))
  })

  it("respects ncol parameter", {
    data <- as.data.frame(aseg)
    result <- split_data_grid(data, ncol = 3)
    expect_type(result, "list")
    expect_equal(result$position, c(".grid_row", ".grid_col"))
  })
})


describe("reposition_brain with subcortical", {
  it("works with nrow parameter", {
    data <- as.data.frame(aseg)
    result <- reposition_brain(data, nrow = 2)
    expect_s3_class(result, "sf")
  })

  it("works with views parameter", {
    data <- as.data.frame(aseg)
    views <- unique(data$view)[1:3]
    result <- reposition_brain(data, views = views)
    expect_s3_class(result, "sf")
    expect_true(all(result$view %in% views))
  })

  it("respects view order", {
    data <- as.data.frame(aseg)
    views <- rev(unique(data$view)[1:3])
    result <- reposition_brain(data, views = views)
    result_views <- unique(result$view)
    expect_equal(result_views, views)
  })
})


describe("position_formula with subcortical", {
  it("handles type ~ . formula", {
    data <- as.data.frame(aseg)
    k <- position_formula(type ~ ., data)
    expect_true("position" %in% names(k))
    expect_equal(k$position, "rows")
  })

  it("handles . ~ type formula", {
    data <- as.data.frame(aseg)
    k <- position_formula(. ~ type, data)
    expect_true("position" %in% names(k))
    expect_equal(k$position, "columns")
  })

  it("handles view ~ . formula for subcortical", {
    data <- as.data.frame(aseg)
    k <- position_formula(view ~ ., data)
    expect_equal(k$position, "rows")
  })

  it("handles . ~ view formula for subcortical", {
    data <- as.data.frame(aseg)
    k <- position_formula(. ~ view, data)
    expect_equal(k$position, "columns")
  })
})

describe("split_data_grid with defaults", {
  it("auto-calculates nrow and ncol when both NULL", {
    data <- as.data.frame(aseg)
    result <- split_data_grid(data)
    expect_type(result, "list")
    expect_equal(result$position, c(".grid_row", ".grid_col"))
  })
})

describe("reposition_brain subcortical formula", {
  it("works with type ~ . formula", {
    data <- as.data.frame(aseg)
    result <- reposition_brain(data, type ~ .)
    expect_s3_class(result, "sf")
  })

  it("works with . ~ type formula", {
    data <- as.data.frame(aseg)
    result <- reposition_brain(data, . ~ type)
    expect_s3_class(result, "sf")
  })
})

describe("position_formula subcortical multi-var", {
  it("handles two-variable formula for subcortical", {
    data <- as.data.frame(aseg)
    data$hemi <- "left"
    k <- position_formula(view ~ hemi, data)
    expect_equal(k$position, c("view", "hemi"))
  })
})

describe("stack_grid numeric sorting", {
  it("works with numeric grid positions", {
    data <- as.data.frame(aseg)
    result <- reposition_brain(data, nrow = 2, ncol = 4)
    expect_s3_class(result, "sf")
  })
})

describe("extract_view_type", {
  it("extracts type from view names", {
    views <- c("axial_1", "axial_2", "coronal_1", "sagittal")
    types <- extract_view_type(views)
    expect_equal(types, c("axial", "axial", "coronal", "sagittal"))
  })

  it("handles views without underscore", {
    views <- c("sagittal", "coronal")
    types <- extract_view_type(views)
    expect_equal(types, c("sagittal", "coronal"))
  })
})
