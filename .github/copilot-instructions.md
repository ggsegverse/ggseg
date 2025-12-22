<!-- .github/copilot-instructions.md -->
# Quick instructions for AI coding agents working on ggseg

Purpose: help an AI get productive quickly by outlining the project's
shape, important files, build/test workflows, and repo-specific
conventions. Keep changes minimal and always reference the files named
below when making edits.

- Big picture
  - ggseg provides a ggplot2 geom and data for plotting brain atlases.
    The core pieces are: R code (R/), packaged atlas data (data/), and
    data preprocessing scripts (data-raw/). The package publishes a
    pkgdown site in `docs/` and includes vignettes in `vignettes/`.
  - Spatial functionality depends on `sf` and native libs: GDAL, GEOS,
    PROJ. Changes touching spatial code may require those native libs.

- Key files & folders to inspect first
  - `README.md` — high-level overview and install examples.
  - `DESCRIPTION` — package metadata, native deps (SystemRequirements),
    and suggested workflow (roxygen, testthat settings).
  - `R/` — implementation. Start with `ggseg.R`, `geom-brain.R`,
    `brain_atlas.R`, and `read_freesurfer.R` for main data and plotting
    flows.
  - `data/` — prebuilt atlas `.rda` datasets (e.g. `dk.rda`, `aseg.rda`).
  - `data-raw/` — scripts that generate atlas data: `make_data.R`,
    `make_hex.R`. Treat these as source-of-truth for atlas creation.
  - `vignettes/`, `docs/`, `pkgdown/` — docs site + examples. `inst/`
    contains CITATION and other install-time artifacts.

- Developer workflows (commands/examples)
  - Update docs after changing roxygen: `devtools::document()`
  - Run full package checks: `devtools::check()` or `R CMD check .`
  - Run unit tests: `devtools::test()` (testthat 3rd edition; tests run in
    parallel via `Config/testthat/parallel: true`).
  - Build site locally: `pkgdown::build_site()` (site lives in `docs/`).

- Conventions & patterns to follow
  - Use roxygen2 for documentation; `RoxygenNote` in `DESCRIPTION`
    indicates expected roxygen version.
  - Atlas data is generated in `data-raw/` and stored (compressed) in
    `data/` as `.rda` files — do not hand-edit files in `data/`.
  - Spatial code uses `sf` idioms and tidyverse style. Prefer `|>` and
    `dplyr`/`tidyr` utilities where existing code does.
  - Tests follow testthat v3 patterns. Keep tests fast; heavy spatial
    integration can be isolated behind small unit tests.

- Integration points & native deps
  - `sf` requires GDAL/GEOS/PROJ on the system — CI and local dev
    must have these installed. `SystemRequirements` in `DESCRIPTION`
    lists minima (GDAL >= 2.0.1, GEOS >= 3.4.0, PROJ >= 4.8.0).
  - The package sets `C++17` in `DESCRIPTION`; if you touch C++ or
    `src/`, ensure `src/Makevars` uses `CXX_STD = CXX17` and check
    compiler flags.

- Linting, formatting, and CI notes
  - Project uses `lintr`; add `.lintr` to ignore large auto-generated
    folders like `data-raw/` if not already ignored: `exclude: "data-raw/"`.
  - PDF manual requires LaTeX packages (e.g. `inconsolata`); expect
    PDF creation to fail on systems missing TeX packages — CI may
    differ from local systems.

- Example change pattern (edit + verify)
  1. Modify R code (e.g. `R/geom-brain.R`).
  2. Update roxygen comments in the same file.
  3. Run `devtools::document()` and `devtools::test()`.
  4. Run `devtools::check()` and fix warnings/notes before PR.

If anything above is unclear or you want the file shortened/extended,
tell me what to focus on and I will iterate.
