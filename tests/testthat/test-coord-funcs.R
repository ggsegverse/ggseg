describe("gap", {
  it("returns midpoint of range", {
    expect_equal(gap(c(0, 10)), 5)
    expect_equal(gap(c(-5, 5)), 0)
    expect_equal(gap(c(3, 3)), 3)
  })
})
