# Attack a neighbouring territory

Resolves a full battle with
[`rk_battle()`](https://r-heller.github.io/risikoR/reference/rk_battle.md)
between two adjacent territories. If the defender is wiped out the
territory changes hands and armies move in from the attacking territory.

## Usage

``` r
rk_attack(game, from, to, max_def = 2L, move = NULL)
```

## Arguments

- game:

  An `rk_game` object.

- from:

  The attacking territory; must be held by the player to move and carry
  at least two armies.

- to:

  The defending territory; must be adjacent to `from` and held by
  another player.

- max_def:

  Maximum defender dice permitted (default `2L`).

- move:

  Number of armies to move into a conquered territory. Must leave at
  least one army behind. Defaults to all but one of the surviving
  attackers.

## Value

A new `rk_game` object with the battle stored in `last_battle`. The
input `game` is left unchanged. Conquering the last territory of an
opponent eliminates them; taking the last territory of the last opponent
moves the game into the `"over"` phase.

## See also

Other turn:
[`rk_end_turn()`](https://r-heller.github.io/risikoR/reference/rk_end_turn.md),
[`rk_fortify()`](https://r-heller.github.io/risikoR/reference/rk_fortify.md),
[`rk_legal_attacks()`](https://r-heller.github.io/risikoR/reference/rk_legal_attacks.md),
[`rk_reinforce()`](https://r-heller.github.io/risikoR/reference/rk_reinforce.md),
[`rk_step()`](https://r-heller.github.io/risikoR/reference/rk_step.md)

## Examples

``` r
game <- rk_game(c("Red", "Blue"), seed = 1)
placements <- rk_reinforcements(game, "Red")
names(placements) <- rk_territories(game, "Red")[[1L]]
game <- rk_reinforce(game, "Red", placements)

targets <- rk_legal_attacks(game, "Red")
set.seed(1)
game <- rk_attack(game, targets$from[[1L]], targets$to[[1L]])
game$last_battle
#> <rk_battle> territory conquered after 3 duels
#> Attacker: 6 left · Defender: 0 left
```
