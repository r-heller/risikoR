# Attacks available to a player

Enumerates every legal attack: an owned territory with at least two
armies next to a territory held by somebody else.

## Usage

``` r
rk_legal_attacks(game, player = game$turn)
```

## Arguments

- game:

  An `rk_game` object.

- player:

  The attacking player. Defaults to the player to move.

## Value

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with one row per legal attack and columns `from` (character), `to`
(character), `defender` (character), `att_armies` (integer) and
`def_armies` (integer). Zero rows when no attack is available.

## See also

Other turn:
[`rk_attack()`](https://r-heller.github.io/risikoR/reference/rk_attack.md),
[`rk_end_turn()`](https://r-heller.github.io/risikoR/reference/rk_end_turn.md),
[`rk_fortify()`](https://r-heller.github.io/risikoR/reference/rk_fortify.md),
[`rk_reinforce()`](https://r-heller.github.io/risikoR/reference/rk_reinforce.md),
[`rk_step()`](https://r-heller.github.io/risikoR/reference/rk_step.md)

## Examples

``` r
game <- rk_game(c("Red", "Blue"), seed = 1)
rk_legal_attacks(game, "Red")
#> # A tibble: 23 × 5
#>    from            to                  defender att_armies def_armies
#>    <chr>           <chr>               <chr>         <int>      <int>
#>  1 Alaska          Northwest_Territory Blue              2          2
#>  2 Alberta         Northwest_Territory Blue              2          2
#>  3 Eastern_US      Central_America     Blue              5          1
#>  4 Venezuela       Central_America     Blue              2          1
#>  5 Venezuela       Brazil              Blue              2          2
#>  6 Peru            Brazil              Blue              3          2
#>  7 Great_Britain   Iceland             Blue              2          1
#>  8 Great_Britain   Scandinavia         Blue              2          3
#>  9 Great_Britain   Northern_Europe     Blue              2          3
#> 10 Southern_Europe Northern_Europe     Blue              3          3
#> # ℹ 13 more rows
```
