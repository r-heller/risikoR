# Built-in artificial-intelligence agents

Factory returning a scriptable AI policy: a function of `(game, player)`
that inspects the game state and returns the action to take next, ready
for
[`rk_step()`](https://r-heller.github.io/risikoR/reference/rk_step.md).

## Usage

``` r
rk_ai(strategy = c("random", "aggressive", "cautious"), ratio = 1.5)
```

## Arguments

- strategy:

  One of `"random"`, `"aggressive"` or `"cautious"`.

- ratio:

  Minimum ratio of attacking to defending armies before the `"cautious"`
  strategy will attack. Ignored by the other strategies.

## Value

A function of `(game, player)` returning an action list with an `action`
element of `"reinforce"`, `"attack"`, `"fortify"` or `"end_turn"`, plus
the arguments that action needs.

## Details

The supplied strategies are:

- `"random"`:

  Spreads reinforcements at random, then picks uniformly among the legal
  attacks, ending the turn with probability `0.25` at each decision
  point.

- `"aggressive"`:

  Stacks every reinforcement on its strongest frontier territory and
  attacks the weakest reachable enemy for as long as it outnumbers the
  defender.

- `"cautious"`:

  Reinforces its weakest frontier, attacks only when the attacking
  armies are at least `ratio` times the defending armies, and otherwise
  pulls armies out of the interior towards the frontier.

## See also

[`rk_play()`](https://r-heller.github.io/risikoR/reference/rk_play.md)
to run a whole game,
[`rk_step()`](https://r-heller.github.io/risikoR/reference/rk_step.md)
to apply one action.

Other ai:
[`rk_play()`](https://r-heller.github.io/risikoR/reference/rk_play.md),
[`rk_tournament()`](https://r-heller.github.io/risikoR/reference/rk_tournament.md)

## Examples

``` r
bot <- rk_ai("aggressive")
game <- rk_game(c("Red", "Blue"), seed = 1)
bot(game, "Red")$action
#> [1] "reinforce"
```
