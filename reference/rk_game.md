# Create a new Risk game state

Constructs an `rk_game` object holding the players, territory ownership
and army counts, the map, and whose turn it is. Territories are dealt
out at random and each player then spreads their starting armies over
the territories they hold (40 armies for two players, 35 for three, and
so on down to 20 for six, as in the printed rules). The default map is
the classic 42-territory world (see
[`rk_world()`](https://r-heller.github.io/risikoR/reference/rk_world.md)).

## Usage

``` r
rk_game(players, map = rk_world(), seed = NULL)
```

## Arguments

- players:

  Character vector of 2 to 6 unique player names.

- map:

  An `rk_map` object. Defaults to
  [`rk_world()`](https://r-heller.github.io/risikoR/reference/rk_world.md).

- seed:

  Optional whole number seed for the random deal. Supplying it calls
  [`set.seed()`](https://rdrr.io/r/base/Random.html) and therefore
  resets the caller's random number stream.

## Value

An S3 object of class `rk_game`: a list with elements

- `players`:

  character, the roster in turn order (never changes).

- `active`:

  character, the players who still hold territory.

- `map`:

  the `rk_map` being played on.

- `state`:

  a
  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
  with one row per territory and columns `territory` (character),
  `owner` (character) and `armies` (integer), in map order.

- `turn`:

  character, the player to move.

- `phase`:

  character, one of `"reinforce"`, `"attack"`, `"fortify"` or `"over"`.

- `round`:

  integer, the current round, starting at 1.

- `fortified`:

  a flag: has the player to move already fortified?

- `last_battle`:

  the `rk_battle` most recently resolved; an empty battle before the
  first attack.

- `log`:

  a
  [`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
  of actions with columns `round` (integer), `player`, `action`, `from`,
  `to` (character), `armies` (integer) and `conquered` (logical).

## See also

[`rk_reinforce()`](https://r-heller.github.io/risikoR/reference/rk_reinforce.md),
[`rk_attack()`](https://r-heller.github.io/risikoR/reference/rk_attack.md),
[`rk_fortify()`](https://r-heller.github.io/risikoR/reference/rk_fortify.md)
and
[`rk_end_turn()`](https://r-heller.github.io/risikoR/reference/rk_end_turn.md)
for the turn cycle, and
[`rk_play()`](https://r-heller.github.io/risikoR/reference/rk_play.md)
to run a whole game.

Other game:
[`rk_armies()`](https://r-heller.github.io/risikoR/reference/rk_armies.md),
[`rk_continents_held()`](https://r-heller.github.io/risikoR/reference/rk_continents_held.md),
[`rk_is_winner()`](https://r-heller.github.io/risikoR/reference/rk_is_winner.md),
[`rk_owner()`](https://r-heller.github.io/risikoR/reference/rk_owner.md),
[`rk_reinforcements()`](https://r-heller.github.io/risikoR/reference/rk_reinforcements.md),
[`rk_territories()`](https://r-heller.github.io/risikoR/reference/rk_territories.md),
[`rk_winner()`](https://r-heller.github.io/risikoR/reference/rk_winner.md),
[`summary.rk_game()`](https://r-heller.github.io/risikoR/reference/summary.rk_game.md)

## Examples

``` r
game <- rk_game(c("Red", "Blue", "Green"), seed = 1)
game
#> <rk_game> 3 players on 42 territories, round 1
#> Turn: Red (reinforce phase)
#> * Red: 14 territories, 35 armies, 0 continents
#>   Blue: 14 territories, 35 armies, 0 continents
#>   Green: 14 territories, 35 armies, 0 continents
summary(game)
#> # A tibble: 3 × 6
#>   player territories armies continents reinforcements alive
#>   <chr>        <int>  <int>      <int>          <int> <lgl>
#> 1 Red             14     35          0              4 TRUE 
#> 2 Blue            14     35          0              4 TRUE 
#> 3 Green           14     35          0              4 TRUE 
```
