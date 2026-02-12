.onAttach <- function(libname, pkgname) {
  data(
    "dk", "aseg", "tracula",
    package = "ggseg.formats",
    envir = as.environment(paste0("package:", pkgname))
  )
}
