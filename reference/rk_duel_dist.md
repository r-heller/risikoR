# Exact loss distribution for a single dice duel

Enumerates every equally likely combination of attacker and defender
dice and returns the exact probability of each possible outcome of one
duel. No simulation is involved.

## Usage

``` r
rk_duel_dist(n_att, n_def, max_def = 2L)
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

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with one row per possible outcome, ordered by `att_loss`, and columns:

- `n_att`:

  integer, attacker dice.

- `n_def`:

  integer, defender dice.

- `att_loss`:

  integer, armies lost by the attacker, from `0` to `min(n_att, n_def)`.

- `def_loss`:

  integer, armies lost by the defender; always
  `min(n_att, n_def) - att_loss`.

- `p`:

  double, probability of the outcome. The column sums to 1.

## See also

Other combat:
[`rk_battle()`](https://r-heller.github.io/risikoR/reference/rk_battle.md),
[`rk_battle_odds()`](https://r-heller.github.io/risikoR/reference/rk_battle_odds.md),
[`rk_duel()`](https://r-heller.github.io/risikoR/reference/rk_duel.md),
[`rk_duel_odds()`](https://r-heller.github.io/risikoR/reference/rk_duel_odds.md),
[`rk_odds_table()`](https://r-heller.github.io/risikoR/reference/rk_odds_table.md)

## Examples

``` r
# The classic three-against-two distribution
rk_duel_dist(3, 2)
#> # A tibble: 3 × 5
#>   n_att n_def att_loss def_loss     p
#>   <int> <int>    <int>    <int> <dbl>
#> 1     3     2        0        2 0.372
#> 2     3     2        1        1 0.336
#> 3     3     2        2        0 0.293
```
