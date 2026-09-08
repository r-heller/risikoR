# Play a game to the end

Runs a complete game, letting each player's policy choose every action,
until somebody has conquered the world or `max_rounds` rounds have been
played.

## Usage

``` r
rk_play(game, policies, max_rounds = 100L, verbose = FALSE)
```

## Arguments

- game:

  An `rk_game` object, usually straight from
  [`rk_game()`](https://r-heller.github.io/risikoR/reference/rk_game.md).

- policies:

  Either a named character vector of strategy names (passed to
  [`rk_ai()`](https://r-heller.github.io/risikoR/reference/rk_ai.md)) or
  a named list of policy functions, with one entry per player.

- max_rounds:

  Maximum number of rounds to play before stopping.

- verbose:

  A flag: report each completed round with
  [`cli::cli_alert()`](https://cli.r-lib.org/reference/cli_alert.html)?

## Value

An S3 object of class `rk_game_result`: a list with `winner` (a single
string, `NA_character_` if the round cap was reached), `rounds`
(integer, the number of rounds played), `decided` (a flag), `game` (the
final `rk_game`), `standings` (a
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with one row per player per round and columns `round`, `player`,
`territories`, `armies`, `continents`, `reinforcements` and `alive`;
round `0` is the opening deal) and `policies` (a named character vector
of strategy names).

## See also

Other ai:
[`rk_ai()`](https://r-heller.github.io/risikoR/reference/rk_ai.md),
[`rk_tournament()`](https://r-heller.github.io/risikoR/reference/rk_tournament.md)

## Examples

``` r
game <- rk_game(c("Red", "Blue"), seed = 42)
result <- rk_play(
  game,
  policies = c(Red = "aggressive", Blue = "cautious"),
  max_rounds = 5
)
result
#> <rk_game_result> 2 players
#> Undecided after 5 rounds
#> Policies: Red (aggressive) and Blue (cautious)
head(result$standings)
#> # A tibble: 6 × 7
#>   round player territories armies continents reinforcements alive
#>   <int> <chr>        <int>  <int>      <int>          <int> <lgl>
#> 1     0 Red             21     40          0              7 TRUE 
#> 2     0 Blue            21     40          0              7 TRUE 
#> 3     1 Red             24     33          0              8 TRUE 
#> 4     1 Blue            18     21          0              6 TRUE 
#> 5     2 Red             29     32          1             11 TRUE 
#> 6     2 Blue            13     14          0              4 TRUE 
```
