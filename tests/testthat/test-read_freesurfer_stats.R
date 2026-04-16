test_that("test read_freesurfer_stats works", {
  aseg_file <- test_path("data/bert/stats/aseg.stats")

  aseg_stats <- read_freesurfer_stats(aseg_file)
  expect_named(
    aseg_stats,
    c(
      "Index",
      "SegId",
      "NVoxels",
      "Volume_mm3",
      "label",
      "normMean",
      "normStdDev",
      "normMin",
      "normMax",
      "normRange"
    )
  )
  expect_identical(nrow(aseg_stats), 45L)

  expect_named(
    read_freesurfer_stats(aseg_file, FALSE),
    c(
      "Index",
      "SegId",
      "NVoxels",
      "Volume_mm3",
      "StructName",
      "normMean",
      "normStdDev",
      "normMin",
      "normMax",
      "normRange"
    )
  )

  dkt_file <- test_path("data/bert/stats/lh.aparc.stats")

  dkt_stats <- read_freesurfer_stats(dkt_file)
  expect_named(
    dkt_stats,
    c(
      "label",
      "NumVert",
      "SurfArea",
      "GrayVol",
      "ThickAvg",
      "ThickStd",
      "MeanCurv",
      "GausCurv",
      "FoldInd",
      "CurvInd"
    )
  )
  expect_identical(nrow(dkt_stats), 34L)

  expect_named(
    read_freesurfer_stats(dkt_file, FALSE),
    c(
      "StructName",
      "NumVert",
      "SurfArea",
      "GrayVol",
      "ThickAvg",
      "ThickStd",
      "MeanCurv",
      "GausCurv",
      "FoldInd",
      "CurvInd"
    )
  )
})

test_that("test that read_atlas_files works", {
  dat <- read_atlas_files(test_path("data"), "aparc")

  expect_named(
    dat,
    c(
      "subject",
      "label",
      "NumVert",
      "SurfArea",
      "GrayVol",
      "ThickAvg",
      "ThickStd",
      "MeanCurv",
      "GausCurv",
      "FoldInd",
      "CurvInd"
    )
  )
  expect_identical(nrow(dat), 68L)
  expect_identical(
    unique(dat$label)[1:10],
    c(
      "lh_bankssts",
      "lh_caudalanteriorcingulate",
      "lh_caudalmiddlefrontal",
      "lh_cuneus",
      "lh_entorhinal",
      "lh_fusiform",
      "lh_inferiorparietal",
      "lh_inferiortemporal",
      "lh_isthmuscingulate",
      "lh_lateraloccipital"
    )
  )
})

test_that("test read_freesurfer_table works", {
  file <- test_path("data/aparc.volume.table")
  dat <- read_freesurfer_table(file)

  expect_named(dat, c("subject", "label", "value"))
  expect_identical(nrow(dat), 36L)
  expect_true(any(grepl("volume$", dat$label)))

  dat <- read_freesurfer_table(file, measure = "volume")
  expect_named(dat, c("subject", "label", "volume"))
  expect_false(any(grepl("volume$", dat$label)))
})
