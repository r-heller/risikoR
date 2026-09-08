# Heatmap of conquest probability

Draws
[`rk_odds_table()`](https://r-heller.github.io/risikoR/reference/rk_odds_table.md)
as a tile heatmap: attacker armies on one axis, defender armies on the
other, conquest probability as fill. The stepped line traces where the
odds pass even.

## Usage

``` r
rk_plot_odds_heatmap(
  att_range = 2:15,
  def_range = 1:15,
  method = c("exact", "mc"),
  n = 1000L,
  max_def = 2L
)
```

## Arguments

- att_range:

  Integer vector of attacker army counts (each `>= 2`).

- def_range:

  Integer vector of defender army counts (each `>= 1`).

- method:

  Either `"mc"` (Monte Carlo, the default) or `"exact"`.

- n:

  Number of simulated battles. Ignored when `method = "exact"`.

- max_def:

  Maximum defender dice permitted (default `2L`).

## Value

A `ggplot` object.

## See also

Other plots:
[`autoplot.rk_game()`](https://r-heller.github.io/risikoR/reference/autoplot.rk_game.md),
[`rk_plot_conquest()`](https://r-heller.github.io/risikoR/reference/rk_plot_conquest.md),
[`rk_plot_duel()`](https://r-heller.github.io/risikoR/reference/rk_plot_duel.md),
[`rk_plot_map()`](https://r-heller.github.io/risikoR/reference/rk_plot_map.md),
[`rk_plot_tournament()`](https://r-heller.github.io/risikoR/reference/rk_plot_tournament.md)

## Examples

``` r
rk_plot_odds_heatmap(att_range = 2:10, def_range = 1:10)
```
