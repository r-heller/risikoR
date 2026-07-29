#' Plot the loss distribution of a single duel
#'
#' Draws the exact outcome distribution of one dice duel (see
#' [rk_duel_dist()]) as a bar chart, with the expected losses in the subtitle.
#'
#' @inheritParams rk_duel
#'
#' @return A `ggplot` object.
#' @export
#' @family plots
#'
#' @examples
#' rk_plot_duel(3, 2)
rk_plot_duel <- function(n_att, n_def, max_def = 2L) {
  dist <- rk_duel_dist(n_att, n_def, max_def = max_def)
  odds <- rk_duel_odds(n_att, n_def, max_def = max_def)
  dist$outcome <- paste0(
    "attacker -", dist$att_loss, " / defender -", dist$def_loss
  )

  ggplot2::ggplot(
    dist,
    ggplot2::aes(x = .data$outcome, y = .data$p, fill = .data$outcome)
  ) +
    ggplot2::geom_col(width = 0.6) +
    ggplot2::scale_fill_manual(values = .rk_palette(nrow(dist))) +
    ggplot2::scale_y_continuous(limits = c(0, 1)) +
    ggplot2::labs(
      x = NULL,
      y = "probability",
      title = sprintf(
        "Duel outcomes: %d attacker vs %d defender dice",
        odds$n_att, odds$n_def
      ),
      subtitle = sprintf(
        "Expected loss %.4f attacker, %.4f defender (sd %.4f)",
        odds$e_att_loss, odds$e_def_loss, odds$sd_loss
      )
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "none")
}

#' Plot conquest probability across defender strength
#'
#' Shows the conquest probability as the defender army count varies, holding
#' the attacker strength fixed.
#'
#' @param att_armies Fixed number of attacking armies.
#' @param def_range Integer vector of defender army counts to evaluate.
#' @param n Simulations per point when `method = "mc"`.
#' @param max_def Maximum defender dice (default `2L`).
#' @param method Either `"mc"` (Monte Carlo, the default) or `"exact"`; see
#'   [rk_battle_odds()].
#'
#' @return A `ggplot` object.
#' @export
#' @family plots
#'
#' @examples
#' rk_plot_conquest(20, def_range = seq(2, 20, by = 2), method = "exact")
rk_plot_conquest <- function(att_armies, def_range = seq_len(20),
                             n = 2000L, max_def = 2L,
                             method = c("mc", "exact")) {
  method <- match.arg(method)
  df <- rk_odds_table(
    att_range = att_armies, def_range = def_range,
    method = method, n = n, max_def = max_def
  )
  ggplot2::ggplot(
    df,
    ggplot2::aes(x = .data$def_armies, y = .data$p_conquer)
  ) +
    ggplot2::geom_line(colour = .rk_accent(), linewidth = 0.7) +
    ggplot2::geom_point(colour = .rk_accent(), size = 1.8) +
    ggplot2::scale_y_continuous(limits = c(0, 1)) +
    ggplot2::labs(
      x = "defender armies",
      y = "P(conquer)",
      title = sprintf("Conquest probability with %d attackers", df$att_armies[[1L]]),
      subtitle = if (method == "exact") {
        "Exact Markov-chain solution"
      } else {
        sprintf("Monte Carlo, %d battles per point", n)
      }
    ) +
    ggplot2::theme_minimal()
}

