test_that("plot functions return ggplot objects", {
  expect_s3_class(rk_plot_duel(3, 2), "ggplot")
  expect_s3_class(rk_plot_duel(1, 1, max_def = 3L), "ggplot")
  expect_s3_class(
    rk_plot_conquest(10, def_range = c(2, 6), method = "exact"), "ggplot"
  )
  expect_s3_class(
    rk_plot_odds_heatmap(att_range = 2:4, def_range = 1:3), "ggplot"
  )
})

test_that("the map plots for a board and for a game", {
  world <- rk_plot_map(rk_world())
  expect_s3_class(world, "ggplot")
  game <- rk_plot_map(rk_test_game())
  expect_s3_class(game, "ggplot")
  expect_s3_class(rk_plot_map(rk_test_game(), labels = FALSE), "ggplot")
  expect_s3_class(rk_plot_map(rk_test_map(), armies = FALSE), "ggplot")
  expect_error(rk_plot_map("world"), "rk_map")
  expect_error(rk_plot_map(rk_world(), labels = "yes"), "TRUE")
  expect_error(rk_plot_map(rk_world(), armies = 1), "TRUE")
})

test_that("the map plot survives being built", {
  built <- ggplot2::ggplot_build(rk_plot_map(rk_test_game()))
  expect_s3_class(built, "ggplot_built")
})

test_that("a finished game plots with a winner subtitle", {
  withr::local_seed(1)
  game <- rk_test_game()
  game$state$owner <- c("Red", "Red", "Red", "Blue")
  game$state$armies <- c(1L, 1L, 30L, 1L)
  game$phase <- "attack"
  over <- rk_attack(game, "C", "D")
  expect_s3_class(rk_plot_map(over), "ggplot")
})

test_that("autoplot methods dispatch", {
  game <- rk_test_game()
  expect_s3_class(ggplot2::autoplot(game), "ggplot")
  expect_s3_class(autoplot(game), "ggplot")
  withr::local_seed(1)
  battle <- rk_battle(10, 8)
  expect_s3_class(ggplot2::autoplot(battle), "ggplot")
  built <- ggplot2::ggplot_build(ggplot2::autoplot(battle))
  expect_s3_class(built, "ggplot_built")
})

test_that("tournament results plot", {
  withr::local_seed(1)
  out <- rk_tournament(
    c(Red = "aggressive", Blue = "cautious"),
    n_games = 2, map = rk_test_map(), max_rounds = 20, seed = 1
  )
  expect_s3_class(rk_plot_tournament(out), "ggplot")
  expect_error(rk_plot_tournament(out[, 1:2]), "Missing column")
  expect_error(rk_plot_tournament("results"), "rk_tournament")
})
