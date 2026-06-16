describe("layout_cell_offsets", {
  it("gathers, centres in a uniform cell, and grid-shifts each group", {
    # group 1 is 10x10 at origin; group 2 is 4x4 at origin
    bboxes <- rbind(
      c(xmin = 0, ymin = 0, xmax = 10, ymax = 10),
      c(xmin = 0, ymin = 0, xmax = 4, ymax = 4)
    )
    offs <- layout_cell_offsets(bboxes, row_idx = c(1, 1), col_idx = c(1, 2))
    # cell is 10x10 (largest), sep_x = 12
    # g1: already fills the cell at origin -> no shift
    expect_equal(unname(offs[1, ]), c(0, 0))
    # g2: centred in the 10-wide cell ((10-4)/2 = 3) then +1 column (sep 12)
    expect_equal(unname(offs[2, ]), c(3 + 12, 3))
  })

  it("shifts down the rows for a vertical layout", {
    bboxes <- rbind(
      c(xmin = 0, ymin = 0, xmax = 10, ymax = 10),
      c(xmin = 0, ymin = 0, xmax = 10, ymax = 10)
    )
    offs <- layout_cell_offsets(bboxes, row_idx = c(1, 2), col_idx = c(1, 1))
    expect_equal(unname(offs[, "dx"]), c(0, 0))
    # second group drops one row; vertical separation is 12
    expect_equal(unname(offs[, "dy"]), c(0, 12))
  })

  it("folds a non-zero origin into the offset (gather)", {
    bboxes <- rbind(c(xmin = 100, ymin = 50, xmax = 110, ymax = 60))
    offs <- layout_cell_offsets(bboxes, row_idx = 1, col_idx = 1)
    expect_equal(unname(offs[1, ]), c(-100, -50))
  })
})

describe("layout_box", {
  it("pads the overall extent by 1% and anchors at the negative pad", {
    bboxes <- rbind(
      c(xmin = 0, ymin = 0, xmax = 10, ymax = 10),
      c(xmin = 12, ymin = 0, xmax = 22, ymax = 10)
    )
    box <- layout_box(bboxes)
    pad <- 22 * 0.01
    expect_equal(unname(box), c(-pad, -pad, 22 + pad, 10 + pad))
    expect_named(box, c("xmin", "ymin", "xmax", "ymax"))
  })
})

describe("cell_indices", {
  it("lays groups left-to-right for columns", {
    groups <- vector("list", 3)
    idx <- cell_indices(groups, "columns")
    expect_equal(idx$row, c(1, 1, 1))
    expect_equal(idx$col, c(1, 2, 3))
    expect_equal(idx$order, 1:3)
  })

  it("stacks groups top-to-bottom for rows", {
    groups <- vector("list", 3)
    idx <- cell_indices(groups, "rows")
    expect_equal(idx$row, c(1, 2, 3))
    expect_equal(idx$col, c(1, 1, 1))
  })

  it("maps grid groups to (row, col) indices and returns row-major order", {
    mk <- function(r, c) data.frame(.grid_row = r, .grid_col = c, x = 0, y = 0)
    # indices are positions in the first-appearance unique values
    groups <- list(mk(1, 1), mk(1, 2), mk(2, 1))
    idx <- cell_indices(groups, "grid", ".grid_row", ".grid_col")
    expect_equal(idx$row, c(1, 1, 2))
    expect_equal(idx$col, c(1, 2, 1))
    # already in row-major (row, col) order
    expect_equal(idx$order, c(1, 2, 3))
  })
})

describe("position_groups", {
  it("applies the offsets via the supplied translate + returns padded box", {
    g1 <- data.frame(x = c(0, 10), y = c(0, 10))
    g2 <- data.frame(x = c(0, 10), y = c(0, 10))
    res <- position_groups(
      list(g1, g2),
      "columns",
      NULL,
      NULL,
      bbox_of = bbox_flat,
      translate = function(g, dx, dy) {
        g$x <- g$x + dx
        g$y <- g$y + dy
        g
      }
    )
    expect_length(res$data, 2)
    # second group shifted one cell to the right (sep_x = 12)
    expect_equal(min(res$data[[2]]$x), 12)
    expect_named(res$box, c("xmin", "ymin", "xmax", "ymax"))
  })
})
