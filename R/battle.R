#' Simulate a full battle between two territories
#'
#' Repeatedly resolves dice duels via [rk_duel()] until either the attacker can
#' no longer attack (fewer than two armies remain on the attacking territory)
#' or the defender is wiped out. At each step the attacker and defender roll the
#' maximum number of dice permitted by their remaining armies and the ruleset.
#'
#' @param att_armies Number of armies on the attacking territory (must be
#'   `>= 2`, since one army must remain behind).
#' @param def_armies Number of armies on the defending territory (`>= 1`).
#' @param max_def Maximum defender dice permitted (default `2L`).
#'
#' @return An S3 object of class `rk_battle`: a list with `att_armies` and
#'   `def_armies` (the starting armies), `att_remaining` and `def_remaining`
#'   (integers), `conquered` (a flag, `TRUE` when the defender was wiped out),
#'   `rounds` (integer number of duels fought) and `log`, a
#'   [tibble::tibble()] with one row per duel and columns `round`, `att_loss`
#'   and `def_loss` (all integer).
#' @export
#' @family combat
#' @seealso [rk_battle_odds()] for win probabilities without simulating.
#'
#' @examples
#' set.seed(42)
#' rk_battle(10, 8)
rk_battle <- function(att_armies, def_armies, max_def = 2L) {
  max_def <- .rk_check_count(max_def, "max_def", 1L, 3L)
  att_armies <- .rk_check_count(att_armies, "att_armies", 2L, .Machine$integer.max)
  def_armies <- .rk_check_count(def_armies, "def_armies", 1L, .Machine$integer.max)

  att <- att_armies
  def <- def_armies
  al <- integer(0)
  dl <- integer(0)

  while (att > 1L && def > 0L) {
    n_att <- min(3L, att - 1L)
    n_def <- min(max_def, def)
    res <- rk_duel(n_att, n_def, max_def = max_def)
    att <- att - res$att_loss
    def <- def - res$def_loss
    al <- c(al, res$att_loss)
    dl <- c(dl, res$def_loss)
  }

  .rk_new_battle(att_armies, def_armies, att, def, al, dl)
}

#' Win probability and expected survivors for a battle
#'
#' Computes the probability that the attacker conquers the territory, together
#' with the expected surviving armies on both sides. The default `"mc"` method
#' simulates `n` independent battles; `"exact"` solves the absorbing Markov
#' chain over army states and involves no simulation.
#'
#' @inheritParams rk_battle
#' @param n Number of simulated battles. Ignored when `method = "exact"`.
#' @param method Either `"mc"` (Monte Carlo, the default) or `"exact"`.
#'
#' @return A one-row [tibble::tibble()] with columns:
#'   \describe{
#'     \item{`att_armies`, `def_armies`}{integer, the starting armies.}
#'     \item{`method`}{character, `"mc"` or `"exact"`.}
#'     \item{`n`}{integer, the number of simulated battles; `NA_integer_` for
#'       the exact method.}
#'     \item{`p_conquer`}{double, probability that the attacker takes the
#'       territory.}
#'     \item{`e_att_survivors`, `e_def_survivors`}{double, expected armies left
#'       on the attacking and defending territory when the battle ends.}
#'   }
#' @export
#' @family combat
#'
#' @examples
#' # Exact, no simulation
#' rk_battle_odds(10, 8, method = "exact")
#'
#' set.seed(1)
#' rk_battle_odds(10, 8, n = 500)
rk_battle_odds <- function(att_armies, def_armies, n = 10000L, max_def = 2L,
                           method = c("mc", "exact")) {
  method <- match.arg(method)
  max_def <- .rk_check_count(max_def, "max_def", 1L, 3L)
  att_armies <- .rk_check_count(att_armies, "att_armies", 2L, .Machine$integer.max)
  def_armies <- .rk_check_count(def_armies, "def_armies", 1L, .Machine$integer.max)

  if (method == "exact") {
    res <- .rk_battle_exact(att_armies, def_armies, max_def)
    n_used <- NA_integer_
  } else {
    n <- .rk_check_count(n, "n", 1L, .Machine$integer.max)
    res <- .rk_battle_mc(att_armies, def_armies, max_def, n)
    n_used <- n
  }

  tibble::tibble(
    att_armies = att_armies,
    def_armies = def_armies,
    method = method,
    n = n_used,
    p_conquer = res$p_conquer,
    e_att_survivors = res$e_att,
    e_def_survivors = res$e_def
  )
}

