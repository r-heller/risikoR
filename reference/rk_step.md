# Advance the game by one action

Applies a single action to the game state. This is the atomic step used
by
[`rk_play()`](https://r-heller.github.io/risikoR/reference/rk_play.md),
the AI agents and the Shiny app. When `action` is not supplied the
action is chosen by `policy`.

## Usage

``` r
rk_step(game, action = NULL, policy = rk_ai("random"))
```

## Arguments

- game:

  An `rk_game` object.

- action:

  A named list describing the action, or `NULL` to let `policy` choose.
  The `action` element must be one of `"reinforce"` (with `placements`),
  `"attack"` (with `from`, `to` and optionally `move`), `"fortify"`
  (with `from`, `to`, `armies`) or `"end_turn"`.

- policy:

  A function of `(game, player)` returning such a list; see
  [`rk_ai()`](https://r-heller.github.io/risikoR/reference/rk_ai.md).
  Only used when `action` is `NULL`.

## Value

A new `rk_game` object. The input `game` is left unchanged.

## See also

Other turn:
[`rk_attack()`](https://r-heller.github.io/risikoR/reference/rk_attack.md),
[`rk_end_turn()`](https://r-heller.github.io/risikoR/reference/rk_end_turn.md),
[`rk_fortify()`](https://r-heller.github.io/risikoR/reference/rk_fortify.md),
[`rk_legal_attacks()`](https://r-heller.github.io/risikoR/reference/rk_legal_attacks.md),
[`rk_reinforce()`](https://r-heller.github.io/risikoR/reference/rk_reinforce.md)

## Examples

``` r
game <- rk_game(c("Red", "Blue"), seed = 1)
set.seed(1)
rk_step(game, policy = rk_ai("random"))$phase
#> [1] "attack"
```
