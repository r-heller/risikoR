#' Built-in artificial-intelligence agents
#'
#' Factory returning a scriptable AI policy: a function of `(game, player)`
#' that inspects the game state and returns the action to take next, ready for
#' [rk_step()].
#'
#' The supplied strategies are:
#' \describe{
#'   \item{`"random"`}{Spreads reinforcements at random, then picks uniformly
#'     among the legal attacks, ending the turn with probability `0.25` at each
#'     decision point.}
#'   \item{`"aggressive"`}{Stacks every reinforcement on its strongest frontier
#'     territory and attacks the weakest reachable enemy for as long as it
#'     outnumbers the defender.}
#'   \item{`"cautious"`}{Reinforces its weakest frontier, attacks only when the
#'     attacking armies are at least `ratio` times the defending armies, and
#'     otherwise pulls armies out of the interior towards the frontier.}
#' }
#'
#' @param strategy One of `"random"`, `"aggressive"` or `"cautious"`.
#' @param ratio Minimum ratio of attacking to defending armies before the
#'   `"cautious"` strategy will attack. Ignored by the other strategies.
#'
#' @return A function of `(game, player)` returning an action list with an
#'   `action` element of `"reinforce"`, `"attack"`, `"fortify"` or
#'   `"end_turn"`, plus the arguments that action needs.
#' @export
#' @family ai
#' @seealso [rk_play()] to run a whole game, [rk_step()] to apply one action.
#'
#' @examples
#' bot <- rk_ai("aggressive")
#' game <- rk_game(c("Red", "Blue"), seed = 1)
#' bot(game, "Red")$action
rk_ai <- function(strategy = c("random", "aggressive", "cautious"),
                  ratio = 1.5) {
  strategy <- match.arg(strategy)
  if (!is.numeric(ratio) || length(ratio) != 1L || is.na(ratio) || ratio <= 0) {
    cli::cli_abort("{.arg ratio} must be a single positive number.")
  }
  force(ratio)
  function(game, player) {
    .rk_check_game(game)
    player <- .rk_check_player(game, player)
    switch(
      strategy,
      random = .rk_policy_random(game, player),
      aggressive = .rk_policy_aggressive(game, player),
      cautious = .rk_policy_cautious(game, player, ratio)
    )
  }
}

#' Play a game to the end
#'
#' Runs a complete game, letting each player's policy choose every action,
#' until somebody has conquered the world or `max_rounds` rounds have been
#' played.
#'
#' @param game An `rk_game` object, usually straight from [rk_game()].
#' @param policies Either a named character vector of strategy names (passed to
#'   [rk_ai()]) or a named list of policy functions, with one entry per player.
#' @param max_rounds Maximum number of rounds to play before stopping.
#' @param verbose A flag: report each completed round with [cli::cli_alert()]?
#'
#' @return An S3 object of class `rk_game_result`: a list with `winner` (a
#'   single string, `NA_character_` if the round cap was reached), `rounds`
#'   (integer, the number of rounds played), `decided` (a flag), `game` (the
#'   final `rk_game`), `standings` (a [tibble::tibble()] with one row per player
#'   per round and columns `round`, `player`, `territories`, `armies`,
#'   `continents`, `reinforcements` and `alive`; round `0` is the opening deal)
#'   and `policies` (a named character vector of strategy names).
#' @export
#' @family ai
#'
#' @examples
#' game <- rk_game(c("Red", "Blue"), seed = 42)
#' result <- rk_play(
#'   game,
#'   policies = c(Red = "aggressive", Blue = "cautious"),
#'   max_rounds = 5
#' )
#' result
#' head(result$standings)
rk_play <- function(game, policies, max_rounds = 100L, verbose = FALSE) {
  .rk_check_game(game)
  max_rounds <- .rk_check_count(max_rounds, "max_rounds", 1L, 100000L)
  if (!rlang::is_bool(verbose)) {
    cli::cli_abort("{.arg verbose} must be {.code TRUE} or {.code FALSE}.")
  }
  parsed <- .rk_parse_policies(policies, game$players)

  standings <- list(.rk_standings(game, 0L))
  last_round <- game$round
  guard <- 0L
  max_actions <- 1000L * max_rounds

  while (!rk_is_winner(game) && game$round <= max_rounds) {
    guard <- guard + 1L
    if (guard > max_actions) {
      cli::cli_abort(c(
        "The game did not finish within {max_actions} actions.",
        "i" = "A policy may never be ending its turn."
      ))
    }
    game <- rk_step(game, parsed$policies[[game$turn]](game, game$turn))
    if (game$round != last_round) {
      standings[[length(standings) + 1L]] <- .rk_standings(game, last_round)
      if (verbose) {
        cli::cli_alert_info("Round {last_round} complete.")
      }
      last_round <- game$round
    }
    if (identical(game$phase, "over")) break
  }

  if (rk_is_winner(game)) {
    standings[[length(standings) + 1L]] <- .rk_standings(game, game$round)
  }

  structure(
    list(
      winner = rk_winner(game),
      rounds = min(as.integer(game$round), max_rounds),
      decided = rk_is_winner(game),
      game = game,
      standings = do.call(rbind, standings),
      policies = parsed$labels
    ),
    class = "rk_game_result"
  )
}

