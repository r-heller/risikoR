# Reinforcement armies available to a player

The standard allowance: one army per three territories held, never fewer
than three, plus the bonus of every continent the player fully controls.

## Usage

``` r
rk_reinforcements(game, player)
```

## Arguments

- game:

  An `rk_game` object.

- player:

  A single player name.

## Value

A single integer; `0L` for an eliminated player.

## See also

Other game:
[`rk_armies()`](https://r-heller.github.io/risikoR/reference/rk_armies.md),
[`rk_continents_held()`](https://r-heller.github.io/risikoR/reference/rk_continents_held.md),
[`rk_game()`](https://r-heller.github.io/risikoR/reference/rk_game.md),
[`rk_is_winner()`](https://r-heller.github.io/risikoR/reference/rk_is_winner.md),
[`rk_owner()`](https://r-heller.github.io/risikoR/reference/rk_owner.md),
[`rk_territories()`](https://r-heller.github.io/risikoR/reference/rk_territories.md),
[`rk_winner()`](https://r-heller.github.io/risikoR/reference/rk_winner.md),
[`summary.rk_game()`](https://r-heller.github.io/risikoR/reference/summary.rk_game.md)

## Examples

``` r
game <- rk_game(c("Red", "Blue"), seed = 1)
rk_reinforcements(game, "Red")
#> [1] 7
```
