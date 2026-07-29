#' Launch the interactive risikoR application
#'
#' Starts the bundled 'shiny' application: four tabs for playing a game against
#' the AI agents on a clickable map, analysing a single dice duel, simulating
#' battles against the exact solution, and running strategy tournaments.
#' Requires the `Suggests` packages the app uses (`shiny` and `bslib`).
#'
#' @param ... Passed to [shiny::runApp()].
#'
#' @return Invisible `NULL`. Called for the side effect of launching a Shiny
#'   application.
#' @export
#' @family app
#'
#' @examples
#' \dontrun{
#' rk_run_app()
#' }
rk_run_app <- function(...) {
  for (pkg in c("shiny", "bslib")) {
    if (!.rk_has_package(pkg)) {
      cli::cli_abort(c(
        "Package {.pkg {pkg}} is required to run the app.",
        "i" = "Install it with {.code install.packages(\"{pkg}\")}."
      ))
    }
  }
  app_dir <- system.file("shiny", "risikoR", package = "risikoR")
  shiny::runApp(app_dir, ...)
  invisible(NULL)
}

# Wrapped so that tests can mock a missing dependency.
.rk_has_package <- function(pkg) {
  requireNamespace(pkg, quietly = TRUE)
}
