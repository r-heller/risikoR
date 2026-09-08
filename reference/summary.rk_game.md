# Standings for every player

Standings for every player

## Usage

``` r
# S3 method for class 'rk_game'
summary(object, ...)
```

## Arguments

- object:

  An `rk_game` object.

- ...:

  Not used.

## Value

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with one row per player (roster order) and columns `player` (character),
`territories` (integer), `armies` (integer), `continents` (integer),
`reinforcements` (integer) and `alive` (logical).

## See also

Other game:
[`rk_armies()`](https://r-heller.github.io/risikoR/reference/rk_armies.md),
[`rk_continents_held()`](https://r-heller.github.io/risikoR/reference/rk_continents_held.md),
[`rk_game()`](https://r-heller.github.io/risikoR/reference/rk_game.md),
[`rk_is_winner()`](https://r-heller.github.io/risikoR/reference/rk_is_winner.md),
[`rk_owner()`](https://r-heller.github.io/risikoR/reference/rk_owner.md),
[`rk_reinforcements()`](https://r-heller.github.io/risikoR/reference/rk_reinforcements.md),
[`rk_territories()`](https://r-heller.github.io/risikoR/reference/rk_territories.md),
[`rk_winner()`](https://r-heller.github.io/risikoR/reference/rk_winner.md)

## Examples

``` r
summary(rk_game(c("Red", "Blue", "Green"), seed = 1))
#> # A tibble: 3 × 6
#>   player territories armies continents reinforcements alive
#>   <chr>        <int>  <int>      <int>          <int> <lgl>
#> 1 Red             14     35          0              4 TRUE 
#> 2 Blue            14     35          0              4 TRUE 
#> 3 Green           14     35          0              4 TRUE 
```
