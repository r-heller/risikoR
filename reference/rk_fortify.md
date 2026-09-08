# Move armies between two connected territories

Performs the single fortification move allowed at the end of a turn.
Both territories must be held by the player to move and joined by a path
running entirely through their own territories.

## Usage

``` r
rk_fortify(game, from, to, armies)
```

## Arguments

- game:

  An `rk_game` object.

- from:

  The territory to move armies out of; at least one army must stay
  behind.

- to:

  The territory to move armies into.

- armies:

  Number of armies to move (at least one).

## Value

A new `rk_game` object in the `"fortify"` phase. The input `game` is
left unchanged.

## See also

Other turn:
[`rk_attack()`](https://r-heller.github.io/risikoR/reference/rk_attack.md),
[`rk_end_turn()`](https://r-heller.github.io/risikoR/reference/rk_end_turn.md),
[`rk_legal_attacks()`](https://r-heller.github.io/risikoR/reference/rk_legal_attacks.md),
[`rk_reinforce()`](https://r-heller.github.io/risikoR/reference/rk_reinforce.md),
[`rk_step()`](https://r-heller.github.io/risikoR/reference/rk_step.md)

## Examples

``` r
game <- rk_game(c("Red", "Blue"), seed = 1)
from <- rk_territories(game, "Red")[[1L]]
placements <- rk_reinforcements(game, "Red")
names(placements) <- from
game <- rk_reinforce(game, "Red", placements)

to <- intersect(rk_neighbors(game, from), rk_territories(game, "Red"))[[1L]]
game <- rk_fortify(game, from, to, 3)
rk_armies(game, c(from, to))
#> [1] 6 5
```
