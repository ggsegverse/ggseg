.onLoad <- function(libname, pkgname) {
  ns <- topenv(environment())
  for (obj in c("dk", "aseg", "tracula")) {
    delayedAssign(obj, getExportedValue("ggseg.formats", obj), assign.env = ns)
  }
}
