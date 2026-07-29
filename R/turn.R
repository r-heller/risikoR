#' Place reinforcement armies
#'
#' Places the player's reinforcement armies on territories they own and moves
#' the game into the attack phase. The number of armies to place is given by
#' [rk_reinforcements()] and the placements must account for all of them.
#'
#' @param game An `rk_game` object.
#' @param player The player to move; must be the player whose turn it is.
#' @param placements A named numeric vector of armies to place, with territory
#'   names for names. Every named territory must be owned by `player` and the
#'   values must sum to `rk_reinforcements(game, player)`.
#'
#' @return A new `rk_game` object in the `"attack"` phase. The input `game` is
#'   left unchanged.
#' @export
#' @family turn
#'
#' @examples
#' game <- rk_game(c("Red", "Blue"), seed = 1)
#' placements <- rk_reinforcements(game, "Red")
#' names(placements) <- rk_territories(game, "Red")[[1L]]
#' game <- rk_reinforce(game, "Red", placements)
#' game$phase
rk_reinforce <- function(game, player, placements) {
  .rk_check_game(game)
  .rk_check_phase(game, "reinforce")
  player <- .rk_check_player(game, player)
  if (!identical(player, game$turn)) {
    cli::cli_abort(c(
      "It is not {.val {player}}'s turn.",
      "i" = "{.val {game$turn}} is to move."
    ))
  }

  if (!is.numeric(placements) || length(placements) == 0L ||
      is.null(names(placements)) || anyNA(placements)) {
    cli::cli_abort(
      "{.arg placements} must be a named numeric vector of armies."
    )
  }
  if (any(placements < 0) || any(placements != as.integer(placements))) {
    cli::cli_abort("{.arg placements} must be non-negative whole numbers.")
  }
  if (anyDuplicated(names(placements)) > 0L) {
    cli::cli_abort("{.arg placements} must name each territory at most once.")
  }
  .rk_check_territory(game$map, names(placements), "placements")
  owned <- rk_territories(game, player)
  foreign <- setdiff(names(placements), owned)
  if (length(foreign) > 0L) {
    cli::cli_abort(c(
      "{.arg placements} must only name territories held by {.val {player}}.",
      "x" = "Not held: {.val {foreign}}."
    ))
  }
  need <- .rk_reinforcements(game, player)
  got <- sum(as.integer(placements))
  if (got != need) {
    cli::cli_abort(c(
      "{.arg placements} must account for every reinforcement army.",
      "x" = "Placed {got}, but {.val {player}} receives {need}."
    ))
  }

  idx <- .rk_index(game, names(placements))
  game$state$armies[idx] <- game$state$armies[idx] + as.integer(placements)
  game <- .rk_log(game, "reinforce", armies = need, conquered = FALSE)
  game$phase <- "attack"
  game
}

