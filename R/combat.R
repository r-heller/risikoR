#' Resolve a single Risk dice duel
#'
#' Resolves one throw of the dice in a Risk battle. The attacker rolls
#' `n_att` dice and the defender `n_def` dice; the highest attacker die is
#' compared with the highest defender die, then (if both rolled at least two
#' dice) the second-highest pair. The attacker removes a defending army when
#' strictly higher; ties and lower rolls remove an attacking army.
#'
#' @param n_att Number of attacker dice (1-3).
#' @param n_def Number of defender dice (1-2; up to 3 in older variants).
#' @param max_def Maximum defender dice permitted by the ruleset. Defaults to
#'   `2L`; set to `3L` for the older variant.
#'
#' @return A list with four elements: `att_loss` and `def_loss` (integers
#'   summing to `min(n_att, n_def)`, the number of compared dice pairs), and
#'   `att_roll` and `def_roll`, the integer dice rolls sorted in decreasing
#'   order.
#' @export
#' @family combat
#' @seealso [rk_duel_odds()] for the exact outcome probabilities.
#'
#' @examples
#' set.seed(1)
#' rk_duel(3, 2)
rk_duel <- function(n_att, n_def, max_def = 2L) {
  max_def <- .rk_check_count(max_def, "max_def", 1L, 3L)
  n_att <- .rk_check_count(n_att, "n_att", 1L, 3L)
  n_def <- .rk_check_count(n_def, "n_def", 1L, max_def)

  att <- sort(.rk_roll(n_att), decreasing = TRUE)
  def <- sort(.rk_roll(n_def), decreasing = TRUE)
  pairs <- min(n_att, n_def)

  att_loss <- 0L
  def_loss <- 0L
  for (i in seq_len(pairs)) {
    if (att[i] > def[i]) {
      def_loss <- def_loss + 1L
    } else {
      att_loss <- att_loss + 1L
    }
  }
  list(att_loss = att_loss, def_loss = def_loss, att_roll = att, def_roll = def)
}

#' Exact loss distribution for a single dice duel
#'
#' Enumerates every equally likely combination of attacker and defender dice
#' and returns the exact probability of each possible outcome of one duel. No
#' simulation is involved.
#'
#' @inheritParams rk_duel
#'
#' @return A [tibble::tibble()] with one row per possible outcome, ordered by
#'   `att_loss`, and columns:
#'   \describe{
#'     \item{`n_att`}{integer, attacker dice.}
#'     \item{`n_def`}{integer, defender dice.}
#'     \item{`att_loss`}{integer, armies lost by the attacker, from `0` to
#'       `min(n_att, n_def)`.}
#'     \item{`def_loss`}{integer, armies lost by the defender; always
#'       `min(n_att, n_def) - att_loss`.}
#'     \item{`p`}{double, probability of the outcome. The column sums to 1.}
#'   }
#' @export
#' @family combat
#'
#' @examples
#' # The classic three-against-two distribution
#' rk_duel_dist(3, 2)
rk_duel_dist <- function(n_att, n_def, max_def = 2L) {
  max_def <- .rk_check_count(max_def, "max_def", 1L, 3L)
  n_att <- .rk_check_count(n_att, "n_att", 1L, 3L)
  n_def <- .rk_check_count(n_def, "n_def", 1L, max_def)

  pairs <- min(n_att, n_def)
  probs <- .rk_loss_probs(n_att, n_def)
  att_loss <- seq.int(0L, pairs)

  tibble::tibble(
    n_att = n_att,
    n_def = n_def,
    att_loss = att_loss,
    def_loss = pairs - att_loss,
    p = probs
  )
}

#' Expected losses and win probability for a single dice duel
#'
#' Summarises the exact outcome distribution of one Risk dice duel (see
#' [rk_duel_dist()]) as expected losses and the probabilities of the three
#' qualitative outcomes. No simulation is used.
#'
#' @inheritParams rk_duel
#'
#' @return A one-row [tibble::tibble()] with columns:
#'   \describe{
#'     \item{`n_att`}{integer, attacker dice.}
#'     \item{`n_def`}{integer, defender dice.}
#'     \item{`e_att_loss`}{double, expected armies lost by the attacker.}
#'     \item{`e_def_loss`}{double, expected armies lost by the defender, equal
#'       to `min(n_att, n_def) - e_att_loss`.}
#'     \item{`sd_loss`}{double, standard deviation of the attacker's loss.}
#'     \item{`p_att_wins_all`}{double, probability that the attacker wins every
#'       compared pair, i.e. `att_loss == 0`.}
#'     \item{`p_def_wins_all`}{double, probability that the defender wins every
#'       compared pair, i.e. `att_loss == min(n_att, n_def)`.}
#'     \item{`p_split`}{double, probability that both sides lose exactly one
#'       army. A split needs two compared pairs, so it is `0` whenever only one
#'       pair is compared -- in that case `p_att_wins_all + p_def_wins_all`
#'       equals 1.}
#'   }
#' @export
#' @family combat
#' @seealso [rk_duel_dist()] for the full outcome distribution.
#'
#' @examples
#' rk_duel_odds(3, 2)
#'
#' # One die each: a split is impossible
#' rk_duel_odds(1, 1)
rk_duel_odds <- function(n_att, n_def, max_def = 2L) {
  dist <- rk_duel_dist(n_att, n_def, max_def = max_def)
  pairs <- max(dist$att_loss)

  e_att <- sum(dist$att_loss * dist$p)
  var_att <- sum((dist$att_loss - e_att)^2 * dist$p)

  tibble::tibble(
    n_att = dist$n_att[[1L]],
    n_def = dist$n_def[[1L]],
    e_att_loss = e_att,
    e_def_loss = pairs - e_att,
    sd_loss = sqrt(var_att),
    p_att_wins_all = dist$p[dist$att_loss == 0L],
    p_def_wins_all = dist$p[dist$att_loss == pairs],
    p_split = if (pairs == 2L) dist$p[dist$att_loss == 1L] else 0
  )
}

# --- internal helpers -------------------------------------------------------

.rk_roll <- function(n) sample.int(6L, n, replace = TRUE)

# All 6^n dice combinations, each row sorted in decreasing order.
.rk_sorted_faces <- function(n) {
  grid <- as.matrix(expand.grid(rep(list(seq_len(6L)), n)))
  if (n == 1L) {
    return(matrix(as.integer(grid), ncol = 1L))
  }
  out <- t(apply(grid, 1L, sort, decreasing = TRUE))
  matrix(as.integer(out), ncol = n)
}

# Probability vector over attacker losses 0..min(n_att, n_def). Memoised: the
# exact battle engine asks for the same handful of dice pairings over and over.
.rk_loss_cache <- new.env(parent = emptyenv())

.rk_loss_probs <- function(n_att, n_def) {
  key <- paste0(n_att, "v", n_def)
  cached <- .rk_loss_cache[[key]]
  if (!is.null(cached)) {
    return(cached)
  }
  pairs <- min(n_att, n_def)
  att <- .rk_sorted_faces(n_att)
  def <- .rk_sorted_faces(n_def)
  idx <- expand.grid(i = seq_len(nrow(att)), j = seq_len(nrow(def)))
  losses <- integer(nrow(idx))
  for (k in seq_len(pairs)) {
    losses <- losses + as.integer(att[idx$i, k] <= def[idx$j, k])
  }
  out <- tabulate(losses + 1L, nbins = pairs + 1L) / nrow(idx)
  .rk_loss_cache[[key]] <- out
  out
}
