describe("gap", {
  it("returns midpoint of range", {
    expect_identical(gap(c(2, 8)), 5)
    expect_identical(gap(c(-10, 10)), 0)
    expect_identical(gap(c(0, 0)), 0)
  })
})
