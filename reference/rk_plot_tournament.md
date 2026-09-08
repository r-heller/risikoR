# Plot tournament win rates

Draws the win rate of each player in a
[`rk_tournament()`](https://r-heller.github.io/risikoR/reference/rk_tournament.md)
result as a horizontal bar chart, sorted by win rate. Each bar carries
the player's map colour and is labelled with the strategy it played.

## Usage

``` r
rk_plot_tournament(results)
```

## Arguments

- results:

  A
  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
  as returned by
  [`rk_tournament()`](https://r-heller.github.io/risikoR/reference/rk_tournament.md).

## Value

A `ggplot` object.

## See also

Other plots:
[`autoplot.rk_game()`](https://r-heller.github.io/risikoR/reference/autoplot.rk_game.md),
[`rk_plot_conquest()`](https://r-heller.github.io/risikoR/reference/rk_plot_conquest.md),
[`rk_plot_duel()`](https://r-heller.github.io/risikoR/reference/rk_plot_duel.md),
[`rk_plot_map()`](https://r-heller.github.io/risikoR/reference/rk_plot_map.md),
[`rk_plot_odds_heatmap()`](https://r-heller.github.io/risikoR/reference/rk_plot_odds_heatmap.md)

## Examples

``` r
# \donttest{
results <- rk_tournament(
  c(Red = "aggressive", Blue = "cautious"),
  n_games = 2, max_rounds = 10, seed = 1
)
rk_plot_tournament(results)

# }
```
