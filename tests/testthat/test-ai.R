test_that("rk_ai returns a policy function", {
  for (strategy in c("random", "aggressive", "cautious")) {
    bot <- rk_ai(strategy)
    expect_type(bot, "closure")
    expect_named(formals(bot), c("game", "player"))
  }
  expect_error(rk_ai("clever"), "should be one of")
  expect_error(rk_ai("random", ratio = -1), "positive number")
})

test_that("every policy proposes a legal action in every phase", {
  withr::local_seed(1)
  for (strategy in c("random", "aggressive", "cautious")) {
    bot <- rk_ai(strategy)
    game <- rk_test_game()

    action <- bot(game, "Red")
    expect_equal(action$action, "reinforce")
    expect_equal(sum(action$placements), rk_reinforcements(game, "Red"))
    expect_true(all(names(action$placements) %in% rk_territories(game, "Red")))
    game <- rk_step(game, action)

    action <- bot(game, "Red")
    expect_true(action$action %in% c("attack", "fortify", "end_turn"))
    game <- rk_step(game, action)
    expect_s3_class(game, "rk_game")
  }
})

test_that("the aggressive policy attacks the weakest reachable enemy", {
  game <- rk_test_game()
  game$state$owner <- c("Red", "Red", "Blue", "Blue")
  game$state$armies <- c(9L, 1L, 4L, 1L)
  game$phase <- "attack"
  action <- rk_ai("aggressive")(game, "Red")
  expect_equal(action$action, "attack")
  expect_equal(action$from, "A")
  expect_equal(action$to, "C")

  # nothing favourable: the turn ends
  game$state$armies <- c(2L, 1L, 40L, 1L)
  expect_equal(rk_ai("aggressive")(game, "Red")$action, "end_turn")
})

test_that("the cautious policy respects its ratio", {
  game <- rk_test_game()
  game$state$owner <- c("Red", "Red", "Blue", "Blue")
  game$state$armies <- c(4L, 1L, 3L, 1L)
  game$phase <- "attack"
  # 4 against 3 is below the default ratio of 1.5
  expect_false(identical(rk_ai("cautious")(game, "Red")$action, "attack"))
  # but not below a ratio of 1.1
  expect_equal(rk_ai("cautious", ratio = 1.1)(game, "Red")$action, "attack")
})

test_that("the cautious policy pulls armies out of the interior", {
  game <- rk_test_game()
  game$state$owner <- c("Red", "Red", "Red", "Blue")
  game$state$armies <- c(6L, 1L, 1L, 40L)
  game$phase <- "attack"
  action <- rk_ai("cautious")(game, "Red")
  expect_equal(action$action, "fortify")
  expect_equal(action$from, "A")
  expect_true(action$to %in% c("B", "C"))
  expect_equal(action$armies, 5L)
})

test_that("rk_play reaches a winner", {
  withr::local_seed(1)
  result <- rk_play(
    rk_test_game(),
    policies = c(Red = "aggressive", Blue = "cautious"),
    max_rounds = 50
  )
  expect_s3_class(result, "rk_game_result")
  expect_true(result$decided)
  expect_true(result$winner %in% c("Red", "Blue"))
  expect_equal(rk_winner(result$game), result$winner)
  expect_s3_class(result$standings, "tbl_df")
  expect_named(
    result$standings,
    c("round", "player", "territories", "armies", "continents",
      "reinforcements", "alive")
  )
  expect_equal(min(result$standings$round), 0L)
  expect_equal(max(result$standings$round), result$rounds)
  final <- result$standings[result$standings$round == result$rounds, ]
  expect_equal(sum(final$territories), 4L)
  expect_equal(final$territories[final$player == result$winner], 4L)
})

test_that("rk_play stops at the round cap", {
  withr::local_seed(2)
  result <- rk_play(
    rk_game(c("Red", "Blue", "Green"), seed = 5),
    policies = c(Red = "cautious", Blue = "cautious", Green = "cautious"),
    max_rounds = 2
  )
  expect_false(result$decided)
  expect_true(is.na(result$winner))
  expect_equal(result$rounds, 2L)
  expect_equal(max(result$standings$round), 2L)
})

test_that("rk_play accepts custom policies and reports them", {
  withr::local_seed(1)
  always_end <- function(game, player) {
    if (identical(game$phase, "reinforce")) {
      placements <- rk_reinforcements(game, player)
      names(placements) <- rk_territories(game, player)[[1L]]
      return(list(action = "reinforce", placements = placements))
    }
    list(action = "end_turn")
  }
  result <- rk_play(
    rk_test_game(),
    policies = list(Red = always_end, Blue = always_end),
    max_rounds = 3
  )
  expect_false(result$decided)
  expect_equal(unname(result$policies), c("custom", "custom"))
  expect_equal(nrow(result$game$log), 3L * 2L * 2L)
})

test_that("rk_play validates its arguments", {
  game <- rk_test_game()
  expect_error(rk_play(game, c(Red = "aggressive")), "one entry per player")
  expect_error(
    rk_play(game, c(Red = "clever", Blue = "random")),
    "Unknown strategy"
  )
  expect_error(rk_play(game, 1:2), "named character vector")
  expect_error(
    rk_play(game, c(Red = "random", Blue = "random"), verbose = "yes"),
    "TRUE"
  )
  expect_error(
    rk_play(game, c(Red = "random", Blue = "random"), max_rounds = 0),
    "between 1 and"
  )
})

test_that("rk_play can report progress", {
  withr::local_seed(1)
  expect_message(
    rk_play(
      rk_test_game(),
      policies = c(Red = "random", Blue = "random"),
      max_rounds = 1, verbose = TRUE
    ),
    "Round 1 complete"
  )
})

test_that("results print and format", {
  withr::local_seed(1)
  result <- rk_play(
    rk_test_game(), c(Red = "aggressive", Blue = "cautious"), max_rounds = 50
  )
  expect_type(format(result), "character")
  expect_output(print(result), "rk_game_result")
})

test_that("rk_tournament summarises many games", {
  withr::local_seed(1)
  out <- rk_tournament(
    c(Red = "aggressive", Blue = "cautious"),
    n_games = 3, map = rk_test_map(), max_rounds = 30, seed = 1
  )
  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 2L)
  expect_named(
    out,
    c("player", "strategy", "games", "wins", "win_rate", "mean_territories",
      "mean_rounds")
  )
  expect_equal(out$games, c(3L, 3L))
  expect_equal(sum(out$wins), 3L)
  expect_equal(sum(out$win_rate), 1)
  expect_equal(sum(out$mean_territories), 4)
})

test_that("rk_tournament validates its arguments", {
  expect_error(rk_tournament(c("aggressive", "cautious")), "named character")
  expect_error(
    rk_tournament(c(Red = "aggressive", Blue = "cautious"), n_games = 0),
    "between 1 and"
  )
  expect_error(
    rk_tournament(c(Red = "aggressive", Blue = "cautious"), map = "world"),
    "rk_map"
  )
})
