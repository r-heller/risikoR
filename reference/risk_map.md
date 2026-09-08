# The classic Risk world board

The standard 42-territory, 6-continent Risk board: which territories
exist, which of them border one another, how they group into continents,
the bonus armies each continent is worth, and static coordinates for
drawing the board.
[`rk_world()`](https://r-heller.github.io/risikoR/reference/rk_world.md)
wraps this dataset into an `rk_map` object.

## Usage

``` r
risk_map
```

## Format

A list with five elements:

- `territories`:

  Character vector of the 42 territory names, in board order (North
  America, South America, Europe, Africa, Asia, Australia).

- `adjacency`:

  Named list with one element per territory, each a character vector of
  the territories it borders. The graph is symmetric and no territory
  borders itself.

- `continent`:

  Named list with one element per continent, each a character vector of
  its territories. Every territory belongs to exactly one continent.

- `continent_bonus`:

  Named integer vector of the extra armies a player receives for holding
  each continent: North America 5, South America 2, Europe 5, Africa 3,
  Asia 7, Australia 2.

- `layout`:

  A
  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
  with 42 rows and columns `territory` (character), `x` and `y` (double
  plotting coordinates on a 0-100 canvas) and `continent` (character).

## Source

The territory, adjacency and continent structure of the standard Risk
board; assembled by `data-raw/make_map.R`. The plotting coordinates are
a schematic layout, not a geographic projection.

## See also

Other map:
[`rk_map()`](https://r-heller.github.io/risikoR/reference/rk_map.md),
[`rk_neighbors()`](https://r-heller.github.io/risikoR/reference/rk_neighbors.md),
[`rk_world()`](https://r-heller.github.io/risikoR/reference/rk_world.md)

## Examples

``` r
risk_map$continent_bonus
#> North_America South_America        Europe        Africa          Asia 
#>             5             2             5             3             7 
#>     Australia 
#>             2 
risk_map$adjacency$Brazil
#> [1] "Venezuela"    "Peru"         "Argentina"    "North_Africa"
```
