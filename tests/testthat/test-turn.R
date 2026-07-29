test_that("rk_reinforce places armies and moves to the attack phase", {
  game <- rk_test_game()
  own <- rk_territories(game, "Red")
  need <- rk_reinforcements(game, "Red")
  placements <- c(need - 1L, 1L)
  names(placements) <- own[1:2]
  before <- rk_armies(game, own[1:2])

  after <- rk_reinforce(game, "Red", placements)
  expect_equal(rk_armies(after, own[1:2]), before + c(need - 1L, 1L))
  expect_equal(after$phase, "attack")
  expect_equal(nrow(after$log), 1L)
  expect_equal(after$log$action, "reinforce")
  # the input game is untouched
  expect_equal(game$phase, "reinforce")
  expect_equal(rk_armies(game, own[1:2]), before)
  expect_equal(nrow(game$log), 0L)
})

test_that("rk_reinforce validates the placement", {
  game <- rk_test_game()
  own <- rk_territories(game, "Red")
  need <- rk_reinforcements(game, "Red")
  good <- need
  names(good) <- own[[1L]]

  short <- need - 1L
  names(short) <- own[[1L]]
  expect_error(rk_reinforce(game, "Red", short), "every reinforcement army")

  enemy <- need
  names(enemy) <- rk_territories(game, "Blue")[[1L]]
  expect_error(rk_reinforce(game, "Red", enemy), "only name territories held")

  unnamed <- need
  expect_error(rk_reinforce(game, "Red", unnamed), "named numeric vector")

  negative <- c(need + 1L, -1L)
  names(negative) <- own[1:2]
  expect_error(rk_reinforce(game, "Red", negative), "non-negative")

  fractional <- need + 0.5
  names(fractional) <- own[[1L]]
  expect_error(rk_reinforce(game, "Red", fractional), "whole numbers")

  duplicated <- c(1L, need - 1L)
  names(duplicated) <- c(own[[1L]], own[[1L]])
  expect_error(rk_reinforce(game, "Red", duplicated), "at most once")

  unknown <- need
  names(unknown) <- "Z"
  expect_error(rk_reinforce(game, "Red", unknown), "Unknown territor")

  expect_error(rk_reinforce(game, "Blue", good), "not .*Blue.*turn|not.*turn")
  expect_error(
    rk_reinforce(rk_stack_and_advance(game), "Red", good),
    "reinforce.*phase"
  )
})

test_that("rk_attack enforces legality", {
  game <- rk_test_game()
  expect_error(rk_attack(game, "A", "B"), "attack.*phase")

  game <- rk_stack_and_advance(game)
  own <- rk_territories(game, "Red")
  enemy <- rk_territories(game, "Blue")
  expect_error(rk_attack(game, enemy[[1L]], own[[1L]]), "held by the player")
  expect_error(rk_attack(game, own[[1L]], own[[1L]]), "already yours")
  expect_error(rk_attack(game, own[[1L]], "Z"), "Unknown territor")

  # a territory with a single army cannot attack
  weak <- game
  weak$state$armies <- rep(1L, 4L)
  targets <- rk_legal_attacks(weak, "Red")
  expect_equal(nrow(targets), 0L)
  expect_s3_class(targets, "tbl_df")
})

test_that("a won battle transfers the territory and the armies", {
  withr::local_seed(1)
  game <- rk_test_game()
  game$state$owner <- c("Red", "Red", "Red", "Blue")
  game$state$armies <- c(1L, 1L, 30L, 1L)
  game$phase <- "attack"

  after <- rk_attack(game, "C", "D")
  expect_true(after$last_battle$conquered)
  expect_equal(rk_owner(after, "D"), "Red")
  expect_equal(
    rk_armies(after, "C") + rk_armies(after, "D"),
    after$last_battle$att_remaining
  )
  expect_equal(rk_armies(after, "C"), 1L)
  expect_equal(after$log$conquered[[1L]], TRUE)
  # conquering the last enemy territory ends the game
  expect_equal(after$active, "Red")
  expect_true(rk_is_winner(after))
  expect_equal(rk_winner(after), "Red")
  expect_equal(after$phase, "over")
  # the original game is untouched
  expect_equal(rk_owner(game, "D"), "Blue")
})

test_that("the number of armies moved in can be chosen", {
  withr::local_seed(1)
  game <- rk_test_game()
  game$state$owner <- c("Red", "Red", "Red", "Blue")
  game$state$armies <- c(1L, 1L, 30L, 1L)
  game$phase <- "attack"

  after <- rk_attack(game, "C", "D", move = 2L)
  expect_equal(rk_armies(after, "D"), 2L)
  expect_equal(
    rk_armies(after, "C"), after$last_battle$att_remaining - 2L
  )
  expect_error(rk_attack(game, "C", "D", move = 0), "between 1 and")
})

