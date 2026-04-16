describe("gap", {
  it("returns midpoint of range", {
    expect_identical(gap(c(0, 10)), 5)
    expect_identical(gap(c(-5, 5)), 0)
    expect_identical(gap(c(3, 3)), 3)
  })
})