#' Run many games and compare strategies
#'
#' Repeatedly deals a fresh game and plays it out with [rk_play()], then
#' summarises how often each strategy won.
#'
#' @param policies A named character vector of strategy names, one per player,
#'   for example `c(Red = "aggressive", Blue = "cautious")`.
#' @param n_games Number of games to play.
#' @param map An `rk_map` object to play on. Defaults to [rk_world()].
#' @inheritParams rk_play
#' @param seed Optional whole number seed. Supplying it calls [set.seed()] and
#'   therefore resets the caller's random number stream.
#'
#' @return A [tibble::tibble()] with one row per player and columns `player`
#'   (character), `strategy` (character), `games` (integer), `wins` (integer),
#'   `win_rate` (double), `mean_territories` (double, territories held when the
#'   games ended) and `mean_rounds` (double, the average game length, repeated
#'   on every row).
#' @export
#' @family ai
#'
#' @examples
#' \donttest{
#' rk_tournament(
#'   c(Red = "aggressive", Blue = "cautious"),
#'   n_games = 2, max_rounds = 10, seed = 1
#' )
#' }
rk_tournament <- function(policies, n_games = 20L, map = rk_world(),
                          max_rounds = 100L, seed = NULL, verbose = FALSE) {
  n_games <- .rk_check_count(n_games, "n_games", 1L, 100000L)
  .rk_check_map(map, "map")
  if (!is.character(policies) || is.null(names(policies))) {
    cli::cli_abort(
      "{.arg policies} must be a named character vector of strategy names."
    )
  }
  if (!is.null(seed)) {
    seed <- .rk_check_count(seed, "seed", -.Machine$integer.max,
                            .Machine$integer.max)
    set.seed(seed)
  }
  players <- names(policies)

  wins <- integer(length(players))
  names(wins) <- players
  territories <- numeric(length(players))
  names(territories) <- players
  rounds <- integer(n_games)

  for (i in seq_len(n_games)) {
    game <- rk_game(players, map = map)
    result <- rk_play(game, policies, max_rounds = max_rounds)
    rounds[[i]] <- result$rounds
    final <- result$standings[result$standings$round == result$rounds, ]
    territories <- territories + final$territories[match(players, final$player)]
    if (!is.na(result$winner)) {
      wins[[result$winner]] <- wins[[result$winner]] + 1L
    }
    if (verbose) {
      cli::cli_alert_info("Game {i} of {n_games}: winner {result$winner}.")
    }
  }

  tibble::tibble(
    player = players,
    strategy = unname(policies),
    games = n_games,
    wins = unname(wins),
    win_rate = unname(wins) / n_games,
    mean_territories = unname(territories) / n_games,
    mean_rounds = mean(rounds)
  )
}

#' @export
format.rk_game_result <- function(x, ...) {
  rlang::check_dots_empty()
  outcome <- if (x$decided) {
    cli::format_inline("Winner: {x$winner} after {x$rounds} round{?s}")
  } else {
    cli::format_inline("Undecided after {x$rounds} round{?s}")
  }
  c(
    cli::format_inline("<rk_game_result> {length(x$policies)} players"),
    outcome,
    cli::format_inline(
      "Policies: {paste0(names(x$policies), ' (', x$policies, ')')}"
    )
  )
}

#' @export
print.rk_game_result <- function(x, ...) {
  rlang::check_dots_empty()
  cli::cat_line(format(x))
  invisible(x)
}

# --- policies ---------------------------------------------------------------

.rk_policy_random <- function(game, player) {
  if (identical(game$phase, "reinforce")) {
    own <- rk_territories(game, player)
    n <- .rk_reinforcements(game, player)
    spread <- tabulate(
      sample.int(length(own), n, replace = TRUE),
      nbins = length(own)
    )
    return(.rk_action_reinforce(own, spread))
  }
  legal <- .rk_legal_attacks(game, player)
  if (identical(game$phase, "attack") && nrow(legal) > 0L &&
      sample.int(4L, 1L) > 1L) {
    i <- sample.int(nrow(legal), 1L)
    return(list(action = "attack", from = legal$from[[i]], to = legal$to[[i]]))
  }
  list(action = "end_turn")
}

