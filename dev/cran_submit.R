# Prepare for CRAN ----

# Run tests and examples
devtools::test()
devtools::run_examples()
# autotest::autotest_package(test = TRUE)

# Check package as CRAN
rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-CRAN"))

# Check content (grain of salt needed)
# remotes::install_github("ThinkR-open/checkhelper")
checkhelper::find_missing_tags()

# Check spelling
# usethis::use_spell_check()
spelling::spell_check_package()

# Check URL are correct
# remotes::install_github("r-lib/urlchecker")
urlchecker::url_check()
#urlchecker::url_update()

# check on other distributions
# _win devel
devtools::check_win_devel()

# _rhub
#devtools::check_rhub()
#rhub::check_on_windows(check_args = "--force-multiarch")
# rhub::check_on_solaris() # retired?

# Update NEWS
fledge::bump_version()

# Add comments for CRAN
usethis::use_CRAN_comments(open = rlang::is_interactive())

# Verify you're ready for release, and release
devtools::release()
