# Plot the world map

Draws the board. Territories are tiled landmasses grouped into
continents, borders between neighbours are drawn as lines on the ground
and neighbours that only meet across water are joined by a dashed sea
route. An `rk_game` is coloured by owner and each territory carries its
army count; a bare `rk_map` is coloured by continent.

## Usage

``` r
rk_plot_map(x, labels = TRUE, armies = TRUE)
```

## Arguments

- x:

  An `rk_game` or an `rk_map`.

- labels:

  A flag: label territories with their names?

- armies:

  A flag: label territories with their army count? Only applies to an
  `rk_game`.

## Value

A `ggplot` object.

## Details

Forty-two named territories need room. The board is laid out for a
canvas of roughly 240 by 170 mm; on anything much smaller than about 180
mm wide the territory names will start to overrun their territories,
because text keeps its point size while the map shrinks with the device.
Pass `labels = FALSE` for a thumbnail.

## See also

Other plots:
[`autoplot.rk_game()`](https://r-heller.github.io/risikoR/reference/autoplot.rk_game.md),
[`rk_plot_conquest()`](https://r-heller.github.io/risikoR/reference/rk_plot_conquest.md),
[`rk_plot_duel()`](https://r-heller.github.io/risikoR/reference/rk_plot_duel.md),
[`rk_plot_odds_heatmap()`](https://r-heller.github.io/risikoR/reference/rk_plot_odds_heatmap.md),
[`rk_plot_tournament()`](https://r-heller.github.io/risikoR/reference/rk_plot_tournament.md)

## Examples

``` r
rk_plot_map(rk_world())


game <- rk_game(c("Red", "Blue", "Green"), seed = 1)
rk_plot_map(game)
```
