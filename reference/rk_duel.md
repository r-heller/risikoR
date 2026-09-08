# Resolve a single Risk dice duel

Resolves one throw of the dice in a Risk battle. The attacker rolls
`n_att` dice and the defender `n_def` dice; the highest attacker die is
compared with the highest defender die, then (if both rolled at least
two dice) the second-highest pair. The attacker removes a defending army
when strictly higher; ties and lower rolls remove an attacking army.

## Usage

``` r
rk_duel(n_att, n_def, max_def = 2L)
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

A list with four elements: `att_loss` and `def_loss` (integers summing
to `min(n_att, n_def)`, the number of compared dice pairs), and
`att_roll` and `def_roll`, the integer dice rolls sorted in decreasing
order.

## See also

[`rk_duel_odds()`](https://r-heller.github.io/risikoR/reference/rk_duel_odds.md)
for the exact outcome probabilities.

Other combat:
[`rk_battle()`](https://r-heller.github.io/risikoR/reference/rk_battle.md),
[`rk_battle_odds()`](https://r-heller.github.io/risikoR/reference/rk_battle_odds.md),
[`rk_duel_dist()`](https://r-heller.github.io/risikoR/reference/rk_duel_dist.md),
[`rk_duel_odds()`](https://r-heller.github.io/risikoR/reference/rk_duel_odds.md),
[`rk_odds_table()`](https://r-heller.github.io/risikoR/reference/rk_odds_table.md)

## Examples

``` r
set.seed(1)
rk_duel(3, 2)
#> $att_loss
#> [1] 2
#> 
#> $def_loss
#> [1] 0
#> 
#> $att_roll
#> [1] 4 1 1
#> 
#> $def_roll
#> [1] 5 2
#> 
```
