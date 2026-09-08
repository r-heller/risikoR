# Run many games and compare strategies

Repeatedly deals a fresh game and plays it out with
[`rk_play()`](https://r-heller.github.io/risikoR/reference/rk_play.md),
then summarises how often each strategy won.

## Usage

``` r
rk_tournament(
  policies,
  n_games = 20L,
  map = rk_world(),
  max_rounds = 100L,
  seed = NULL,
  verbose = FALSE
)
```

## Arguments

- policies:

  A named character vector of strategy names, one per player, for
  example `c(Red = "aggressive", Blue = "cautious")`.

- n_games:

  Number of games to play.

- map:

  An `rk_map` object to play on. Defaults to
  [`rk_world()`](https://r-heller.github.io/risikoR/reference/rk_world.md).

- max_rounds:

  Maximum number of rounds to play before stopping.

- seed:

  Optional whole number seed. Supplying it calls
  [`set.seed()`](https://rdrr.io/r/base/Random.html) and therefore
  resets the caller's random number stream.

- verbose:

  A flag: report each completed round with
  [`cli::cli_alert()`](https://cli.r-lib.org/reference/cli_alert.html)?

## Value

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with one row per player and columns `player` (character), `strategy`
(character), `games` (integer), `wins` (integer), `win_rate` (double),
`mean_territories` (double, territories held when the games ended) and
`mean_rounds` (double, the average game length, repeated on every row).

## See also

Other ai:
[`rk_ai()`](https://r-heller.github.io/risikoR/reference/rk_ai.md),
[`rk_play()`](https://r-heller.github.io/risikoR/reference/rk_play.md)

## Examples

``` r
# \donttest{
rk_tournament(
  c(Red = "aggressive", Blue = "cautious"),
  n_games = 2, max_rounds = 10, seed = 1
)
#> # A tibble: 2 × 7
#>   player strategy   games  wins win_rate mean_territories mean_rounds
#>   <chr>  <chr>      <int> <int>    <dbl>            <dbl>       <dbl>
#> 1 Red    aggressive     2     0        0                0           5
#> 2 Blue   cautious       2     2        1               42           5
# }
```
