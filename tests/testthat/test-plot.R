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

test_that("the drawn board agrees with the adjacency graph", {
  # The map is only honest if the borders it draws are the borders the game
  # engine will let you attack across. Two links on the world board are drawn
  # as routes instead: Alaska - Kamchatka wraps round the far side, and
  # East Africa - Middle East is a water crossing.
  map <- rk_world()
  board <- risikoR:::.rk_board(map)
  edges <- risikoR:::.rk_cell_edges(board$tiles, board$cells)
  shared <- edges$id %in% edges$id[duplicated(edges$id)]
  same <- duplicated(paste(edges$id, edges$territory)) |
    duplicated(paste(edges$id, edges$territory), fromLast = TRUE)
  between <- edges[shared & !same, ]
  drawn <- unique(vapply(
    split(between$territory, between$id),
    function(z) paste(sort(unique(z)), collapse = " - "),
    character(1L)
  ))

  links <- risikoR:::.rk_links(map)
  wanted <- paste(pmin(links$from, links$to), pmax(links$from, links$to),
                  sep = " - ")
  as_routes <- c("Alaska - Kamchatka", "East_Africa - Middle_East")

  expect_setequal(setdiff(wanted, drawn), as_routes)
  expect_setequal(setdiff(drawn, wanted), character(0))

  # Every route the plot draws must be one of those two, and both must be there.
  expect_equal(length(unique(board$routes$id)), 1L)
  expect_equal(length(unique(board$wraps$id)), 2L)
})

test_that("every border is wide enough to see", {
  board <- risikoR:::.rk_board(rk_world())
  edges <- risikoR:::.rk_cell_edges(board$tiles, board$cells)
  shared <- edges$id %in% edges$id[duplicated(edges$id)]
  same <- duplicated(paste(edges$id, edges$territory)) |
    duplicated(paste(edges$id, edges$territory), fromLast = TRUE)
  between <- edges[shared & !same, ]
  widths <- table(vapply(
    split(between$territory, between$id),
    function(z) paste(sort(unique(z)), collapse = " - "),
    character(1L)
  ))
  expect_gte(min(widths), 3L)
})

test_that("continent labels sit nearest their own continent", {
  board <- risikoR:::.rk_board(rk_world())
  labels <- board$labels
  expect_equal(nrow(labels), 6L)
  nearest <- risikoR:::.rk_nearest_land(labels$x, labels$y, board$cells)
  expect_equal(nearest$continent, labels$continent)
})

test_that("labels shrink to fit a narrow territory", {
  size <- risikoR:::.rk_fit_size(
    c("Madagascar", "Peru", "Congo"), span = c(4, 9, 9), size = 2.4
  )
  expect_lt(size[[1L]], size[[2L]])
  expect_lte(max(size), 2.4)
  expect_gte(min(size), 2.4 * 0.66)
})
