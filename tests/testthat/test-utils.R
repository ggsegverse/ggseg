describe("modify_list", {
  it("merges new values into old list", {
    old <- list(a = 1, b = 2, c = 3)
    new <- list(b = 20, d = 40)
    result <- modify_list(old, new)
    expect_equal(result$a, 1)
    expect_equal(result$b, 20)
    expect_equal(result$c, 3)
    expect_equal(result$d, 40)
  })

  it("returns old list when new is empty", {
    old <- list(a = 1)
    result <- modify_list(old, list())
    expect_equal(result, old)
  })
})

describe("gap", {
  it("returns midpoint of range", {
    expect_equal(gap(c(2, 8)), 5)
    expect_equal(gap(c(-10, 10)), 0)
    expect_equal(gap(c(0, 0)), 0)
  })
})