#' Conquest probability over a grid of army counts
#'
#' Evaluates [rk_battle_odds()] over every combination of attacker and defender
#' armies in `att_range` and `def_range`. This is the reference table behind
#' [rk_plot_odds_heatmap()].
#'
#' @param att_range Integer vector of attacker army counts (each `>= 2`).
#' @param def_range Integer vector of defender army counts (each `>= 1`).
#' @inheritParams rk_battle_odds
#'
#' @return A [tibble::tibble()] with one row per combination and columns
#'   `att_armies` (integer), `def_armies` (integer), `method` (character),
#'   `p_conquer`, `e_att_survivors` and `e_def_survivors` (double). Rows are
#'   ordered by `att_armies`, then `def_armies`.
#' @export
#' @family combat
#'
#' @examples
#' rk_odds_table(att_range = 2:6, def_range = 1:5)
rk_odds_table <- function(att_range = 2:15, def_range = 1:15,
                          method = c("exact", "mc"), n = 1000L, max_def = 2L) {
  method <- match.arg(method)
  if (!is.numeric(att_range) || length(att_range) == 0L || anyNA(att_range)) {
    cli::cli_abort("{.arg att_range} must be a non-empty numeric vector.")
  }
  if (!is.numeric(def_range) || length(def_range) == 0L || anyNA(def_range)) {
    cli::cli_abort("{.arg def_range} must be a non-empty numeric vector.")
  }

  grid <- expand.grid(def_armies = def_range, att_armies = att_range)
  rows <- lapply(seq_len(nrow(grid)), function(i) {
    rk_battle_odds(
      grid$att_armies[[i]], grid$def_armies[[i]],
      n = n, max_def = max_def, method = method
    )
  })
  out <- do.call(rbind, rows)
  out[, c("att_armies", "def_armies", "method", "p_conquer",
          "e_att_survivors", "e_def_survivors")]
}

#' @export
format.rk_battle <- function(x, ...) {
  rlang::check_dots_empty()
  outcome <- if (x$conquered) "conquered" else "repelled"
  c(
    cli::format_inline(
      "<rk_battle> territory {outcome} after {x$rounds} duel{?s}"
    ),
    cli::format_inline(
      "Attacker: {x$att_remaining} left \u00b7 Defender: {x$def_remaining} left"
    )
  )
}

#' @export
print.rk_battle <- function(x, ...) {
  rlang::check_dots_empty()
  cli::cat_line(format(x))
  invisible(x)
}

# --- internal helpers -------------------------------------------------------

.rk_new_battle <- function(att_armies, def_armies, att_remaining,
                           def_remaining, att_losses, def_losses) {
  structure(
    list(
      att_armies = as.integer(att_armies),
      def_armies = as.integer(def_armies),
      att_remaining = as.integer(att_remaining),
      def_remaining = as.integer(def_remaining),
      conquered = def_remaining == 0L,
      rounds = length(att_losses),
      log = tibble::tibble(
        round = seq_along(att_losses),
        att_loss = as.integer(att_losses),
        def_loss = as.integer(def_losses)
      )
    ),
    class = "rk_battle"
  )
}

# A battle that never happened; keeps `rk_game$last_battle` type stable.
.rk_empty_battle <- function() {
  out <- .rk_new_battle(0L, 0L, 0L, 0L, integer(0), integer(0))
  out$conquered <- FALSE
  out
}

.rk_battle_mc <- function(att_armies, def_armies, max_def, n) {
  wins <- 0L
  att_surv <- 0
  def_surv <- 0
  for (i in seq_len(n)) {
    b <- rk_battle(att_armies, def_armies, max_def = max_def)
    if (b$conquered) wins <- wins + 1L
    att_surv <- att_surv + b$att_remaining
    def_surv <- def_surv + b$def_remaining
  }
  list(
    p_conquer = wins / n,
    e_att = att_surv / n,
    e_def = def_surv / n
  )
}

# Absorbing Markov chain over (attacker armies, defender armies). Each duel
# removes exactly `pairs` armies, so sweeping states in decreasing order of
# attacker armies and then defender armies visits every state before its
# successors.
.rk_battle_exact <- function(att_armies, def_armies, max_def) {
  mass <- matrix(0, nrow = att_armies + 1L, ncol = def_armies + 1L)
  mass[att_armies + 1L, def_armies + 1L] <- 1

  p_conquer <- 0
  e_att <- 0
  e_def <- 0

  for (a in seq.int(att_armies, 1L)) {
    for (d in seq.int(def_armies, 0L)) {
      here <- mass[a + 1L, d + 1L]
      if (here == 0) next
      if (d == 0L || a <= 1L) {
        if (d == 0L) p_conquer <- p_conquer + here
        e_att <- e_att + a * here
        e_def <- e_def + d * here
        next
      }
      n_att <- min(3L, a - 1L)
      n_def <- min(max_def, d)
      pairs <- min(n_att, n_def)
      probs <- .rk_loss_probs(n_att, n_def)
      for (k in seq.int(0L, pairs)) {
        if (probs[[k + 1L]] == 0) next
        row <- a - k + 1L
        col <- d - (pairs - k) + 1L
        mass[row, col] <- mass[row, col] + here * probs[[k + 1L]]
      }
    }
  }

  list(p_conquer = p_conquer, e_att = e_att, e_def = e_def)
}