#' Attack a neighbouring territory
#'
#' Resolves a full battle with [rk_battle()] between two adjacent territories.
#' If the defender is wiped out the territory changes hands and armies move in
#' from the attacking territory.
#'
#' @inheritParams rk_reinforce
#' @param from The attacking territory; must be held by the player to move and
#'   carry at least two armies.
#' @param to The defending territory; must be adjacent to `from` and held by
#'   another player.
#' @param max_def Maximum defender dice permitted (default `2L`).
#' @param move Number of armies to move into a conquered territory. Must leave
#'   at least one army behind. Defaults to all but one of the surviving
#'   attackers.
#'
#' @return A new `rk_game` object with the battle stored in `last_battle`. The
#'   input `game` is left unchanged. Conquering the last territory of an
#'   opponent eliminates them; taking the last territory of the last opponent
#'   moves the game into the `"over"` phase.
#' @export
#' @family turn
#'
#' @examples
#' game <- rk_game(c("Red", "Blue"), seed = 1)
#' placements <- rk_reinforcements(game, "Red")
#' names(placements) <- rk_territories(game, "Red")[[1L]]
#' game <- rk_reinforce(game, "Red", placements)
#'
#' targets <- rk_legal_attacks(game, "Red")
#' set.seed(1)
#' game <- rk_attack(game, targets$from[[1L]], targets$to[[1L]])
#' game$last_battle
rk_attack <- function(game, from, to, max_def = 2L, move = NULL) {
  .rk_check_game(game)
  .rk_check_phase(game, "attack")
  from <- .rk_check_territory(game$map, .rk_check_string(from, "from"), "from")
  to <- .rk_check_territory(game$map, .rk_check_string(to, "to"), "to")
  player <- game$turn

  if (!identical(rk_owner(game, from), player)) {
    cli::cli_abort(c(
      "{.arg from} must be held by the player to move.",
      "x" = "{.val {from}} belongs to {.val {rk_owner(game, from)}}."
    ))
  }
  if (identical(rk_owner(game, to), player)) {
    cli::cli_abort(c(
      "{.arg to} must be held by an opponent.",
      "x" = "{.val {to}} is already yours."
    ))
  }
  if (!to %in% game$map$adjacency[[from]]) {
    cli::cli_abort(c(
      "{.arg to} must neighbour {.arg from}.",
      "x" = "{.val {to}} does not border {.val {from}}."
    ))
  }
  att_armies <- rk_armies(game, from)
  if (att_armies < 2L) {
    cli::cli_abort(c(
      "{.arg from} must hold at least two armies to attack.",
      "x" = "{.val {from}} holds {att_armies}."
    ))
  }

  def_armies <- rk_armies(game, to)
  defender <- rk_owner(game, to)
  battle <- rk_battle(att_armies, def_armies, max_def = max_def)

  i_from <- .rk_index(game, from)
  i_to <- .rk_index(game, to)
  game$state$armies[i_from] <- battle$att_remaining
  game$state$armies[i_to] <- battle$def_remaining
  moved <- 0L

  if (battle$conquered) {
    moved <- if (is.null(move)) {
      battle$att_remaining - 1L
    } else {
      .rk_check_count(move, "move", 1L, battle$att_remaining - 1L)
    }
    game$state$owner[i_to] <- player
    game$state$armies[i_from] <- battle$att_remaining - moved
    game$state$armies[i_to] <- moved
  }

  game$last_battle <- battle
  game <- .rk_log(
    game, "attack",
    from = from, to = to, armies = moved, conquered = battle$conquered
  )
  if (battle$conquered) {
    game <- .rk_update_active(game, defender)
  }
  game
}

