# Package index

## Combat engine

One throw of the dice, exactly enumerated, and the battles built from
it.

- [`rk_duel()`](https://r-heller.github.io/risikoR/reference/rk_duel.md)
  : Resolve a single Risk dice duel
- [`rk_duel_dist()`](https://r-heller.github.io/risikoR/reference/rk_duel_dist.md)
  : Exact loss distribution for a single dice duel
- [`rk_duel_odds()`](https://r-heller.github.io/risikoR/reference/rk_duel_odds.md)
  : Expected losses and win probability for a single dice duel
- [`rk_battle()`](https://r-heller.github.io/risikoR/reference/rk_battle.md)
  : Simulate a full battle between two territories
- [`rk_battle_odds()`](https://r-heller.github.io/risikoR/reference/rk_battle_odds.md)
  : Win probability and expected survivors for a battle
- [`rk_odds_table()`](https://r-heller.github.io/risikoR/reference/rk_odds_table.md)
  : Conquest probability over a grid of army counts

## The board

The classic world map, custom boards and the adjacency graph.

- [`rk_world()`](https://r-heller.github.io/risikoR/reference/rk_world.md)
  : The classic Risk world map
- [`rk_map()`](https://r-heller.github.io/risikoR/reference/rk_map.md) :
  Build a Risk map
- [`rk_neighbors()`](https://r-heller.github.io/risikoR/reference/rk_neighbors.md)
  : Neighbouring territories
- [`risk_map`](https://r-heller.github.io/risikoR/reference/risk_map.md)
  : The classic Risk world board

## Game state

Creating a game and asking it questions.

- [`rk_game()`](https://r-heller.github.io/risikoR/reference/rk_game.md)
  : Create a new Risk game state
- [`rk_owner()`](https://r-heller.github.io/risikoR/reference/rk_owner.md)
  : Who owns a territory
- [`rk_armies()`](https://r-heller.github.io/risikoR/reference/rk_armies.md)
  : How many armies stand on a territory
- [`rk_territories()`](https://r-heller.github.io/risikoR/reference/rk_territories.md)
  : Territories held by a player
- [`rk_continents_held()`](https://r-heller.github.io/risikoR/reference/rk_continents_held.md)
  : Continents fully controlled by a player
- [`rk_reinforcements()`](https://r-heller.github.io/risikoR/reference/rk_reinforcements.md)
  : Reinforcement armies available to a player
- [`rk_is_winner()`](https://r-heller.github.io/risikoR/reference/rk_is_winner.md)
  : Has the game been won?
- [`rk_winner()`](https://r-heller.github.io/risikoR/reference/rk_winner.md)
  : The winner of the game
- [`summary(`*`<rk_game>`*`)`](https://r-heller.github.io/risikoR/reference/summary.rk_game.md)
  : Standings for every player

## The turn cycle

Reinforce, attack, fortify, hand over. Every mutator returns a new game.

- [`rk_reinforce()`](https://r-heller.github.io/risikoR/reference/rk_reinforce.md)
  : Place reinforcement armies
- [`rk_attack()`](https://r-heller.github.io/risikoR/reference/rk_attack.md)
  : Attack a neighbouring territory
- [`rk_fortify()`](https://r-heller.github.io/risikoR/reference/rk_fortify.md)
  : Move armies between two connected territories
- [`rk_end_turn()`](https://r-heller.github.io/risikoR/reference/rk_end_turn.md)
  : End the current turn
- [`rk_step()`](https://r-heller.github.io/risikoR/reference/rk_step.md)
  : Advance the game by one action
- [`rk_legal_attacks()`](https://r-heller.github.io/risikoR/reference/rk_legal_attacks.md)
  : Attacks available to a player

## Agents and tournaments

Scriptable policies, whole games and strategy comparisons.

- [`rk_ai()`](https://r-heller.github.io/risikoR/reference/rk_ai.md) :
  Built-in artificial-intelligence agents
- [`rk_play()`](https://r-heller.github.io/risikoR/reference/rk_play.md)
  : Play a game to the end
- [`rk_tournament()`](https://r-heller.github.io/risikoR/reference/rk_tournament.md)
  : Run many games and compare strategies

## Visualisation

Every plot function returns a ggplot2 object.

- [`rk_plot_map()`](https://r-heller.github.io/risikoR/reference/rk_plot_map.md)
  : Plot the world map
- [`rk_plot_duel()`](https://r-heller.github.io/risikoR/reference/rk_plot_duel.md)
  : Plot the loss distribution of a single duel
- [`rk_plot_conquest()`](https://r-heller.github.io/risikoR/reference/rk_plot_conquest.md)
  : Plot conquest probability across defender strength
- [`rk_plot_odds_heatmap()`](https://r-heller.github.io/risikoR/reference/rk_plot_odds_heatmap.md)
  : Heatmap of conquest probability
- [`rk_plot_tournament()`](https://r-heller.github.io/risikoR/reference/rk_plot_tournament.md)
  : Plot tournament win rates
- [`autoplot(`*`<rk_game>`*`)`](https://r-heller.github.io/risikoR/reference/autoplot.rk_game.md)
  [`autoplot(`*`<rk_battle>`*`)`](https://r-heller.github.io/risikoR/reference/autoplot.rk_game.md)
  : Plot a game or a battle

## Application

- [`rk_run_app()`](https://r-heller.github.io/risikoR/reference/rk_run_app.md)
  : Launch the interactive risikoR application
