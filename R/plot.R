#' Plot the loss distribution of a single duel
#'
#' Draws the exact outcome distribution of one dice duel (see
#' [rk_duel_dist()]) as a bar chart. Bars are coloured by who comes out of the
#' exchange ahead, and labelled with the probability.
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

  dist$outcome <- factor(
    sprintf("%d / %d", dist$att_loss, dist$def_loss),
    levels = sprintf("%d / %d", dist$att_loss, dist$def_loss)
  )
  net <- dist$def_loss - dist$att_loss
  dist$edge <- factor(
    ifelse(net > 0, "attacker ahead", ifelse(net < 0, "defender ahead", "even")),
    levels = c("attacker ahead", "even", "defender ahead")
  )
  dist$label <- .rk_pct(dist$p, 1L)

  ggplot2::ggplot(
    dist,
    ggplot2::aes(x = .data$outcome, y = .data$p, fill = .data$edge)
  ) +
    ggplot2::geom_col(width = 0.62) +
    ggplot2::geom_text(
      ggplot2::aes(label = .data$label), vjust = -0.55,
      size = 3.1, colour = .rk_ink_mid()
    ) +
    ggplot2::scale_fill_manual(
      values = c(
        "attacker ahead" = .rk_accent(),
        "even" = "#B9BEC6",
        "defender ahead" = "#D55E00"
      ),
      drop = FALSE, name = NULL
    ) +
    ggplot2::scale_y_continuous(
      labels = function(z) .rk_pct(z, 0L),
      expand = ggplot2::expansion(mult = c(0, 0.14))
    ) +
    ggplot2::labs(
      x = "armies lost: attacker / defender",
      y = "probability",
      title = sprintf(
        "One exchange: %d attacking dice against %d defending",
        odds$n_att, odds$n_def
      ),
      subtitle = sprintf(
        "Expected losses %.4f attacker, %.4f defender (sd %.4f)",
        odds$e_att_loss, odds$e_def_loss, odds$sd_loss
      ),
      caption = "Highest dice compared pairwise; ties go to the defender."
    ) +
    .rk_theme(grid = "y") +
    ggplot2::theme(
      panel.grid.major.x = ggplot2::element_blank(),
      legend.position = "bottom"
    )
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
  even <- df$def_armies[df$p_conquer >= 0.5]
  even <- if (length(even) > 0L) max(even) else NA_integer_

  p <- ggplot2::ggplot(
    df, ggplot2::aes(x = .data$def_armies, y = .data$p_conquer)
  ) +
    # A probability belongs on a full 0-1 scale, but that leaves the bottom half
    # of the panel empty. Give it a job: it is the region where the attack is
    # the wrong move.
    ggplot2::annotate(
      "rect", xmin = -Inf, xmax = Inf, ymin = 0, ymax = 0.5,
      fill = .rk_rule(), alpha = 0.55
    ) +
    ggplot2::annotate(
      "text", x = min(df$def_armies), y = 0.19, hjust = -0.08,
      label = "defender favoured", size = 2.9, colour = .rk_ink_soft()
    ) +
    ggplot2::geom_hline(
      yintercept = 0.5, linetype = "22", linewidth = 0.4,
      colour = .rk_ink_soft()
    ) +
    ggplot2::geom_line(colour = .rk_accent(), linewidth = 0.9) +
    ggplot2::geom_point(
      colour = .rk_accent(), fill = "white", shape = 21,
      size = 1.9, stroke = 0.8
    )
  if (!is.na(even) && even < max(df$def_armies)) {
    p <- p + ggplot2::geom_vline(
      xintercept = even, linetype = "22", linewidth = 0.4,
      colour = .rk_ink_soft()
    )
  }
  p +
    ggplot2::scale_y_continuous(
      limits = c(0, 1), labels = function(z) .rk_pct(z, 0L),
      expand = ggplot2::expansion(mult = c(0, 0.03))
    ) +
    ggplot2::scale_x_continuous(
      breaks = .rk_int_breaks, expand = ggplot2::expansion(mult = 0.035)
    ) +
    ggplot2::labs(
      x = "defender armies",
      y = "P(conquer)",
      title = sprintf(
        "Conquest probability with %d attacking armies", df$att_armies[[1L]]
      ),
      subtitle = if (is.na(even)) {
        "The attacker is an underdog across this whole range"
      } else if (even >= max(df$def_armies)) {
        "Better than even odds across this whole range"
      } else {
        sprintf("Better than even odds up to %d defending armies", even)
      },
      caption = if (method == "exact") {
        "Exact Markov-chain solution. Dashed line marks even odds."
      } else {
        sprintf(
          "Monte Carlo, %d battles per point. Dashed line marks even odds.", n
        )
      }
    ) +
    .rk_theme(grid = "y")
}