#' Move armies between two connected territories
#'
#' Performs the single fortification move allowed at the end of a turn. Both
#' territories must be held by the player to move and joined by a path running
#' entirely through their own territories.
#'
#' @inheritParams rk_reinforce
#' @param from The territory to move armies out of; at least one army must stay
#'   behind.
#' @param to The territory to move armies into.
#' @param armies Number of armies to move (at least one).
#'
#' @return A new `rk_game` object in the `"fortify"` phase. The input `game` is
#'   left unchanged.
#' @export
#' @family turn
#'
#' @examples
#' game <- rk_game(c("Red", "Blue"), seed = 1)
#' from <- rk_territories(game, "Red")[[1L]]
#' placements <- rk_reinforcements(game, "Red")
#' names(placements) <- from
#' game <- rk_reinforce(game, "Red", placements)
#'
#' to <- intersect(rk_neighbors(game, from), rk_territories(game, "Red"))[[1L]]
#' game <- rk_fortify(game, from, to, 3)
#' rk_armies(game, c(from, to))
rk_fortify <- function(game, from, to, armies) {
  .rk_check_game(game)
  .rk_check_phase(game, c("attack", "fortify"))
  if (isTRUE(game$fortified)) {
    cli::cli_abort(c(
      "Only one fortification is allowed per turn.",
      "i" = "End the turn with {.fun rk_end_turn}."
    ))
  }
  from <- .rk_check_territory(game$map, .rk_check_string(from, "from"), "from")
  to <- .rk_check_territory(game$map, .rk_check_string(to, "to"), "to")
  player <- game$turn

  if (identical(from, to)) {
    cli::cli_abort("{.arg from} and {.arg to} must be different territories.")
  }
  not_own <- c(from, to)[rk_owner(game, c(from, to)) != player]
  if (length(not_own) > 0L) {
    cli::cli_abort(c(
      "Both territories must be held by the player to move.",
      "x" = "Not held by {.val {player}}: {.val {not_own}}."
    ))
  }
  if (!.rk_connected(game, from, to, player)) {
    cli::cli_abort(c(
      "{.arg from} and {.arg to} must be connected by your own territories.",
      "x" = "No owned path runs from {.val {from}} to {.val {to}}."
    ))
  }
  available <- rk_armies(game, from) - 1L
  if (available < 1L) {
    cli::cli_abort(c(
      "{.arg from} has no armies to spare.",
      "x" = "{.val {from}} holds {rk_armies(game, from)}; one must stay."
    ))
  }
  armies <- .rk_check_count(armies, "armies", 1L, available)

  game$state$armies[.rk_index(game, from)] <-
    game$state$armies[.rk_index(game, from)] - armies
  game$state$armies[.rk_index(game, to)] <-
    game$state$armies[.rk_index(game, to)] + armies

  game <- .rk_log(
    game, "fortify", from = from, to = to, armies = armies, conquered = FALSE
  )
  game$fortified <- TRUE
  game$phase <- "fortify"
  game
}

#' End the current turn
#'
#' Hands play to the next surviving player, resets the phase to `"reinforce"`
#' and advances the round counter when play wraps back to the first player.
#'
#' @inheritParams rk_reinforce
#'
#' @return A new `rk_game` object. The input `game` is left unchanged.
#' @export
#' @family turn
#'
#' @examples
#' game <- rk_game(c("Red", "Blue"), seed = 1)
#' placements <- rk_reinforcements(game, "Red")
#' names(placements) <- rk_territories(game, "Red")[[1L]]
#' game <- rk_reinforce(game, "Red", placements)
#' rk_end_turn(game)$turn
rk_end_turn <- function(game) {
  .rk_check_game(game)
  .rk_check_phase(game, c("attack", "fortify"))
  game <- .rk_log(game, "end_turn", conquered = FALSE)
  .rk_advance_turn(game)
}

#' Advance the game by one action
#'
#' Applies a single action to the game state. This is the atomic step used by
#' [rk_play()], the AI agents and the Shiny app. When `action` is not supplied
#' the action is chosen by `policy`.
#'
#' @inheritParams rk_reinforce
#' @param action A named list describing the action, or `NULL` to let `policy`
#'   choose. The `action` element must be one of `"reinforce"` (with
#'   `placements`), `"attack"` (with `from`, `to` and optionally `move`),
#'   `"fortify"` (with `from`, `to`, `armies`) or `"end_turn"`.
#' @param policy A function of `(game, player)` returning such a list; see
#'   [rk_ai()]. Only used when `action` is `NULL`.
#'
#' @return A new `rk_game` object. The input `game` is left unchanged.
#' @export
#' @family turn
#'
#' @examples
#' game <- rk_game(c("Red", "Blue"), seed = 1)
#' set.seed(1)
#' rk_step(game, policy = rk_ai("random"))$phase
rk_step <- function(game, action = NULL, policy = rk_ai("random")) {
  .rk_check_game(game)
  if (identical(game$phase, "over")) {
    cli::cli_abort(c(
      "The game is over.",
      "i" = "{.val {rk_winner(game)}} has already won."
    ))
  }
  if (is.null(action)) {
    if (!is.function(policy)) {
      cli::cli_abort("{.arg policy} must be a function of {.code (game, player)}.")
    }
    action <- policy(game, game$turn)
  }
  action <- .rk_check_action(action)

  switch(
    action$action,
    reinforce = rk_reinforce(game, game$turn, action$placements),
    attack = rk_attack(
      game, action$from, action$to,
      max_def = action$max_def %||% 2L, move = action$move
    ),
    fortify = rk_fortify(game, action$from, action$to, action$armies),
    end_turn = rk_end_turn(game)
  )
}

