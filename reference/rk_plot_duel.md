# Plot the loss distribution of a single duel

Draws the exact outcome distribution of one dice duel (see
[`rk_duel_dist()`](https://r-heller.github.io/risikoR/reference/rk_duel_dist.md))
as a bar chart. Bars are coloured by who comes out of the exchange
ahead, and labelled with the probability.

## Usage

``` r
rk_plot_duel(n_att, n_def, max_def = 2L)
```

## Arguments

- n_att:

  Number of attacker dice (1-3).

- n_def:

  Number of defender dice (1-2; up to 3 in older variants).

- max_def:

  Maximum defender dice permitted by the ruleset. Defaults to `2L`; set
  to `3L` for the older variant.

## Value

A `ggplot` object.

## See also

Other plots:
[`autoplot.rk_game()`](https://r-heller.github.io/risikoR/reference/autoplot.rk_game.md),
[`rk_plot_conquest()`](https://r-heller.github.io/risikoR/reference/rk_plot_conquest.md),
[`rk_plot_map()`](https://r-heller.github.io/risikoR/reference/rk_plot_map.md),
[`rk_plot_odds_heatmap()`](https://r-heller.github.io/risikoR/reference/rk_plot_odds_heatmap.md),
[`rk_plot_tournament()`](https://r-heller.github.io/risikoR/reference/rk_plot_tournament.md)

## Examples

``` r
rk_plot_duel(3, 2)
```