test_that("a lost battle leaves ownership alone", {
  withr::local_seed(3)
  game <- rk_test_game()
  game$state$owner <- c("Red", "Red", "Red", "Blue")
  game$state$armies <- c(1L, 1L, 2L, 30L)
  game$phase <- "attack"

  after <- rk_attack(game, "C", "D")
  expect_false(after$last_battle$conquered)
  expect_equal(rk_owner(after, "D"), "Blue")
  expect_equal(rk_armies(after, "C"), 1L)
  expect_false(rk_is_winner(after))
})

test_that("rk_step cannot be used once the game is over", {
  withr::local_seed(1)
  game <- rk_test_game()
  game$state$owner <- c("Red", "Red", "Red", "Blue")
  game$state$armies <- c(1L, 1L, 30L, 1L)
  game$phase <- "attack"
  over <- rk_attack(game, "C", "D")
  expect_error(rk_step(over), "game is over")
})

test_that("rk_fortify moves armies along an owned path", {
  game <- rk_test_game()
  game$state$owner <- c("Red", "Red", "Red", "Blue")
  game$state$armies <- c(5L, 1L, 1L, 1L)
  game$phase <- "attack"

  after <- rk_fortify(game, "A", "B", 3L)
  expect_equal(rk_armies(after, "A"), 2L)
  expect_equal(rk_armies(after, "B"), 4L)
  expect_equal(after$phase, "fortify")
  expect_true(after$fortified)
  expect_equal(rk_armies(game, "A"), 5L)

  expect_error(rk_fortify(after, "A", "B", 1L), "one fortification")
  expect_error(rk_fortify(game, "A", "A", 1L), "different territories")
  expect_error(rk_fortify(game, "A", "D", 1L), "held by the player")
  expect_error(rk_fortify(game, "A", "B", 5L), "between 1 and 4")
  expect_error(rk_fortify(game, "B", "A", 1L), "no armies to spare")
})

test_that("fortification needs a connected path", {
  game <- rk_test_game()
  game$state$owner <- c("Red", "Blue", "Blue", "Red")
  game$state$armies <- c(5L, 1L, 1L, 1L)
  game$phase <- "attack"
  expect_error(rk_fortify(game, "A", "D", 1L), "connected")
})

test_that("rk_end_turn hands over and counts rounds", {
  game <- rk_game(c("Red", "Blue", "Green"), map = rk_test_map(), seed = 2)
  expect_error(rk_end_turn(game), "attack.*phase")

  game <- rk_end_turn(rk_stack_and_advance(game))
  expect_equal(game$turn, "Blue")
  expect_equal(game$round, 1L)
  expect_equal(game$phase, "reinforce")
  expect_false(game$fortified)

  game <- rk_end_turn(rk_stack_and_advance(game))
  expect_equal(game$turn, "Green")
  expect_equal(game$round, 1L)

  game <- rk_end_turn(rk_stack_and_advance(game))
  expect_equal(game$turn, "Red")
  expect_equal(game$round, 2L)
})

test_that("rk_step dispatches on the action", {
  game <- rk_test_game()
  own <- rk_territories(game, "Red")
  placements <- rk_reinforcements(game, "Red")
  names(placements) <- own[[1L]]

  stepped <- rk_step(game, list(action = "reinforce", placements = placements))
  expect_equal(stepped$phase, "attack")

  ended <- rk_step(stepped, list(action = "end_turn"))
  expect_equal(ended$turn, "Blue")

  expect_error(rk_step(game, list(action = "surrender")), "must be one of")
  expect_error(rk_step(game, "attack"), "must be a list")
  expect_error(rk_step(game, list(), policy = "nope"), "must be a list")
  expect_error(rk_step(game, policy = "nope"), "must be a function")
})

test_that("rk_step uses the policy when no action is given", {
  withr::local_seed(1)
  game <- rk_test_game()
  stepped <- rk_step(game, policy = rk_ai("aggressive"))
  expect_s3_class(stepped, "rk_game")
  expect_equal(stepped$phase, "attack")
})

test_that("rk_legal_attacks reports every legal move", {
  game <- rk_test_game()
  game$state$owner <- c("Red", "Red", "Blue", "Blue")
  game$state$armies <- c(3L, 1L, 1L, 1L)
  legal <- rk_legal_attacks(game, "Red")
  expect_equal(nrow(legal), 1L)
  expect_equal(legal$from, "A")
  expect_equal(legal$to, "C")
  expect_equal(legal$defender, "Blue")
  expect_equal(legal$att_armies, 3L)
  expect_named(
    legal, c("from", "to", "defender", "att_armies", "def_armies")
  )
  expect_error(rk_legal_attacks(game, "Purple"), "not playing")
})

test_that("turn errors read well", {
  game <- rk_test_game()
  expect_snapshot(rk_attack(game, "A", "B"), error = TRUE)
  expect_snapshot(rk_reinforce(game, "Blue", c(A = 3L)), error = TRUE)
})
