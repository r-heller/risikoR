# Build a Risk map

Constructs an `rk_map` from a territory list, an adjacency graph and a
continent partition. Use it to play on a custom board; the classic world
board is available from
[`rk_world()`](https://r-heller.github.io/risikoR/reference/rk_world.md).

## Usage

``` r
rk_map(territories, adjacency, continent, continent_bonus, layout = NULL)
```

## Arguments

- territories:

  Character vector of unique territory names.

- adjacency:

  Named list, one element per territory, giving the names of its
  neighbours. The graph must be symmetric (if `a` neighbours `b`, then
  `b` neighbours `a`) and no territory may neighbour itself.

- continent:

  Named list, one element per continent, giving the territories it
  contains. Every territory must belong to exactly one continent.

- continent_bonus:

  Named numeric vector of bonus armies per continent, with one entry per
  element of `continent`.

- layout:

  Optional
  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
  of plotting coordinates with columns `territory`, `x` and `y`. When
  omitted, territories are arranged on a circle grouped by continent.

## Value

An S3 object of class `rk_map`: a list with elements `territories`
(character), `adjacency` (named list), `continent` (named list),
`continent_bonus` (named integer) and `layout` (a tibble with columns
`territory`, `x`, `y` and `continent`).

## See also

Other map:
[`risk_map`](https://r-heller.github.io/risikoR/reference/risk_map.md),
[`rk_neighbors()`](https://r-heller.github.io/risikoR/reference/rk_neighbors.md),
[`rk_world()`](https://r-heller.github.io/risikoR/reference/rk_world.md)

## Examples

``` r
m <- rk_map(
  territories = c("North", "South", "East"),
  adjacency = list(
    North = c("South", "East"),
    South = c("North", "East"),
    East = c("North", "South")
  ),
  continent = list(Land = c("North", "South", "East")),
  continent_bonus = c(Land = 2)
)
m
#> <rk_map> 3 territories, 1 continent
#> Bonuses: Land +2
```
