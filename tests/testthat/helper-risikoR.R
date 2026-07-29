# A four-territory board: two continents of two, every territory reachable.
# Small enough that whole games finish in milliseconds.
rk_test_map <- function() {
  rk_map(
    territories = c("A", "B", "C", "D"),
    adjacency = list(
      A = c("B", "C"),
      B = c("A", "D"),
      C = c("A", "D"),
      D = c("B", "C")
    ),
    continent = list(North = c("A", "B"), South = c("C", "D")),
    continent_bonus = c(North = 2, South = 3)
  )
}

# A two-player game on that board, with a deterministic deal.
rk_test_game <- function(seed = 1) {
  rk_game(c("Red", "Blue"), map = rk_test_map(), seed = seed)
}

# Move a game into the attack phase by placing every reinforcement on the
# player's first territory.
rk_stack_and_advance <- function(game, player = game$turn) {
  placements <- rk_reinforcements(game, player)
  names(placements) <- rk_territories(game, player)[[1L]]
  rk_reinforce(game, player, placements)
}
