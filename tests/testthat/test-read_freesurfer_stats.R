test_that("test read_freesurfer_stats works", {
  aseg_file <- test_path("data/bert/stats/aseg.stats")

  aseg_stats <- read_freesurfer_stats(aseg_file)
  expect_equal(
    names(aseg_stats),
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
  expect_equal(nrow(aseg_stats), 45)

  expect_equal(
    names(read_freesurfer_stats(aseg_file, FALSE)),
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
  expect_equal(
    names(dkt_stats),
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
  expect_equal(nrow(dkt_stats), 34)

  expect_equal(
    names(read_freesurfer_stats(dkt_file, FALSE)),
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

  expect_equal(
    names(dat),
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
  expect_equal(nrow(dat), 68)
  expect_equal(
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

  expect_equal(names(dat), c("subject", "label", "value"))
  expect_equal(nrow(dat), 36)
  expect_true(any(grepl("volume$", dat$label)))

  dat <- read_freesurfer_table(file, measure = "volume")
  expect_equal(names(dat), c("subject", "label", "volume"))
  expect_false(any(grepl("volume$", dat$label)))
})