#' Plot the world map
#'
#' Draws the board. Territories are tiled landmasses grouped into continents,
#' borders between neighbours are drawn as lines on the ground and neighbours
#' that only meet across water are joined by a dashed sea route. An `rk_game`
#' is coloured by owner and each territory carries its army count; a bare
#' `rk_map` is coloured by continent.
#'
#' @param x An `rk_game` or an `rk_map`.
#' @param labels A flag: label territories with their names?
#' @param armies A flag: label territories with their army count? Only applies
#'   to an `rk_game`.
#'
#' @details
#' Forty-two named territories need room. The board is laid out for a canvas of
#' roughly 240 by 170 mm; on anything much smaller than about 180 mm wide the
#' territory names will start to overrun their territories, because text keeps
#' its point size while the map shrinks with the device. Pass `labels = FALSE`
#' for a thumbnail.
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

  board <- .rk_board(map)
  nodes <- board$centres
  is_game <- inherits(x, "rk_game")
  cfg <- board$cfg

  if (is_game) {
    key <- rk_owner(x, nodes$territory)
    nodes$armies <- rk_armies(x, nodes$territory)
    held <- vapply(
      x$players, function(p) sum(key == p, na.rm = TRUE), integer(1L)
    )
    values <- .rk_player_colours(x$players)
    legend <- "owner"
    # Only players who still hold ground get a key. A key for an eliminated
    # player draws an empty box, because the layer has no rows in that colour
    # for the glyph to take its fill from; the caption says who is out instead.
    breaks <- x$players[held > 0L]
    guide_labels <- sprintf("%s  %d", breaks, held[held > 0L])
    gone <- x$players[held == 0L]
    # An escape rather than a literal em dash: R code has to stay ASCII to be
    # portable across locales.
    title <- sprintf("Risk \u2014 round %d", x$round)
    subtitle <- if (identical(x$phase, "over")) {
      sprintf("%s has conquered the world", rk_winner(x))
    } else {
      sprintf("%s to move, %s phase", x$turn, x$phase)
    }
    caption <- sprintf(
      paste0(
        "Numbers are armies; the count beside each colour is territories ",
        "held. %s%d armies on the board.%s"
      ),
      .rk_route_note(board), sum(nodes$armies),
      if (length(gone) > 0L) {
        sprintf(" %s no longer on the board.", paste(gone, collapse = ", "))
      } else {
        ""
      }
    )
  } else {
    key <- unname(.rk_territory_continent(map)[nodes$territory])
    nodes$armies <- NA_integer_
    values <- .rk_continent_colours()[names(map$continent)]
    if (anyNA(values)) {
      values <- .rk_palette(length(map$continent))
      names(values) <- names(map$continent)
    }
    legend <- "continent"
    breaks <- names(map$continent)
    guide_labels <- .rk_label(breaks)
    title <- "The Risk world board"
    subtitle <- sprintf(
      "%d territories in %d continent%s",
      length(map$territories), length(map$continent),
      if (length(map$continent) == 1L) "" else "s"
    )
    caption <- paste0(
      "The number beside each continent is the bonus for holding all of it. ",
      .rk_route_note(board)
    )
  }
  nodes$key <- factor(key, levels = breaks)
  fills <- unname(values[as.character(nodes$key)])

  tiles <- board$tiles
  tiles$key <- factor(
    nodes$key[match(tiles$territory, nodes$territory)], levels = breaks
  )
  coast <- board$coast
  coast$continent <- factor(coast$continent, levels = names(map$continent))
  cont_col <- .rk_continent_colours()[names(map$continent)]
  if (anyNA(cont_col)) {
    cont_col <- .rk_palette(length(map$continent))
    names(cont_col) <- names(map$continent)
  }

  # Each side of a border is drawn in whichever of white or its own darkened
  # fill stands out against that side's territory: a white crease vanishes on a
  # pale yellow player, a dark one vanishes on a saturated blue.
  border_fill <- unname(values[as.character(
    nodes$key[match(board$borders$territory, nodes$territory)]
  )])
  border_col <- ifelse(
    is.na(border_fill), "white",
    .rk_contrast(
      ifelse(is.na(border_fill), "#FFFFFF", border_fill),
      dark = .rk_shade(ifelse(is.na(border_fill), "#FFFFFF", border_fill), 0.55),
      light = "#FFFFFF"
    )
  )

  p <- ggplot2::ggplot() +
    # The stroke follows the fill so that the seams between hexagons close
    # and each territory reads as one landmass.
    ggplot2::geom_polygon(
      data = tiles,
      ggplot2::aes(
        x = .data$x, y = .data$y, group = .data$cell, fill = .data$key,
        colour = ggplot2::after_scale(.data$fill)
      ),
      linewidth = 0.3
    ) +
    ggplot2::geom_segment(
      data = board$borders,
      ggplot2::aes(
        x = .data$x, y = .data$y, xend = .data$xend, yend = .data$yend
      ),
      colour = border_col, linewidth = 0.4, lineend = "round"
    ) +
    ggplot2::geom_segment(
      data = coast,
      ggplot2::aes(
        x = .data$x, y = .data$y, xend = .data$xend, yend = .data$yend,
        colour = .data$continent
      ),
      linewidth = 0.8, show.legend = FALSE, lineend = "round"
    ) +
    ggplot2::scale_fill_manual(
      values = values, breaks = breaks, labels = guide_labels,
      name = legend, drop = FALSE,
      guide = if (is_game) {
        ggplot2::guide_legend(
          override.aes = list(colour = NA), nrow = 1L,
          keywidth = grid::unit(11, "pt"), keyheight = grid::unit(11, "pt")
        )
      } else {
        "none"
      }
    ) +
    ggplot2::scale_colour_manual(
      values = .rk_shade(cont_col, 0.62),
      guide = "none", drop = FALSE, na.value = "grey40"
    )

  # Routes go on top of the land, not under it. Drawn underneath they surfaced
  # only where they happened to cross open water, which read as stray dashes.
  if (nrow(board$routes) > 0L) {
    ends <- board$routes[
      !duplicated(board$routes$id) |
        !duplicated(board$routes$id, fromLast = TRUE),
    ]
    p <- p +
      ggplot2::geom_path(
        data = board$routes,
        ggplot2::aes(x = .data$x, y = .data$y, group = .data$id),
        colour = "white", linewidth = 1.6, lineend = "round"
      ) +
      ggplot2::geom_path(
        data = board$routes,
        ggplot2::aes(x = .data$x, y = .data$y, group = .data$id),
        colour = .rk_shore(), linetype = "22", linewidth = 0.55
      ) +
      ggplot2::geom_point(
        data = ends, ggplot2::aes(x = .data$x, y = .data$y),
        colour = .rk_shore(), size = 0.9
      )
  }
  if (nrow(board$wraps) > 0L) {
    tips <- board$wraps[!duplicated(board$wraps$id, fromLast = TRUE), ]
    p <- p +
      ggplot2::geom_path(
        data = board$wraps,
        ggplot2::aes(x = .data$x, y = .data$y, group = .data$id),
        colour = "white", linewidth = 1.5, lineend = "round"
      ) +
      ggplot2::geom_path(
        data = board$wraps,
        ggplot2::aes(x = .data$x, y = .data$y, group = .data$id),
        colour = .rk_shore(), linetype = "22", linewidth = 0.5
      ) +
      ggplot2::geom_point(
        data = tips,
        ggplot2::aes(x = .data$x, y = .data$y),
        colour = .rk_shore(), size = 0.9
      )
  }

  # Continent names carry their own continent's colour, so a label that has to
  # sit in a shared stretch of ocean still says which landmass it belongs to.
  cont_ink <- .rk_shade(cont_col, 0.55)
  p <- p + .rk_halo(
    board$labels, ggplot2::aes(x = .data$x, y = .data$y, label = .data$label),
    size = 2.9, colour = unname(cont_ink[board$labels$continent]),
    halo = .rk_ocean(), fontface = "bold"
  )

  chip_r <- 0.32 * cfg$radius
  show_armies <- isTRUE(armies) && is_game
  chip_y <- nodes$y - 0.18 * cfg$radius
  if (show_armies) {
    discs <- .rk_discs(nodes$x, chip_y, chip_r)
    p <- p +
      ggplot2::geom_polygon(
        data = discs,
        ggplot2::aes(x = .data$x, y = .data$y, group = .data$id),
        fill = "white", colour = NA
      ) +
      ggplot2::geom_text(
        data = nodes,
        ggplot2::aes(x = .data$x, y = chip_y, label = .data$armies),
        size = 2.9, fontface = "bold", colour = .rk_ink_dark()
      )
  }
  if (labels) {
    nodes$name <- .rk_wrap(nodes$territory)
    # Long names in small territories used to run off into the ocean, where
    # white text on the pale sea is unreadable. Fit them instead.
    nodes$size <- .rk_fit_size(nodes$name, nodes$span, size = 2.4)
    nodes$ny <- if (show_armies) chip_y + chip_r * 1.25 else nodes$y
    p <- p + ggplot2::geom_text(
      data = nodes,
      ggplot2::aes(
        x = .data$x, y = .data$ny, label = .data$name, size = .data$size
      ),
      vjust = if (show_armies) 0 else 0.5,
      lineheight = 0.86, show.legend = FALSE,
      colour = .rk_contrast(fills, dark = "#16181C", light = "#FFFFFF")
    ) +
      ggplot2::scale_size_identity()
  }

  p +
    ggplot2::coord_equal(clip = "off", expand = TRUE) +
    ggplot2::labs(
      x = NULL, y = NULL, title = title, subtitle = subtitle,
      caption = .rk_caption(caption)
    ) +
    .rk_theme_map()
}

