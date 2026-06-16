## R CMD check results

0 errors | 0 warnings | 0 notes

## Release summary

This is a feature release (2.2.0). The headline change makes the 'sf' package
an optional dependency: ggseg now draws brain atlases from a lightweight
polygon representation by default, so it installs and plots on systems where
'sf' (and its GDAL / GEOS / PROJ system libraries) is unavailable. The
'sf'-backed rendering path remains available but is deprecated.

## Dependency note

ggseg imports 'ggseg.formats', which is on CRAN. This release relies on
features in a newer 'ggseg.formats'; the 'Remotes' field will be removed and a
minimum version pinned once that 'ggseg.formats' release is on CRAN.

## URL note

The DOI URL <https://doi.org/10.1177/2515245920928009> returns HTTP 403
because the publisher uses a captcha wall. The URL resolves correctly in a
browser.

## Reverse dependencies

The downstream atlas packages in the ggsegverse were checked; final revdep
results to be confirmed at submission time.
