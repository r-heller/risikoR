app_dir <- function() {
  dir <- system.file("shiny", "risikoR", package = "risikoR")
  if (!nzchar(dir)) {
    testthat::skip("app directory not installed")
  }
  dir
}

test_that("the app ships every file it needs", {
  dir <- app_dir()
  expect_true(file.exists(file.path(dir, "app.R")))
  expect_true(file.exists(file.path(dir, "www", "logo.png")))
  modules <- list.files(file.path(dir, "modules"), pattern = "[.]R$")
  expect_setequal(
    modules,
    c("mod_battle.R", "mod_duel.R", "mod_play.R", "mod_strategy.R")
  )
})

test_that("every app file parses", {
  dir <- app_dir()
  files <- list.files(dir, pattern = "[.]R$", recursive = TRUE,
                      full.names = TRUE)
  expect_gt(length(files), 1L)
  for (file in files) {
    expect_no_error(parse(file))
  }
})

test_that("the app uses no library() calls", {
  dir <- app_dir()
  files <- list.files(dir, pattern = "[.]R$", recursive = TRUE,
                      full.names = TRUE)
  for (file in files) {
    lines <- readLines(file, warn = FALSE)
    expect_false(any(grepl("^\\s*(library|require)\\(", lines)))
  }
})

test_that("rk_run_app explains a missing dependency", {
  local_mocked_bindings(.rk_has_package = function(pkg) FALSE)
  expect_error(rk_run_app(), "is required to run the app")
  expect_snapshot(rk_run_app(), error = TRUE)
})

test_that("the app object can be built", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("bslib")
  skip_if_not_installed("plotly")
  dir <- app_dir()
  withr::local_dir(dir)
  app <- source("app.R", local = new.env())$value
  expect_s3_class(app, "shiny.appobj")
})
