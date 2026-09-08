# Expected losses and win probability for a single dice duel

Summarises the exact outcome distribution of one Risk dice duel (see
[`rk_duel_dist()`](https://r-heller.github.io/risikoR/reference/rk_duel_dist.md))
as expected losses and the probabilities of the three qualitative
outcomes. No simulation is used.

## Usage

``` r
rk_duel_odds(n_att, n_def, max_def = 2L)
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

A one-row
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with columns:

- `n_att`:

  integer, attacker dice.

- `n_def`:

  integer, defender dice.

- `e_att_loss`:

  double, expected armies lost by the attacker.

- `e_def_loss`:

  double, expected armies lost by the defender, equal to
  `min(n_att, n_def) - e_att_loss`.

- `sd_loss`:

  double, standard deviation of the attacker's loss.

- `p_att_wins_all`:

  double, probability that the attacker wins every compared pair, i.e.
  `att_loss == 0`.

- `p_def_wins_all`:

  double, probability that the defender wins every compared pair, i.e.
  `att_loss == min(n_att, n_def)`.

- `p_split`:

  double, probability that both sides lose exactly one army. A split
  needs two compared pairs, so it is `0` whenever only one pair is
  compared – in that case `p_att_wins_all + p_def_wins_all` equals 1.

## See also

[`rk_duel_dist()`](https://r-heller.github.io/risikoR/reference/rk_duel_dist.md)
for the full outcome distribution.

Other combat:
[`rk_battle()`](https://r-heller.github.io/risikoR/reference/rk_battle.md),
[`rk_battle_odds()`](https://r-heller.github.io/risikoR/reference/rk_battle_odds.md),
[`rk_duel()`](https://r-heller.github.io/risikoR/reference/rk_duel.md),
[`rk_duel_dist()`](https://r-heller.github.io/risikoR/reference/rk_duel_dist.md),
[`rk_odds_table()`](https://r-heller.github.io/risikoR/reference/rk_odds_table.md)

## Examples

``` r
rk_duel_odds(3, 2)
#> # A tibble: 1 × 8
#>   n_att n_def e_att_loss e_def_loss sd_loss p_att_wins_all p_def_wins_all
#>   <int> <int>      <dbl>      <dbl>   <dbl>          <dbl>          <dbl>
#> 1     3     2      0.921       1.08   0.811          0.372          0.293
#> # ℹ 1 more variable: p_split <dbl>

# One die each: a split is impossible
rk_duel_odds(1, 1)
#> # A tibble: 1 × 8
#>   n_att n_def e_att_loss e_def_loss sd_loss p_att_wins_all p_def_wins_all
#>   <int> <int>      <dbl>      <dbl>   <dbl>          <dbl>          <dbl>
#> 1     1     1      0.583      0.417   0.493          0.417          0.583
#> # ℹ 1 more variable: p_split <dbl>
```
