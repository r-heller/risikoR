# Plot a game or a battle

[`ggplot2::autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
methods: an `rk_game` is drawn as the world map (see
[`rk_plot_map()`](https://r-heller.github.io/risikoR/reference/rk_plot_map.md)),
an `rk_battle` as the armies remaining after each duel.

## Usage

``` r
# S3 method for class 'rk_game'
autoplot(object, ...)

# S3 method for class 'rk_battle'
autoplot(object, ...)
```

## Arguments

- object:

  An `rk_game` or an `rk_battle`.

- ...:

  Passed on to
  [`rk_plot_map()`](https://r-heller.github.io/risikoR/reference/rk_plot_map.md)
  for `rk_game`; not used for `rk_battle`.

## Value

A `ggplot` object.

## See also

Other plots:
[`rk_plot_conquest()`](https://r-heller.github.io/risikoR/reference/rk_plot_conquest.md),
[`rk_plot_duel()`](https://r-heller.github.io/risikoR/reference/rk_plot_duel.md),
[`rk_plot_map()`](https://r-heller.github.io/risikoR/reference/rk_plot_map.md),
[`rk_plot_odds_heatmap()`](https://r-heller.github.io/risikoR/reference/rk_plot_odds_heatmap.md),
[`rk_plot_tournament()`](https://r-heller.github.io/risikoR/reference/rk_plot_tournament.md)

## Examples

``` r
game <- rk_game(c("Red", "Blue"), seed = 1)
ggplot2::autoplot(game)


set.seed(1)
ggplot2::autoplot(rk_battle(12, 10))
```
