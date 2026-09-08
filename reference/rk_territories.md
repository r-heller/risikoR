# Territories held by a player

Territories held by a player

## Usage

``` r
rk_territories(game, player)
```

## Arguments

- game:

  An `rk_game` object.

- player:

  A single player name.

## Value

A character vector of territory names in map order; empty when the
player has been eliminated.

## See also

Other game:
[`rk_armies()`](https://r-heller.github.io/risikoR/reference/rk_armies.md),
[`rk_continents_held()`](https://r-heller.github.io/risikoR/reference/rk_continents_held.md),
[`rk_game()`](https://r-heller.github.io/risikoR/reference/rk_game.md),
[`rk_is_winner()`](https://r-heller.github.io/risikoR/reference/rk_is_winner.md),
[`rk_owner()`](https://r-heller.github.io/risikoR/reference/rk_owner.md),
[`rk_reinforcements()`](https://r-heller.github.io/risikoR/reference/rk_reinforcements.md),
[`rk_winner()`](https://r-heller.github.io/risikoR/reference/rk_winner.md),
[`summary.rk_game()`](https://r-heller.github.io/risikoR/reference/summary.rk_game.md)

## Examples

``` r
game <- rk_game(c("Red", "Blue"), seed = 1)
rk_territories(game, "Red")
#>  [1] "Alaska"            "Alberta"           "Ontario"          
#>  [4] "Quebec"            "Western_US"        "Eastern_US"       
#>  [7] "Venezuela"         "Peru"              "Argentina"        
#> [10] "Great_Britain"     "Western_Europe"    "Southern_Europe"  
#> [13] "North_Africa"      "East_Africa"       "South_Africa"     
#> [16] "Madagascar"        "Siberia"           "Yakutsk"          
#> [19] "Kamchatka"         "India"             "Eastern_Australia"
```
