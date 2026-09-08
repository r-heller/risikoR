# Simulate a full battle between two territories

Repeatedly resolves dice duels via
[`rk_duel()`](https://r-heller.github.io/risikoR/reference/rk_duel.md)
until either the attacker can no longer attack (fewer than two armies
remain on the attacking territory) or the defender is wiped out. At each
step the attacker and defender roll the maximum number of dice permitted
by their remaining armies and the ruleset.

## Usage

``` r
rk_battle(att_armies, def_armies, max_def = 2L)
```

## Arguments

- att_armies:

  Number of armies on the attacking territory (must be `>= 2`, since one
  army must remain behind).

- def_armies:

  Number of armies on the defending territory (`>= 1`).

- max_def:

  Maximum defender dice permitted (default `2L`).

## Value

An S3 object of class `rk_battle`: a list with `att_armies` and
`def_armies` (the starting armies), `att_remaining` and `def_remaining`
(integers), `conquered` (a flag, `TRUE` when the defender was wiped
out), `rounds` (integer number of duels fought) and `log`, a
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with one row per duel and columns `round`, `att_loss` and `def_loss`
(all integer).

## See also

[`rk_battle_odds()`](https://r-heller.github.io/risikoR/reference/rk_battle_odds.md)
for win probabilities without simulating.

Other combat:
[`rk_battle_odds()`](https://r-heller.github.io/risikoR/reference/rk_battle_odds.md),
[`rk_duel()`](https://r-heller.github.io/risikoR/reference/rk_duel.md),
[`rk_duel_dist()`](https://r-heller.github.io/risikoR/reference/rk_duel_dist.md),
[`rk_duel_odds()`](https://r-heller.github.io/risikoR/reference/rk_duel_odds.md),
[`rk_odds_table()`](https://r-heller.github.io/risikoR/reference/rk_odds_table.md)

## Examples

``` r
set.seed(42)
rk_battle(10, 8)
#> <rk_battle> territory conquered after 6 duels
#> Attacker: 6 left · Defender: 0 left
```
