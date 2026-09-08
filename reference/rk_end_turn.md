# End the current turn

Hands play to the next surviving player, resets the phase to
`"reinforce"` and advances the round counter when play wraps back to the
first player.

## Usage

``` r
rk_end_turn(game)
```

## Arguments

- game:

  An `rk_game` object.

## Value

A new `rk_game` object. The input `game` is left unchanged.

## See also

Other turn:
[`rk_attack()`](https://r-heller.github.io/risikoR/reference/rk_attack.md),
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
rk_end_turn(game)$turn
#> [1] "Blue"
```
