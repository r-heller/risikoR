# The winner of the game

The winner of the game

## Usage

``` r
rk_winner(game)
```

## Arguments

- game:

  An `rk_game` object.

## Value

A single string: the winning player's name, or `NA_character_` while the
game is undecided.

## See also

Other game:
[`rk_armies()`](https://r-heller.github.io/risikoR/reference/rk_armies.md),
[`rk_continents_held()`](https://r-heller.github.io/risikoR/reference/rk_continents_held.md),
[`rk_game()`](https://r-heller.github.io/risikoR/reference/rk_game.md),
[`rk_is_winner()`](https://r-heller.github.io/risikoR/reference/rk_is_winner.md),
[`rk_owner()`](https://r-heller.github.io/risikoR/reference/rk_owner.md),
[`rk_reinforcements()`](https://r-heller.github.io/risikoR/reference/rk_reinforcements.md),
[`rk_territories()`](https://r-heller.github.io/risikoR/reference/rk_territories.md),
[`summary.rk_game()`](https://r-heller.github.io/risikoR/reference/summary.rk_game.md)

## Examples

``` r
game <- rk_game(c("Red", "Blue"), seed = 1)
rk_winner(game)
#> [1] NA
```