.rk_policy_aggressive <- function(game, player) {
  if (identical(game$phase, "reinforce")) {
    own <- rk_territories(game, player)
    frontier <- .rk_frontier(game, player)
    pool <- if (length(frontier) > 0L) frontier else own
    armies <- game$state$armies[.rk_index(game, pool)]
    target <- pool[[which.max(armies)]]
    return(.rk_action_reinforce(target, .rk_reinforcements(game, player)))
  }
  legal <- .rk_legal_attacks(game, player)
  if (identical(game$phase, "attack") && nrow(legal) > 0L) {
    good <- legal[legal$att_armies > legal$def_armies, ]
    if (nrow(good) > 0L) {
      i <- order(good$def_armies, -good$att_armies)[[1L]]
      return(list(action = "attack", from = good$from[[i]], to = good$to[[i]]))
    }
  }
  list(action = "end_turn")
}

.rk_policy_cautious <- function(game, player, ratio) {
  if (identical(game$phase, "reinforce")) {
    frontier <- .rk_frontier(game, player)
    pool <- if (length(frontier) > 0L) frontier else rk_territories(game, player)
    armies <- game$state$armies[.rk_index(game, pool)]
    target <- pool[[which.min(armies)]]
    return(.rk_action_reinforce(target, .rk_reinforcements(game, player)))
  }
  legal <- .rk_legal_attacks(game, player)
  if (identical(game$phase, "attack") && nrow(legal) > 0L) {
    good <- legal[legal$att_armies >= ratio * legal$def_armies, ]
    if (nrow(good) > 0L) {
      i <- which.max(good$att_armies / good$def_armies)
      return(list(action = "attack", from = good$from[[i]], to = good$to[[i]]))
    }
  }
  move <- .rk_interior_move(game, player)
  if (!isTRUE(game$fortified) && nrow(move) > 0L) {
    return(list(
      action = "fortify",
      from = move$from[[1L]], to = move$to[[1L]], armies = move$armies[[1L]]
    ))
  }
  list(action = "end_turn")
}

# --- policy helpers ---------------------------------------------------------

.rk_action_reinforce <- function(territories, armies) {
  placements <- as.integer(armies)
  names(placements) <- territories
  list(action = "reinforce", placements = placements)
}

# Owned territories that touch an enemy.
.rk_frontier <- function(game, player) {
  own <- rk_territories(game, player)
  keep <- vapply(
    own,
    function(t) {
      nb <- game$map$adjacency[[t]]
      any(game$state$owner[.rk_index(game, nb)] != player)
    },
    logical(1L)
  )
  own[keep]
}

# The most useful interior-to-frontier fortification, if there is one.
.rk_interior_move <- function(game, player) {
  own <- rk_territories(game, player)
  frontier <- .rk_frontier(game, player)
  interior <- setdiff(own, frontier)
  armies <- game$state$armies[.rk_index(game, interior)]
  interior <- interior[armies > 1L]
  if (length(interior) == 0L || length(frontier) == 0L) {
    return(tibble::tibble(
      from = character(0), to = character(0), armies = integer(0)
    ))
  }
  spare <- game$state$armies[.rk_index(game, interior)] - 1L
  from <- interior[[which.max(spare)]]
  reachable <- intersect(.rk_reachable(game, from, player), frontier)
  if (length(reachable) == 0L) {
    return(tibble::tibble(
      from = character(0), to = character(0), armies = integer(0)
    ))
  }
  weakest <- reachable[[which.min(game$state$armies[.rk_index(game, reachable)])]]
  tibble::tibble(
    from = from,
    to = weakest,
    armies = as.integer(max(spare))
  )
}

.rk_parse_policies <- function(policies, players, call = rlang::caller_env()) {
  if (is.character(policies)) {
    labels <- policies
    fns <- lapply(policies, function(s) {
      if (!s %in% c("random", "aggressive", "cautious")) {
        cli::cli_abort(
          c(
            "{.arg policies} must name built-in strategies.",
            "x" = "Unknown strategy {.val {s}}."
          ),
          call = call
        )
      }
      rk_ai(s)
    })
    names(fns) <- names(policies)
  } else if (is.list(policies) && all(vapply(policies, is.function, logical(1L)))) {
    fns <- policies
    labels <- rep("custom", length(policies))
    names(labels) <- names(policies)
  } else {
    cli::cli_abort(
      "{.arg policies} must be a named character vector or a named list of
       functions.",
      call = call
    )
  }
  if (!setequal(names(fns), players)) {
    cli::cli_abort(
      c(
        "{.arg policies} must have one entry per player.",
        "x" = "Players: {.val {players}}.",
        "i" = "Policies: {.val {names(fns)}}."
      ),
      call = call
    )
  }
  list(policies = fns, labels = labels[players])
}

.rk_standings <- function(game, round = game$round) {
  out <- summary(game)
  out$round <- as.integer(round)
  out[, c("round", "player", "territories", "armies", "continents",
          "reinforcements", "alive")]
}
