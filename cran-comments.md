## Submission

This is a breaking major release (2.2.1 -> 3.0.0). `geom_brain()` has been
rebuilt on a ggplot2 `Stat`, and the bundled atlas geometry now comes from the
re-keyed `ggseg.formats (>= 0.1.0)`, so region keys that user data joins on have
changed. All breaking changes are listed under `## Breaking changes` in NEWS.md,
with the migration path for each.

`ggseg.formats 0.1.0` is being submitted alongside this release and must be
accepted first: `ggseg` 3.0.0 does not work against `ggseg.formats 0.0.4`, which
is why the dependency floor was raised.

## R CMD check results

0 errors | 0 warnings | 1 note

- checking CRAN incoming feasibility ... NOTE
  New maintainer-side dependency floor: `ggseg.formats (>= 0.1.0)`, submitted in
  the same round.

The visual regression tests (`vdiffr`) `skip_on_cran()`: their snapshots are
geometry-specific and so cannot be checked against an atlas version that is not
pinned at check time.

## Reverse dependencies

`neuroimaGene` 0.1.4 is the only CRAN reverse dependency (Imports: ggseg). It was
checked against this version and passes. Its plots in fact improve: the Desikan
and Subcortex figures currently render with a single distinct fill, and render
with 79 and 7 distinct fills respectively against this version. The maintainer
has been notified ahead of submission.