#' Plot the world map
#'
#' Draws the board: adjacency as segments, territories as points labelled with
#' their army count. An `rk_game` is coloured by owner, a bare `rk_map` by
#' continent.
#'
#' @param x An `rk_game` or an `rk_map`.
#' @param labels A flag: label territories with their names?
#' @param armies A flag: label territories with their army count? Only applies
#'   to an `rk_game`.
#'
#' @return A `ggplot` object.
#' @export
#' @family plots
#'
#' @examples
#' rk_plot_map(rk_world())
#'
#' game <- rk_game(c("Red", "Blue", "Green"), seed = 1)
#' rk_plot_map(game)
rk_plot_map <- function(x, labels = TRUE, armies = TRUE) {
  map <- .rk_as_map(x)
  if (!rlang::is_bool(labels)) {
    cli::cli_abort("{.arg labels} must be {.code TRUE} or {.code FALSE}.")
  }
  if (!rlang::is_bool(armies)) {
    cli::cli_abort("{.arg armies} must be {.code TRUE} or {.code FALSE}.")
  }

  edges <- .rk_edges(map)
  nodes <- map$layout
  is_game <- inherits(x, "rk_game")

  if (is_game) {
    nodes$key <- rk_owner(x, nodes$territory)
    nodes$armies <- rk_armies(x, nodes$territory)
    values <- .rk_palette(length(x$players))
    names(values) <- x$players
    legend <- "owner"
    title <- sprintf("Risk: round %d", x$round)
    subtitle <- if (identical(x$phase, "over")) {
      sprintf("%s has won", rk_winner(x))
    } else {
      sprintf("%s to move (%s phase)", x$turn, x$phase)
    }
  } else {
    nodes$key <- nodes$continent
    nodes$armies <- 0L
    values <- .rk_continent_colours()[names(map$continent)]
    if (anyNA(values)) {
      values <- .rk_palette(length(map$continent))
      names(values) <- names(map$continent)
    }
    legend <- "continent"
    title <- "Risk world map"
    subtitle <- sprintf(
      "%d territories, %d continents",
      length(map$territories), length(map$continent)
    )
  }

  p <- ggplot2::ggplot() +
    ggplot2::geom_segment(
      data = edges,
      ggplot2::aes(
        x = .data$x, y = .data$y, xend = .data$xend, yend = .data$yend
      ),
      colour = "grey85", linewidth = 0.3
    ) +
    ggplot2::geom_point(
      data = nodes,
      ggplot2::aes(x = .data$x, y = .data$y, fill = .data$key),
      shape = 21, size = 6, colour = "white", stroke = 0.7
    ) +
    ggplot2::scale_fill_manual(values = values, drop = FALSE)

  if (labels) {
    p <- p + ggplot2::geom_text(
      data = nodes,
      ggplot2::aes(x = .data$x, y = .data$y, label = .data$territory),
      vjust = -1.6, size = 2.1, colour = "grey30"
    )
  }
  if (armies && is_game) {
    p <- p + ggplot2::geom_text(
      data = nodes,
      ggplot2::aes(x = .data$x, y = .data$y, label = .data$armies),
      size = 2.4, colour = "white", fontface = "bold"
    )
  }

  p +
    ggplot2::coord_equal(clip = "off") +
    ggplot2::labs(x = NULL, y = NULL, fill = legend, title = title,
                  subtitle = subtitle) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.text = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    )
}

#' Heatmap of conquest probability
#'
#' Draws [rk_odds_table()] as a tile heatmap: attacker armies on one axis,
#' defender armies on the other, conquest probability as fill.
#'
#' @inheritParams rk_odds_table
#'
#' @return A `ggplot` object.
#' @export
#' @family plots
#'
#' @examples
#' rk_plot_odds_heatmap(att_range = 2:10, def_range = 1:10)
rk_plot_odds_heatmap <- function(att_range = 2:15, def_range = 1:15,
                                 method = c("exact", "mc"), n = 1000L,
                                 max_def = 2L) {
  method <- match.arg(method)
  odds <- rk_odds_table(
    att_range = att_range, def_range = def_range,
    method = method, n = n, max_def = max_def
  )
  ggplot2::ggplot(
    odds,
    ggplot2::aes(x = .data$def_armies, y = .data$att_armies,
                 fill = .data$p_conquer)
  ) +
    ggplot2::geom_tile(colour = "white", linewidth = 0.4) +
    ggplot2::scale_fill_gradient(
      low = "#F4F0F8", high = .rk_accent(), limits = c(0, 1)
    ) +
    ggplot2::labs(
      x = "defender armies",
      y = "attacker armies",
      fill = "P(conquer)",
      title = "Conquest probability",
      subtitle = if (method == "exact") {
        "Exact Markov-chain solution"
      } else {
        sprintf("Monte Carlo, %d battles per cell", n)
      }
    ) +
    ggplot2::theme_minimal()
}

