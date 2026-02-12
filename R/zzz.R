.onLoad <- function(libname, pkgname) {
  ns <- topenv(environment())
  for (obj in c("dk", "aseg", "tracula")) {
    local({
      name <- obj
      delayedAssign(
        name,
        getExportedValue("ggseg.formats", name),
        assign.env = ns
      )
    })
  }
}
