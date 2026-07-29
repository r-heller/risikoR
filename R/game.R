#' Create a new Risk game state
#'
#' Constructs an `rk_game` object holding the players, territory ownership and
#' army counts, the map, and whose turn it is. Territories are dealt out at
#' random and each player then spreads their starting armies over the
#' territories they hold (40 armies for two players, 35 for three, and so on
#' down to 20 for six, as in the printed rules). The default map is the classic
#' 42-territory world (see [rk_world()]).
#'
#' @param players Character vector of 2 to 6 unique player names.
#' @param map An `rk_map` object. Defaults to [rk_world()].
#' @param seed Optional whole number seed for the random deal. Supplying it
#'   calls [set.seed()] and therefore resets the caller's random number stream.
#'
#' @return An S3 object of class `rk_game`: a list with elements
#'   \describe{
#'     \item{`players`}{character, the roster in turn order (never changes).}
#'     \item{`active`}{character, the players who still hold territory.}
#'     \item{`map`}{the `rk_map` being played on.}
#'     \item{`state`}{a [tibble::tibble()] with one row per territory and
#'       columns `territory` (character), `owner` (character) and `armies`
#'       (integer), in map order.}
#'     \item{`turn`}{character, the player to move.}
#'     \item{`phase`}{character, one of `"reinforce"`, `"attack"`, `"fortify"`
#'       or `"over"`.}
#'     \item{`round`}{integer, the current round, starting at 1.}
#'     \item{`fortified`}{a flag: has the player to move already fortified?}
#'     \item{`last_battle`}{the `rk_battle` most recently resolved; an empty
#'       battle before the first attack.}
#'     \item{`log`}{a [tibble::tibble()] of actions with columns `round`
#'       (integer), `player`, `action`, `from`, `to` (character), `armies`
#'       (integer) and `conquered` (logical).}
#'   }
#' @export
#' @family game
#' @seealso [rk_reinforce()], [rk_attack()], [rk_fortify()] and [rk_end_turn()]
#'   for the turn cycle, and [rk_play()] to run a whole game.
#'
#' @examples
#' game <- rk_game(c("Red", "Blue", "Green"), seed = 1)
#' game
#' summary(game)
rk_game <- function(players, map = rk_world(), seed = NULL) {
  players <- .rk_check_chr(players, "players")
  if (length(players) < 2L || length(players) > 6L) {
    cli::cli_abort(c(
      "{.arg players} must name 2 to 6 players.",
      "x" = "Got {length(players)}."
    ))
  }
  if (anyDuplicated(players) > 0L) {
    cli::cli_abort("{.arg players} must be unique.")
  }
  .rk_check_map(map, "map")
  if (!is.null(seed)) {
    seed <- .rk_check_count(seed, "seed", -.Machine$integer.max,
                            .Machine$integer.max)
    set.seed(seed)
  }

  terr <- map$territories
  n <- length(terr)
  if (n < length(players)) {
    cli::cli_abort(c(
      "The map must have at least one territory per player.",
      "x" = "{n} territor{?y/ies} for {length(players)} players."
    ))
  }

  owner <- character(n)
  owner[sample.int(n)] <- rep(players, length.out = n)
  armies <- rep(1L, n)
  start <- .rk_starting_armies(length(players))
  for (p in players) {
    own <- which(owner == p)
    extra <- max(0L, start - length(own))
    if (extra > 0L) {
      spread <- tabulate(
        sample.int(length(own), extra, replace = TRUE),
        nbins = length(own)
      )
      armies[own] <- armies[own] + as.integer(spread)
    }
  }

  structure(
    list(
      players = players,
      active = players,
      map = map,
      state = tibble::tibble(territory = terr, owner = owner, armies = armies),
      turn = players[[1L]],
      phase = "reinforce",
      round = 1L,
      fortified = FALSE,
      last_battle = .rk_empty_battle(),
      log = .rk_empty_log()
    ),
    class = "rk_game"
  )
}

#' Who owns a territory
#'
#' @param game An `rk_game` object.
#' @param territory Character vector of territory names.
#'
#' @return A character vector of owner names, the same length as `territory`.
#' @export
#' @family game
#'
#' @examples
#' game <- rk_game(c("Red", "Blue"), seed = 1)
#' rk_owner(game, c("Brazil", "Egypt"))
rk_owner <- function(game, territory) {
  .rk_check_game(game)
  territory <- .rk_check_territory(game$map, territory, "territory")
  game$state$owner[match(territory, game$state$territory)]
}

#' How many armies stand on a territory
#'
#' @inheritParams rk_owner
#'
#' @return An integer vector of army counts, the same length as `territory`.
#' @export
#' @family game
#'
#' @examples
#' game <- rk_game(c("Red", "Blue"), seed = 1)
#' rk_armies(game, "Brazil")
rk_armies <- function(game, territory) {
  .rk_check_game(game)
  territory <- .rk_check_territory(game$map, territory, "territory")
  game$state$armies[match(territory, game$state$territory)]
}

#' Territories held by a player
#'
#' @inheritParams rk_owner
#' @param player A single player name.
#'
#' @return A character vector of territory names in map order; empty when the
#'   player has been eliminated.
#' @export
#' @family game
#'
#' @examples
#' game <- rk_game(c("Red", "Blue"), seed = 1)
#' rk_territories(game, "Red")
rk_territories <- function(game, player) {
  .rk_check_game(game)
  player <- .rk_check_player(game, player)
  game$state$territory[game$state$owner == player]
}