#' Plot tournament win rates
#'
#' Draws the win rate of each player in a [rk_tournament()] result as a bar
#' chart, coloured by strategy.
#'
#' @param results A [tibble::tibble()] as returned by [rk_tournament()].
#'
#' @return A `ggplot` object.
#' @export
#' @family plots
#'
#' @examples
#' \donttest{
#' results <- rk_tournament(
#'   c(Red = "aggressive", Blue = "cautious"),
#'   n_games = 2, max_rounds = 10, seed = 1
#' )
#' rk_plot_tournament(results)
#' }
rk_plot_tournament <- function(results) {
  required <- c("player", "strategy", "win_rate")
  if (!is.data.frame(results) || !all(required %in% names(results))) {
    cli::cli_abort(c(
      "{.arg results} must be a {.fun rk_tournament} result.",
      "x" = "Missing column{?s}: {.field {setdiff(required, names(results))}}."
    ))
  }
  strategies <- unique(results$strategy)
  values <- .rk_palette(length(strategies))
  names(values) <- strategies

  ggplot2::ggplot(
    results,
    ggplot2::aes(x = .data$player, y = .data$win_rate, fill = .data$strategy)
  ) +
    ggplot2::geom_col(width = 0.6) +
    ggplot2::scale_fill_manual(values = values) +
    ggplot2::scale_y_continuous(limits = c(0, 1)) +
    ggplot2::labs(
      x = NULL,
      y = "win rate",
      fill = "strategy",
      title = "Tournament win rates",
      subtitle = sprintf("%d games per player", results$games[[1L]])
    ) +
    ggplot2::theme_minimal()
}

#' Plot a game or a battle
#'
#' [ggplot2::autoplot()] methods: an `rk_game` is drawn as the world map (see
#' [rk_plot_map()]), an `rk_battle` as the armies remaining after each duel.
#'
#' @param object An `rk_game` or an `rk_battle`.
#' @param ... Passed on to [rk_plot_map()] for `rk_game`; not used for
#'   `rk_battle`.
#'
#' @return A `ggplot` object.
#' @family plots
#' @name autoplot.rk_game
#'
#' @examples
#' game <- rk_game(c("Red", "Blue"), seed = 1)
#' ggplot2::autoplot(game)
#'
#' set.seed(1)
#' ggplot2::autoplot(rk_battle(12, 10))
NULL

#' @rdname autoplot.rk_game
#' @importFrom ggplot2 autoplot
#' @export
autoplot.rk_game <- function(object, ...) {
  rk_plot_map(object, ...)
}

#' @rdname autoplot.rk_game
#' @export
autoplot.rk_battle <- function(object, ...) {
  rlang::check_dots_empty()
  log <- object$log
  path <- tibble::tibble(
    round = rep(c(0L, log$round), 2L),
    side = rep(c("attacker", "defender"), each = nrow(log) + 1L),
    armies = c(
      object$att_armies - cumsum(c(0L, log$att_loss)),
      object$def_armies - cumsum(c(0L, log$def_loss))
    )
  )
  outcome <- if (object$conquered) "territory conquered" else "attack repelled"

  ggplot2::ggplot(
    path,
    ggplot2::aes(x = .data$round, y = .data$armies, colour = .data$side)
  ) +
    ggplot2::geom_step(direction = "vh", linewidth = 0.7) +
    ggplot2::geom_point(size = 1.6) +
    ggplot2::scale_colour_manual(
      values = c(attacker = .rk_accent(), defender = "#D55E00")
    ) +
    ggplot2::labs(
      x = "duel", y = "armies remaining", colour = NULL,
      title = sprintf(
        "Battle: %d vs %d", object$att_armies, object$def_armies
      ),
      subtitle = sprintf("%s after %d duels", outcome, object$rounds)
    ) +
    ggplot2::theme_minimal()
}

#' @importFrom ggplot2 autoplot
#' @export
ggplot2::autoplot
