# Win probability and expected survivors for a battle

Computes the probability that the attacker conquers the territory,
together with the expected surviving armies on both sides. The default
`"mc"` method simulates `n` independent battles; `"exact"` solves the
absorbing Markov chain over army states and involves no simulation.

## Usage

``` r
rk_battle_odds(
  att_armies,
  def_armies,
  n = 10000L,
  max_def = 2L,
  method = c("mc", "exact")
)
```

## Arguments

- att_armies:

  Number of armies on the attacking territory (must be `>= 2`, since one
  army must remain behind).

- def_armies:

  Number of armies on the defending territory (`>= 1`).

- n:

  Number of simulated battles. Ignored when `method = "exact"`.

- max_def:

  Maximum defender dice permitted (default `2L`).

- method:

  Either `"mc"` (Monte Carlo, the default) or `"exact"`.

## Value

A one-row
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with columns:

- `att_armies`, `def_armies`:

  integer, the starting armies.

- `method`:

  character, `"mc"` or `"exact"`.

- `n`:

  integer, the number of simulated battles; `NA_integer_` for the exact
  method.

- `p_conquer`:

  double, probability that the attacker takes the territory.

- `e_att_survivors`, `e_def_survivors`:

  double, expected armies left on the attacking and defending territory
  when the battle ends.

## See also

Other combat:
[`rk_battle()`](https://r-heller.github.io/risikoR/reference/rk_battle.md),
[`rk_duel()`](https://r-heller.github.io/risikoR/reference/rk_duel.md),
[`rk_duel_dist()`](https://r-heller.github.io/risikoR/reference/rk_duel_dist.md),
[`rk_duel_odds()`](https://r-heller.github.io/risikoR/reference/rk_duel_odds.md),
[`rk_odds_table()`](https://r-heller.github.io/risikoR/reference/rk_odds_table.md)

## Examples

``` r
# Exact, no simulation
rk_battle_odds(10, 8, method = "exact")
#> # A tibble: 1 × 7
#>   att_armies def_armies method     n p_conquer e_att_survivors e_def_survivors
#>        <int>      <int> <chr>  <int>     <dbl>           <dbl>           <dbl>
#> 1         10          8 exact     NA     0.646            4.05            1.23

set.seed(1)
rk_battle_odds(10, 8, n = 500)
#> # A tibble: 1 × 7
#>   att_armies def_armies method     n p_conquer e_att_survivors e_def_survivors
#>        <int>      <int> <chr>  <int>     <dbl>           <dbl>           <dbl>
#> 1         10          8 mc       500     0.588            3.74            1.46
```
