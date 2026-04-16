describe("modify_list", {
  it("merges new values into old list", {
    old <- list(a = 1, b = 2, c = 3)
    new <- list(b = 20, d = 40)
    result <- modify_list(old, new)
    expect_identical(result$a, 1)
    expect_identical(result$b, 20)
    expect_identical(result$c, 3)
    expect_identical(result$d, 40)
  })

  it("returns old list when new is empty", {
    old <- list(a = 1)
    result <- modify_list(old, list())
    expect_identical(result, old)
  })
})

describe("gap", {
  it("returns midpoint of range", {
    expect_identical(gap(c(2, 8)), 5)
    expect_identical(gap(c(-10, 10)), 0)
    expect_identical(gap(c(0, 0)), 0)
  })
})
