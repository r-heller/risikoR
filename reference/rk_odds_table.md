# Conquest probability over a grid of army counts

Evaluates
[`rk_battle_odds()`](https://r-heller.github.io/risikoR/reference/rk_battle_odds.md)
over every combination of attacker and defender armies in `att_range`
and `def_range`. This is the reference table behind
[`rk_plot_odds_heatmap()`](https://r-heller.github.io/risikoR/reference/rk_plot_odds_heatmap.md).

## Usage

``` r
rk_odds_table(
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

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with one row per combination and columns `att_armies` (integer),
`def_armies` (integer), `method` (character), `p_conquer`,
`e_att_survivors` and `e_def_survivors` (double). Rows are ordered by
`att_armies`, then `def_armies`.

## See also

Other combat:
[`rk_battle()`](https://r-heller.github.io/risikoR/reference/rk_battle.md),
[`rk_battle_odds()`](https://r-heller.github.io/risikoR/reference/rk_battle_odds.md),
[`rk_duel()`](https://r-heller.github.io/risikoR/reference/rk_duel.md),
[`rk_duel_dist()`](https://r-heller.github.io/risikoR/reference/rk_duel_dist.md),
[`rk_duel_odds()`](https://r-heller.github.io/risikoR/reference/rk_duel_odds.md)

## Examples

``` r
rk_odds_table(att_range = 2:6, def_range = 1:5)
#> # A tibble: 25 × 6
#>    att_armies def_armies method p_conquer e_att_survivors e_def_survivors
#>         <int>      <int> <chr>      <dbl>           <dbl>           <dbl>
#>  1          2          1 exact    0.417              1.42           0.583
#>  2          2          2 exact    0.106              1.11           1.64 
#>  3          2          3 exact    0.0270             1.03           2.65 
#>  4          2          4 exact    0.00688            1.01           3.66 
#>  5          2          5 exact    0.00175            1.00           4.66 
#>  6          3          1 exact    0.754              2.33           0.246
#>  7          3          2 exact    0.363              1.59           1.09 
#>  8          3          3 exact    0.206              1.34           1.93 
#>  9          3          4 exact    0.0913             1.14           2.90 
#> 10          3          5 exact    0.0491             1.08           3.87 
#> # ℹ 15 more rows
```
