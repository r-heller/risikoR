# Plot conquest probability across defender strength

Shows the conquest probability as the defender army count varies,
holding the attacker strength fixed.

## Usage

``` r
rk_plot_conquest(
  att_armies,
  def_range = seq_len(20),
  n = 2000L,
  max_def = 2L,
  method = c("mc", "exact")
)
```

## Arguments

- att_armies:

  Fixed number of attacking armies.

- def_range:

  Integer vector of defender army counts to evaluate.

- n:

  Simulations per point when `method = "mc"`.

- max_def:

  Maximum defender dice (default `2L`).

- method:

  Either `"mc"` (Monte Carlo, the default) or `"exact"`; see
  [`rk_battle_odds()`](https://r-heller.github.io/risikoR/reference/rk_battle_odds.md).

## Value

A `ggplot` object.

## See also

Other plots:
[`autoplot.rk_game()`](https://r-heller.github.io/risikoR/reference/autoplot.rk_game.md),
[`rk_plot_duel()`](https://r-heller.github.io/risikoR/reference/rk_plot_duel.md),
[`rk_plot_map()`](https://r-heller.github.io/risikoR/reference/rk_plot_map.md),
[`rk_plot_odds_heatmap()`](https://r-heller.github.io/risikoR/reference/rk_plot_odds_heatmap.md),
[`rk_plot_tournament()`](https://r-heller.github.io/risikoR/reference/rk_plot_tournament.md)

## Examples

``` r
rk_plot_conquest(20, def_range = seq(2, 20, by = 2), method = "exact")
```
