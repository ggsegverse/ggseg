describe("ggseg", {
  it("is defunct and errors", {
    expect_error(ggseg(), "deprecated.*defunct")
  })
})
