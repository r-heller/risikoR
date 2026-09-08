# Changelog

## risikoR 0.1.0

### Initial release

#### Combat engine

- [`rk_duel()`](https://r-heller.github.io/risikoR/reference/rk_duel.md):
  resolve one throw of the dice, ties to the defender.
- [`rk_duel_dist()`](https://r-heller.github.io/risikoR/reference/rk_duel_dist.md):
  the exact outcome distribution of a duel, by enumeration.
- [`rk_duel_odds()`](https://r-heller.github.io/risikoR/reference/rk_duel_odds.md):
  expected losses, standard deviation and the probabilities of the three
  qualitative outcomes.
- [`rk_battle()`](https://r-heller.github.io/risikoR/reference/rk_battle.md):
  fight a territory out duel by duel, with a per-duel log.
- [`rk_battle_odds()`](https://r-heller.github.io/risikoR/reference/rk_battle_odds.md):
  conquest probability and expected survivors, either by Monte Carlo
  (`method = "mc"`) or by solving the absorbing Markov chain
  (`method = "exact"`).
- [`rk_odds_table()`](https://r-heller.github.io/risikoR/reference/rk_odds_table.md):
  conquest probability over a grid of army counts.

#### The board

- [`rk_world()`](https://r-heller.github.io/risikoR/reference/rk_world.md):
  the classic 42-territory, 6-continent board.
- [`rk_map()`](https://r-heller.github.io/risikoR/reference/rk_map.md):
  build and validate a custom board, with an automatic layout.
- [`rk_neighbors()`](https://r-heller.github.io/risikoR/reference/rk_neighbors.md):
  the territories bordering a territory.
- `risk_map`: the packaged board data, including plotting coordinates.

#### Game model

- [`rk_game()`](https://r-heller.github.io/risikoR/reference/rk_game.md):
  deal a game for 2 to 6 players.
- [`rk_reinforce()`](https://r-heller.github.io/risikoR/reference/rk_reinforce.md),
  [`rk_attack()`](https://r-heller.github.io/risikoR/reference/rk_attack.md),
  [`rk_fortify()`](https://r-heller.github.io/risikoR/reference/rk_fortify.md),
  [`rk_end_turn()`](https://r-heller.github.io/risikoR/reference/rk_end_turn.md):
  the turn cycle. Every mutator returns a new game and leaves its input
  untouched.
- [`rk_step()`](https://r-heller.github.io/risikoR/reference/rk_step.md):
  apply a single action, from a list or from a policy.
- [`rk_legal_attacks()`](https://r-heller.github.io/risikoR/reference/rk_legal_attacks.md),
  [`rk_owner()`](https://r-heller.github.io/risikoR/reference/rk_owner.md),
  [`rk_armies()`](https://r-heller.github.io/risikoR/reference/rk_armies.md),
  [`rk_territories()`](https://r-heller.github.io/risikoR/reference/rk_territories.md),
  [`rk_continents_held()`](https://r-heller.github.io/risikoR/reference/rk_continents_held.md),
  [`rk_reinforcements()`](https://r-heller.github.io/risikoR/reference/rk_reinforcements.md),
  [`rk_is_winner()`](https://r-heller.github.io/risikoR/reference/rk_is_winner.md),
  [`rk_winner()`](https://r-heller.github.io/risikoR/reference/rk_winner.md):
  accessors with stable return types.
- [`summary()`](https://rdrr.io/r/base/summary.html),
  [`print()`](https://rdrr.io/r/base/print.html) and
  [`format()`](https://rdrr.io/r/base/format.html) methods for
  `rk_game`.

#### Agents

- [`rk_ai()`](https://r-heller.github.io/risikoR/reference/rk_ai.md):
  `"random"`, `"aggressive"` and `"cautious"` policies.
- [`rk_play()`](https://r-heller.github.io/risikoR/reference/rk_play.md):
  run a whole game and return a per-round standings log.
- [`rk_tournament()`](https://r-heller.github.io/risikoR/reference/rk_tournament.md):
  many games, summarised as win rates per strategy.

#### Visualisation

- [`rk_plot_map()`](https://r-heller.github.io/risikoR/reference/rk_plot_map.md):
  the board drawn as tiled landmasses grouped into continents, coloured
  by owner or by continent, with army counts on chips and the two links
  that cannot be shared borders drawn as a sea route and as stubs at the
  board edge. The layout is solved so that the borders on the picture
  are exactly the borders
  [`rk_neighbors()`](https://r-heller.github.io/risikoR/reference/rk_neighbors.md)
  reports, and a test enforces it.
- [`rk_plot_duel()`](https://r-heller.github.io/risikoR/reference/rk_plot_duel.md),
  [`rk_plot_conquest()`](https://r-heller.github.io/risikoR/reference/rk_plot_conquest.md),
  [`rk_plot_odds_heatmap()`](https://r-heller.github.io/risikoR/reference/rk_plot_odds_heatmap.md),
  [`rk_plot_tournament()`](https://r-heller.github.io/risikoR/reference/rk_plot_tournament.md).
- [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  methods for `rk_game` and `rk_battle`.
- One shared theme and one colourblind-safe palette across every plot,
  so a player called “Red” is drawn red and continents keep their
  colours.

#### Application

- [`rk_run_app()`](https://r-heller.github.io/risikoR/reference/rk_run_app.md):
  a four-tab Shiny app – play, duel analyser, battle simulator and
  strategy lab.
