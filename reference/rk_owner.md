# Who owns a territory

Who owns a territory

## Usage

``` r
rk_owner(game, territory)
```

## Arguments

- game:

  An `rk_game` object.

- territory:

  Character vector of territory names.

## Value

A character vector of owner names, the same length as `territory`.

## See also

Other game:
[`rk_armies()`](https://r-heller.github.io/risikoR/reference/rk_armies.md),
[`rk_continents_held()`](https://r-heller.github.io/risikoR/reference/rk_continents_held.md),
[`rk_game()`](https://r-heller.github.io/risikoR/reference/rk_game.md),
[`rk_is_winner()`](https://r-heller.github.io/risikoR/reference/rk_is_winner.md),
[`rk_reinforcements()`](https://r-heller.github.io/risikoR/reference/rk_reinforcements.md),
[`rk_territories()`](https://r-heller.github.io/risikoR/reference/rk_territories.md),
[`rk_winner()`](https://r-heller.github.io/risikoR/reference/rk_winner.md),
[`summary.rk_game()`](https://r-heller.github.io/risikoR/reference/summary.rk_game.md)

## Examples

``` r
game <- rk_game(c("Red", "Blue"), seed = 1)
rk_owner(game, c("Brazil", "Egypt"))
#> [1] "Blue" "Blue"
```
