# Place reinforcement armies

Places the player's reinforcement armies on territories they own and
moves the game into the attack phase. The number of armies to place is
given by
[`rk_reinforcements()`](https://r-heller.github.io/risikoR/reference/rk_reinforcements.md)
and the placements must account for all of them.

## Usage

``` r
rk_reinforce(game, player, placements)
```

## Arguments

- game:

  An `rk_game` object.

- player:

  The player to move; must be the player whose turn it is.

- placements:

  A named numeric vector of armies to place, with territory names for
  names. Every named territory must be owned by `player` and the values
  must sum to `rk_reinforcements(game, player)`.

## Value

A new `rk_game` object in the `"attack"` phase. The input `game` is left
unchanged.

## See also

Other turn:
[`rk_attack()`](https://r-heller.github.io/risikoR/reference/rk_attack.md),
[`rk_end_turn()`](https://r-heller.github.io/risikoR/reference/rk_end_turn.md),
[`rk_fortify()`](https://r-heller.github.io/risikoR/reference/rk_fortify.md),
[`rk_legal_attacks()`](https://r-heller.github.io/risikoR/reference/rk_legal_attacks.md),
[`rk_step()`](https://r-heller.github.io/risikoR/reference/rk_step.md)

## Examples

``` r
game <- rk_game(c("Red", "Blue"), seed = 1)
placements <- rk_reinforcements(game, "Red")
names(placements) <- rk_territories(game, "Red")[[1L]]
game <- rk_reinforce(game, "Red", placements)
game$phase
#> [1] "attack"
```