#' Continents fully controlled by a player
#'
#' @inheritParams rk_territories
#'
#' @return A character vector of continent names; empty when the player holds
#'   no complete continent.
#' @export
#' @family game
#'
#' @examples
#' game <- rk_game(c("Red", "Blue"), seed = 1)
#' rk_continents_held(game, "Red")
rk_continents_held <- function(game, player) {
  .rk_check_game(game)
  player <- .rk_check_player(game, player)
  .rk_continents_held(game, player)
}

#' Reinforcement armies available to a player
#'
#' The standard allowance: one army per three territories held, never fewer
#' than three, plus the bonus of every continent the player fully controls.
#'
#' @inheritParams rk_territories
#'
#' @return A single integer; `0L` for an eliminated player.
#' @export
#' @family game
#'
#' @examples
#' game <- rk_game(c("Red", "Blue"), seed = 1)
#' rk_reinforcements(game, "Red")
rk_reinforcements <- function(game, player) {
  .rk_check_game(game)
  player <- .rk_check_player(game, player)
  .rk_reinforcements(game, player)
}

#' Has the game been won?
#'
#' @inheritParams rk_owner
#'
#' @return A single logical: `TRUE` once exactly one player holds territory.
#' @export
#' @family game
#' @seealso [rk_winner()] for the winner's name.
#'
#' @examples
#' game <- rk_game(c("Red", "Blue"), seed = 1)
#' rk_is_winner(game)
rk_is_winner <- function(game) {
  .rk_check_game(game)
  length(game$active) == 1L
}

#' The winner of the game
#'
#' @inheritParams rk_owner
#'
#' @return A single string: the winning player's name, or `NA_character_` while
#'   the game is undecided.
#' @export
#' @family game
#'
#' @examples
#' game <- rk_game(c("Red", "Blue"), seed = 1)
#' rk_winner(game)
rk_winner <- function(game) {
  .rk_check_game(game)
  if (length(game$active) == 1L) game$active[[1L]] else NA_character_
}

#' Standings for every player
#'
#' @param object An `rk_game` object.
#' @param ... Not used.
#'
#' @return A [tibble::tibble()] with one row per player (roster order) and
#'   columns `player` (character), `territories` (integer), `armies` (integer),
#'   `continents` (integer), `reinforcements` (integer) and `alive` (logical).
#' @export
#' @family game
#'
#' @examples
#' summary(rk_game(c("Red", "Blue", "Green"), seed = 1))
summary.rk_game <- function(object, ...) {
  rlang::check_dots_empty()
  players <- object$players
  n_terr <- vapply(
    players, function(p) sum(object$state$owner == p), integer(1L)
  )
  n_army <- vapply(
    players, function(p) sum(object$state$armies[object$state$owner == p]),
    integer(1L)
  )
  n_cont <- vapply(
    players, function(p) length(.rk_continents_held(object, p)), integer(1L)
  )
  reinf <- vapply(
    players, function(p) .rk_reinforcements(object, p), integer(1L)
  )
  tibble::tibble(
    player = players,
    territories = unname(n_terr),
    armies = unname(n_army),
    continents = unname(n_cont),
    reinforcements = unname(reinf),
    alive = players %in% object$active
  )
}

#' @export
format.rk_game <- function(x, ...) {
  rlang::check_dots_empty()
  standings <- summary(x)
  head <- cli::format_inline(
    "<rk_game> {length(x$players)} players on ",
    "{length(x$map$territories)} territories, round {x$round}"
  )
  status <- if (x$phase == "over") {
    cli::format_inline("Winner: {rk_winner(x)}")
  } else {
    cli::format_inline("Turn: {x$turn} ({x$phase} phase)")
  }
  rows <- vapply(
    seq_len(nrow(standings)),
    function(i) {
      row <- standings[i, ]
      mark <- if (row$player == x$turn && x$phase != "over") "*" else " "
      cli::format_inline(
        "{mark} {row$player}: {row$territories} territor{?y/ies}, ",
        "{row$armies} armies, {row$continents} continent{?s}"
      )
    },
    character(1L)
  )
  c(head, status, rows)
}

#' @export
print.rk_game <- function(x, ...) {
  rlang::check_dots_empty()
  cli::cat_line(format(x))
  invisible(x)
}

# --- internal helpers -------------------------------------------------------

.rk_starting_armies <- function(n_players) {
  c(40L, 35L, 30L, 25L, 20L)[[n_players - 1L]]
}

.rk_empty_log <- function() {
  tibble::tibble(
    round = integer(0),
    player = character(0),
    action = character(0),
    from = character(0),
    to = character(0),
    armies = integer(0),
    conquered = logical(0)
  )
}

.rk_log <- function(game, action, from = NA_character_, to = NA_character_,
                    armies = NA_integer_, conquered = NA) {
  game$log <- rbind(
    game$log,
    tibble::tibble(
      round = as.integer(game$round),
      player = game$turn,
      action = action,
      from = from,
      to = to,
      armies = as.integer(armies),
      conquered = conquered
    )
  )
  game
}

.rk_continents_held <- function(game, player) {
  owned <- game$state$territory[game$state$owner == player]
  keep <- vapply(
    game$map$continent,
    function(members) all(members %in% owned),
    logical(1L)
  )
  names(game$map$continent)[keep]
}

.rk_reinforcements <- function(game, player) {
  n_terr <- sum(game$state$owner == player)
  if (n_terr == 0L) {
    return(0L)
  }
  base <- max(3L, n_terr %/% 3L)
  bonus <- sum(game$map$continent_bonus[.rk_continents_held(game, player)])
  as.integer(base + bonus)
}

# Row index of a territory in `game$state`.
.rk_index <- function(game, territory) {
  match(territory, game$state$territory)
}
