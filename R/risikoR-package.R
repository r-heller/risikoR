#' @keywords internal
"_PACKAGE"

#' @importFrom rlang .data
#' @importFrom rlang %||%
#' @importFrom utils globalVariables
NULL

# `risk_map` is this package's own lazy-loaded dataset, used by rk_world().
globalVariables("risk_map")
