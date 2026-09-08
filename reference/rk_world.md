# The classic Risk world map

Returns the standard 42-territory, 6-continent Risk map as an `rk_map`
object, built from the packaged
[risk_map](https://r-heller.github.io/risikoR/reference/risk_map.md)
dataset.

## Usage

``` r
rk_world()
```

## Value

An S3 object of class `rk_map`; see
[`rk_map()`](https://r-heller.github.io/risikoR/reference/rk_map.md) for
the structure.

## See also

Other map:
[`risk_map`](https://r-heller.github.io/risikoR/reference/risk_map.md),
[`rk_map()`](https://r-heller.github.io/risikoR/reference/rk_map.md),
[`rk_neighbors()`](https://r-heller.github.io/risikoR/reference/rk_neighbors.md)

## Examples

``` r
m <- rk_world()
m$continent_bonus
#> North_America South_America        Europe        Africa          Asia 
#>             5             2             5             3             7 
#>     Australia 
#>             2 
rk_neighbors(m, "Brazil")
#> [1] "Venezuela"    "Peru"         "Argentina"    "North_Africa"
```