#' Heatmap of conquest probability
#'
#' Draws [rk_odds_table()] as a tile heatmap: attacker armies on one axis,
#' defender armies on the other, conquest probability as fill. The stepped
#' line traces where the odds pass even.
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

  p <- ggplot2::ggplot(
    odds,
    ggplot2::aes(
      x = .data$def_armies, y = .data$att_armies, fill = .data$p_conquer
    )
  ) +
    ggplot2::geom_tile(colour = "#F4F5F7", linewidth = 0.5)

  frontier <- .rk_even_frontier(odds)
  if (!is.null(frontier)) {
    p <- p + ggplot2::geom_step(
      data = frontier,
      ggplot2::aes(x = .data$def_armies, y = .data$att_armies),
      inherit.aes = FALSE, colour = "white", linewidth = 1.1,
      direction = "vh"
    ) +
      ggplot2::geom_step(
        data = frontier,
        ggplot2::aes(x = .data$def_armies, y = .data$att_armies),
        inherit.aes = FALSE, colour = .rk_ink_dark(), linewidth = 0.45,
        direction = "vh"
      )
  }

  p +
    # The pale end used to bottom out at near-white, so the low-probability
    # corner of the grid dissolved into the page. Start it at a visible tint.
    ggplot2::scale_fill_gradientn(
      colours = c("#EFE9F5", "#D3C2E4", "#A480C9", "#6B3AA0", "#2E1049"),
      limits = c(0, 1), labels = function(z) .rk_pct(z, 0L),
      breaks = c(0, 0.25, 0.5, 0.75, 1),
      guide = ggplot2::guide_colourbar(
        barwidth = grid::unit(140, "pt"), barheight = grid::unit(7, "pt"),
        title.vjust = 1
      )
    ) +
    ggplot2::scale_x_continuous(
      breaks = .rk_int_breaks, expand = ggplot2::expansion(0)
    ) +
    ggplot2::scale_y_continuous(
      breaks = .rk_int_breaks, expand = ggplot2::expansion(0)
    ) +
    ggplot2::labs(
      x = "defender armies",
      y = "attacker armies",
      fill = "P(conquer)",
      title = "Conquest probability",
      subtitle = "How many armies it takes to be confident of taking a territory",
      caption = if (method == "exact") {
        "Exact Markov-chain solution. The dark step marks even odds."
      } else {
        sprintf(
          "Monte Carlo, %d battles per cell. The dark step marks even odds.", n
        )
      }
    ) +
    .rk_theme(grid = "none")
}

