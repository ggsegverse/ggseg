describe("require_sf", {
  it("aborts with install guidance when sf is unavailable", {
    local_mocked_bindings(has_sf = function() FALSE)
    expect_error(require_sf("foo()"), "requires the.+sf.+package")
    expect_error(require_sf("foo()"), "install.packages")
  })

  it("returns invisibly when sf is available", {
    local_mocked_bindings(has_sf = function() TRUE)
    expect_invisible(require_sf("foo()"))
    expect_true(require_sf("foo()"))
  })
})

describe("sf-dependent entry points fail gracefully without sf", {
  it("reposition_brain() aborts via require_sf when sf is unavailable", {
    local_mocked_bindings(has_sf = function() FALSE)
    expect_error(
      reposition_brain(dk(), hemi ~ view),
      "reposition_brain.+requires the.+sf.+package"
    )
  })

  it("brain_join() with an sf-geometry data.frame aborts via require_sf", {
    local_mocked_bindings(has_sf = function() FALSE)
    # A plain data.frame carrying a `geometry` column reaches the st_as_sf
    # branch directly (as.data.frame() is a no-op), so the guard there fires.
    df <- data.frame(atlas = "x", region = "insula", geometry = NA)
    expect_error(
      suppressMessages(brain_join(data.frame(region = "insula", p = 1), df)),
      "requires the.+sf.+package"
    )
  })
})
