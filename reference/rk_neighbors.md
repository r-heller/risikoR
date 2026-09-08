# Neighbouring territories

Returns the territories adjacent to `territory`.

## Usage

``` r
rk_neighbors(x, territory)
```

## Arguments

- x:

  An `rk_map` or an `rk_game`.

- territory:

  A single territory name.

## Value

A character vector of neighbouring territory names, in map order.

## See also

Other map:
[`risk_map`](https://r-heller.github.io/risikoR/reference/risk_map.md),
[`rk_map()`](https://r-heller.github.io/risikoR/reference/rk_map.md),
[`rk_world()`](https://r-heller.github.io/risikoR/reference/rk_world.md)

## Examples

``` r
rk_neighbors(rk_world(), "Egypt")
#> [1] "North_Africa"    "Southern_Europe" "Middle_East"     "East_Africa"    
```
