#' Take an atlas in at a boundary that also accepts a flat data.frame
#'
#' [ggseg.formats::as_ggseg_atlas()] is the door every public function puts
#' between a user's atlas and the rest of the package: it upgrades a legacy
#' list atlas or a stale-schema S7 atlas to the current object and raises the
#' boundary errors on anything that is not an atlas at all. A few of ggseg's
#' boundaries -- [brain_join()], [reposition_brain()], [adapt_scales()] --
#' document a second accepted input, an already-flattened atlas data.frame, so
#' they cannot hand everything they get to `as_ggseg_atlas()`. This passes a
#' data.frame straight through and sends anything else through the door.
#'
#' @param atlas An atlas in any representation, or a data.frame.
#' @param arg The argument name to blame in an error.
#' @param call The environment to attribute the error to.
#' @return `atlas` unchanged when it is a data.frame, otherwise the current
#'   `ggseg_atlas`.
#' @keywords internal
#' @noRd
atlas_or_frame_input <- function(
  atlas,
  arg = rlang::caller_arg(atlas),
  call = rlang::caller_env()
) {
  if (is.data.frame(atlas)) {
    return(atlas)
  }
  ggseg.formats::as_ggseg_atlas(atlas, arg = arg, call = call)
}