#' Plot tournament win rates
#'
#' Draws the win rate of each player in a [rk_tournament()] result as a
#' horizontal bar chart, sorted by win rate. Each bar carries the player's map
#' colour and is labelled with the strategy it played.
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
  results <- as.data.frame(results)
  values <- .rk_player_colours(results$player)

  ord <- order(results$win_rate, decreasing = FALSE)
  results$player <- factor(results$player, levels = results$player[ord])
  results$tick <- sprintf("%s\n%s", as.character(results$player),
                          results$strategy)
  ticks <- results$tick[ord]
  names(ticks) <- as.character(results$player)[ord]
  results$label <- .rk_pct(results$win_rate, 0L)

  ggplot2::ggplot(
    results,
    ggplot2::aes(x = .data$win_rate, y = .data$player, fill = .data$player)
  ) +
    # A track behind every bar, so a player on 0% still gets a row instead of
    # looking like a rendering failure.
    ggplot2::geom_col(
      ggplot2::aes(x = 1), fill = .rk_rule(), width = 0.6
    ) +
    ggplot2::geom_col(width = 0.6) +
    ggplot2::geom_text(
      ggplot2::aes(label = .data$label), hjust = -0.25,
      size = 3.1, colour = .rk_ink_mid()
    ) +
    ggplot2::scale_fill_manual(values = values, guide = "none") +
    ggplot2::scale_y_discrete(labels = ticks) +
    ggplot2::scale_x_continuous(
      limits = c(0, 1), labels = function(z) .rk_pct(z, 0L),
      expand = ggplot2::expansion(mult = c(0, 0.02))
    ) +
    ggplot2::labs(
      x = "win rate", y = NULL,
      title = "Tournament win rates",
      subtitle = sprintf(
        "%d players, %d games each", nrow(results), results$games[[1L]]
      ),
      caption = "Bars carry each player's colour on the map."
    ) +
    .rk_theme(grid = "x") +
    ggplot2::theme(
      axis.text.y = ggplot2::element_text(
        lineheight = 0.95, colour = .rk_ink_dark()
      )
    )
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
    side = factor(
      rep(c("attacker", "defender"), each = nrow(log) + 1L),
      levels = c("attacker", "defender")
    ),
    armies = c(
      object$att_armies - cumsum(c(0L, log$att_loss)),
      object$def_armies - cumsum(c(0L, log$def_loss))
    )
  )
  ends <- path[path$round == max(path$round), ]
  outcome <- if (object$conquered) "territory taken" else "attack repelled"
  values <- c(attacker = .rk_accent(), defender = "#D55E00")

  ggplot2::ggplot(
    path,
    ggplot2::aes(x = .data$round, y = .data$armies, colour = .data$side)
  ) +
    ggplot2::geom_hline(
      yintercept = 0, linewidth = 0.4, colour = .rk_ink_soft()
    ) +
    # "hv", not "vh": each side holds its count through the duel it is about to
    # fight and drops when that duel resolves. Stepping the other way drew the
    # loss before the duel that caused it.
    ggplot2::geom_step(direction = "hv", linewidth = 0.8) +
    ggplot2::geom_point(size = 1.5) +
    ggplot2::geom_text(
      data = ends,
      ggplot2::aes(label = .data$armies), hjust = -0.6, vjust = 0.4,
      size = 3.1, fontface = "bold", show.legend = FALSE
    ) +
    ggplot2::scale_colour_manual(values = values, name = NULL) +
    ggplot2::scale_x_continuous(
      breaks = .rk_int_breaks,
      expand = ggplot2::expansion(mult = c(0.02, 0.10))
    ) +
    ggplot2::scale_y_continuous(
      breaks = .rk_int_breaks,
      expand = ggplot2::expansion(mult = c(0.06, 0.08))
    ) +
    ggplot2::labs(
      x = "duels fought", y = "armies remaining",
      title = sprintf(
        "A single battle: %d against %d", object$att_armies, object$def_armies
      ),
      subtitle = sprintf(
        "%s after %d duel%s", outcome, object$rounds,
        if (object$rounds == 1L) "" else "s"
      )
    ) +
    .rk_theme(grid = "y")
}

