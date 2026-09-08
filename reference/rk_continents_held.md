# Continents fully controlled by a player

Continents fully controlled by a player

## Usage

``` r
rk_continents_held(game, player)
```

## Arguments

- game:

  An `rk_game` object.

- player:

  A single player name.

## Value

A character vector of continent names; empty when the player holds no
complete continent.

## See also

Other game:
[`rk_armies()`](https://r-heller.github.io/risikoR/reference/rk_armies.md),
[`rk_game()`](https://r-heller.github.io/risikoR/reference/rk_game.md),
[`rk_is_winner()`](https://r-heller.github.io/risikoR/reference/rk_is_winner.md),
[`rk_owner()`](https://r-heller.github.io/risikoR/reference/rk_owner.md),
[`rk_reinforcements()`](https://r-heller.github.io/risikoR/reference/rk_reinforcements.md),
[`rk_territories()`](https://r-heller.github.io/risikoR/reference/rk_territories.md),
[`rk_winner()`](https://r-heller.github.io/risikoR/reference/rk_winner.md),
[`summary.rk_game()`](https://r-heller.github.io/risikoR/reference/summary.rk_game.md)

## Examples

``` r
game <- rk_game(c("Red", "Blue"), seed = 1)
rk_continents_held(game, "Red")
#> character(0)
```