#' Attacks available to a player
#'
#' Enumerates every legal attack: an owned territory with at least two armies
#' next to a territory held by somebody else.
#'
#' @inheritParams rk_reinforce
#' @param player The attacking player. Defaults to the player to move.
#'
#' @return A [tibble::tibble()] with one row per legal attack and columns
#'   `from` (character), `to` (character), `defender` (character),
#'   `att_armies` (integer) and `def_armies` (integer). Zero rows when no
#'   attack is available.
#' @export
#' @family turn
#'
#' @examples
#' game <- rk_game(c("Red", "Blue"), seed = 1)
#' rk_legal_attacks(game, "Red")
rk_legal_attacks <- function(game, player = game$turn) {
  .rk_check_game(game)
  player <- .rk_check_player(game, player)
  .rk_legal_attacks(game, player)
}

# --- internal helpers -------------------------------------------------------

.rk_check_action <- function(action, call = rlang::caller_env()) {
  valid <- c("reinforce", "attack", "fortify", "end_turn")
  if (!is.list(action) || is.null(action$action)) {
    cli::cli_abort(
      "{.arg action} must be a list with an {.field action} element.",
      call = call
    )
  }
  kind <- .rk_check_string(action$action, "action$action", call = call)
  if (!kind %in% valid) {
    cli::cli_abort(
      c(
        "{.field action} must be one of {.val {valid}}.",
        "x" = "Got {.val {kind}}."
      ),
      call = call
    )
  }
  action$action <- kind
  action
}

.rk_legal_attacks <- function(game, player) {
  owned <- game$state$territory[game$state$owner == player]
  strong <- owned[game$state$armies[.rk_index(game, owned)] > 1L]
  from <- character(0)
  to <- character(0)
  for (t in strong) {
    nb <- game$map$adjacency[[t]]
    enemy <- nb[game$state$owner[.rk_index(game, nb)] != player]
    if (length(enemy) > 0L) {
      from <- c(from, rep(t, length(enemy)))
      to <- c(to, enemy)
    }
  }
  tibble::tibble(
    from = from,
    to = to,
    defender = game$state$owner[.rk_index(game, to)],
    att_armies = game$state$armies[.rk_index(game, from)],
    def_armies = game$state$armies[.rk_index(game, to)]
  )
}

# Territories reachable from `from` through territories owned by `player`.
.rk_reachable <- function(game, from, player) {
  owned <- game$state$territory[game$state$owner == player]
  seen <- from
  queue <- from
  while (length(queue) > 0L) {
    current <- queue[[1L]]
    queue <- queue[-1L]
    nb <- intersect(game$map$adjacency[[current]], owned)
    fresh <- setdiff(nb, seen)
    seen <- c(seen, fresh)
    queue <- c(queue, fresh)
  }
  seen
}

.rk_connected <- function(game, from, to, player) {
  to %in% .rk_reachable(game, from, player)
}

# Drop `defender` from the active roster if they hold nothing, and end the
# game when a single player is left standing.
.rk_update_active <- function(game, defender) {
  if (!any(game$state$owner == defender)) {
    game$active <- setdiff(game$active, defender)
  }
  if (length(game$active) == 1L) {
    game$phase <- "over"
  }
  game
}

.rk_advance_turn <- function(game) {
  order_players <- game$players[game$players %in% game$active]
  idx <- match(game$turn, order_players)
  if (is.na(idx)) {
    idx <- length(order_players)
  }
  nxt <- idx %% length(order_players) + 1L
  if (nxt <= idx) {
    game$round <- game$round + 1L
  }
  game$turn <- order_players[[nxt]]
  game$phase <- "reinforce"
  game$fortified <- FALSE
  game
}
