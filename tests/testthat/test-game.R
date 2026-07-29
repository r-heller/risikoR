test_that("rk_game deals every territory", {
  game <- rk_game(c("Red", "Blue", "Green"), seed = 1)
  expect_s3_class(game, "rk_game")
  expect_equal(nrow(game$state), 42L)
  expect_equal(game$state$territory, rk_world()$territories)
  expect_setequal(unique(game$state$owner), c("Red", "Blue", "Green"))
  expect_true(all(game$state$armies >= 1L))
  expect_type(game$state$armies, "integer")
  expect_equal(game$turn, "Red")
  expect_equal(game$phase, "reinforce")
  expect_equal(game$round, 1L)
  expect_false(game$fortified)
  expect_equal(nrow(game$log), 0L)
  expect_s3_class(game$last_battle, "rk_battle")
})

test_that("the deal is reproducible and spreads the starting armies", {
  a <- rk_game(c("Red", "Blue"), seed = 7)
  b <- rk_game(c("Red", "Blue"), seed = 7)
  expect_equal(a$state, b$state)
  # Two players start with 40 armies each.
  expect_equal(sum(a$state$armies[a$state$owner == "Red"]), 40L)
  expect_equal(sum(a$state$armies[a$state$owner == "Blue"]), 40L)
  expect_equal(sum(a$state$owner == "Red"), 21L)
})

test_that("rk_game validates its arguments", {
  expect_error(rk_game("Solo"), "2 to 6 players")
  expect_error(rk_game(c("a", "b", "c", "d", "e", "f", "g")), "2 to 6 players")
  expect_error(rk_game(c("Red", "Red")), "must be unique")
  expect_error(rk_game(c(1, 2)), "character vector")
  expect_error(rk_game(c("Red", "Blue"), map = "world"), "rk_map")
  expect_error(rk_game(c("Red", "Blue"), seed = "x"), "whole number")
})

test_that("accessors return stable types", {
  game <- rk_test_game()
  expect_type(rk_owner(game, "A"), "character")
  expect_length(rk_owner(game, c("A", "B")), 2L)
  expect_type(rk_armies(game, "A"), "integer")
  expect_length(rk_armies(game, c("A", "B", "C")), 3L)
  expect_type(rk_territories(game, "Red"), "character")
  expect_type(rk_continents_held(game, "Red"), "character")
  expect_type(rk_reinforcements(game, "Red"), "integer")
  expect_length(rk_reinforcements(game, "Red"), 1L)
  expect_type(rk_is_winner(game), "logical")
  expect_type(rk_winner(game), "character")
  expect_true(is.na(rk_winner(game)))
  expect_false(rk_is_winner(game))
})

test_that("accessors reject unknown territories and players", {
  game <- rk_test_game()
  expect_error(rk_owner(game, "Z"), "Unknown territor")
  expect_error(rk_armies(game, "Z"), "Unknown territor")
  expect_error(rk_territories(game, "Purple"), "not playing")
  expect_error(rk_reinforcements(game, "Purple"), "not playing")
  expect_error(rk_owner("game", "A"), "rk_game")
})

test_that("reinforcements follow the standard allowance", {
  game <- rk_game(c("Red", "Blue", "Green"), seed = 1)
  n_terr <- length(rk_territories(game, "Red"))
  bonus <- sum(rk_world()$continent_bonus[rk_continents_held(game, "Red")])
  expect_equal(
    rk_reinforcements(game, "Red"),
    as.integer(max(3L, n_terr %/% 3L) + bonus)
  )
  # Never fewer than three.
  small <- rk_test_game()
  expect_gte(rk_reinforcements(small, "Red"), 3L)
})

test_that("continent bonuses are counted when a continent is complete", {
  game <- rk_test_game()
  game$state$owner <- c("Red", "Red", "Blue", "Blue")
  expect_equal(rk_continents_held(game, "Red"), "North")
  expect_equal(rk_continents_held(game, "Blue"), "South")
  expect_equal(rk_reinforcements(game, "Red"), 5L)
  expect_equal(rk_reinforcements(game, "Blue"), 6L)
})

test_that("an eliminated player receives nothing", {
  game <- rk_test_game()
  game$state$owner <- rep("Red", 4L)
  expect_equal(rk_reinforcements(game, "Blue"), 0L)
  expect_length(rk_territories(game, "Blue"), 0L)
  expect_type(rk_territories(game, "Blue"), "character")
})

test_that("summary returns one row per player", {
  game <- rk_game(c("Red", "Blue", "Green"), seed = 1)
  s <- summary(game)
  expect_s3_class(s, "tbl_df")
  expect_equal(nrow(s), 3L)
  expect_named(
    s,
    c("player", "territories", "armies", "continents", "reinforcements",
      "alive")
  )
  expect_equal(s$player, game$players)
  expect_equal(sum(s$territories), 42L)
  expect_true(all(s$alive))
})

test_that("games print and format", {
  game <- rk_test_game()
  expect_type(format(game), "character")
  expect_output(print(game), "rk_game")
  expect_snapshot(print(game))
})