#' @importFrom ggplot2 autoplot
#' @export
ggplot2::autoplot

# --- internal helpers -------------------------------------------------------

# Whole-number axis breaks, at most about `n` of them, anchored on the data so
# that both ends of the range get a label instead of `pretty()` cutting them off.
.rk_int_breaks <- function(limits, n = 7L) {
  rng <- range(limits, na.rm = TRUE)
  if (!all(is.finite(rng))) {
    return(numeric(0))
  }
  lo <- ceiling(rng[[1L]])
  hi <- floor(rng[[2L]])
  if (hi < lo) {
    return(numeric(0))
  }
  by <- max(1L, ceiling((hi - lo) / max(1L, n - 1L)))
  seq(lo, hi, by = by)
}

# Only mention the dashed lines in a caption when the board actually has some.
.rk_route_note <- function(board) {
  arcs <- nrow(board$routes) > 0L
  wraps <- nrow(board$wraps) > 0L
  if (arcs && wraps) {
    "Dashed lines are sea routes; the stubs at the edge join across the board. "
  } else if (arcs) {
    "Dashed lines are sea routes. "
  } else if (wraps) {
    "The dashed stubs at the edges join across the board. "
  } else {
    ""
  }
}

# The largest defender count still giving the attacker even odds, per row.
.rk_even_frontier <- function(odds) {
  rows <- split(odds, odds$att_armies)
  out <- lapply(rows, function(d) {
    win <- d$def_armies[d$p_conquer >= 0.5]
    if (length(win) == 0L) {
      return(NULL)
    }
    tibble::tibble(att_armies = d$att_armies[[1L]], def_armies = max(win) + 0.5)
  })
  out <- do.call(rbind, out)
  if (is.null(out) || nrow(out) < 2L) {
    return(NULL)
  }
  out[order(out$att_armies), ]
}
