# risikoR 0.1.0

## Initial release

### Combat engine

* `rk_duel()`: resolve one throw of the dice, ties to the defender.
* `rk_duel_dist()`: the exact outcome distribution of a duel, by enumeration.
* `rk_duel_odds()`: expected losses, standard deviation and the probabilities
  of the three qualitative outcomes.
* `rk_battle()`: fight a territory out duel by duel, with a per-duel log.
* `rk_battle_odds()`: conquest probability and expected survivors, either by
  Monte Carlo (`method = "mc"`) or by solving the absorbing Markov chain
  (`method = "exact"`).
* `rk_odds_table()`: conquest probability over a grid of army counts.

### The board

* `rk_world()`: the classic 42-territory, 6-continent board.
* `rk_map()`: build and validate a custom board, with an automatic layout.
* `rk_neighbors()`: the territories bordering a territory.
* `risk_map`: the packaged board data, including plotting coordinates.

### Game model

* `rk_game()`: deal a game for 2 to 6 players.
* `rk_reinforce()`, `rk_attack()`, `rk_fortify()`, `rk_end_turn()`: the turn
  cycle. Every mutator returns a new game and leaves its input untouched.
* `rk_step()`: apply a single action, from a list or from a policy.
* `rk_legal_attacks()`, `rk_owner()`, `rk_armies()`, `rk_territories()`,
  `rk_continents_held()`, `rk_reinforcements()`, `rk_is_winner()`,
  `rk_winner()`: accessors with stable return types.
* `summary()`, `print()` and `format()` methods for `rk_game`.

### Agents

* `rk_ai()`: `"random"`, `"aggressive"` and `"cautious"` policies.
* `rk_play()`: run a whole game and return a per-round standings log.
* `rk_tournament()`: many games, summarised as win rates per strategy.

### Visualisation

* `rk_plot_map()`: the board coloured by owner or by continent.
* `rk_plot_duel()`, `rk_plot_conquest()`, `rk_plot_odds_heatmap()`,
  `rk_plot_tournament()`.
* `autoplot()` methods for `rk_game` and `rk_battle`.

### Application

* `rk_run_app()`: a four-tab Shiny app — play, duel analyser, battle simulator
  and strategy lab.
