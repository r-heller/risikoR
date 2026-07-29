# Play tab: an interactive game against the built-in AI agents.

mod_play_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      width = 288,
      rk_group("New game"),
      shiny::selectInput(
        ns("n_players"), "Players",
        choices = c(2, 3, 4), selected = 3
      ),
      shiny::selectInput(
        ns("strategy"), "Opponent strategy",
        choices = c("random", "aggressive", "cautious"),
        selected = "aggressive"
      ),
      shiny::numericInput(ns("seed"), "Seed", value = 1, min = 1, step = 1),
      shiny::actionButton(ns("new_game"), "Deal a new board",
                          class = "btn-primary"),
      rk_group("Your turn"),
      shiny::actionButton(ns("end_turn"), "End turn",
                          class = "btn-outline-secondary"),
      shiny::actionButton(ns("clear"), "Clear selection",
                          class = "btn-outline-secondary"),
      rk_group("Board"),
      shiny::checkboxInput(ns("labels"), "Territory names", value = TRUE),
      rk_hint(
        "You play Red. Click your territories to place reinforcements, then ",
        "click one of your own and a neighbour to attack it or to move ",
        "armies there."
      )
    ),
    shiny::uiOutput(ns("status")),
    rk_panel(
      "The board",
      note = "Click a territory to act on it",
      rk_map_figure(ns("map"), ns("map_click"), width_mm = 244, height_mm = 173)
    ),
    bslib::layout_columns(
      col_widths = c(7, 5),
      rk_panel("Standings", shiny::uiOutput(ns("standings"))),
      rk_panel("Message and last battle", shiny::uiOutput(ns("battle")))
    )
  )
}

mod_play_server <- function(id, state) {
  shiny::moduleServer(id, function(input, output, session) {
    human <- "Red"
    all_players <- c("Red", "Blue", "Green", "Yellow")

    shiny::observeEvent(input$new_game, {
      players <- all_players[seq_len(as.integer(input$n_players))]
      seed <- if (is.null(input$seed) || is.na(input$seed)) 1L else input$seed
      state$game <- risikoR::rk_game(players, seed = as.integer(seed))
      state$selected <- NA_character_
      state$pending <- integer(0)
      state$message <- "Place your reinforcements by clicking your territories."
    })

    shiny::observeEvent(input$clear, {
      state$selected <- NA_character_
      state$message <- "Selection cleared."
    })

    shiny::observeEvent(input$map_click, {
      shiny::req(state$game, input$map_click)
      game <- state$game
      if (identical(game$phase, "over") || !identical(game$turn, human)) {
        return()
      }
      territory <- rk_nearest_territory(
        game$map$layout, input$map_click$x, input$map_click$y
      )
      if (is.na(territory)) {
        return()
      }
      if (identical(game$phase, "reinforce")) {
        rk_click_reinforce(state, game, territory, human)
      } else {
        rk_click_move(state, game, territory, human)
      }
    })

    shiny::observeEvent(input$end_turn, {
      shiny::req(state$game)
      game <- state$game
      if (identical(game$phase, "over")) {
        return()
      }
      if (identical(game$phase, "reinforce")) {
        state$message <- "Place every reinforcement army first."
        return()
      }
      result <- tryCatch(
        risikoR::rk_end_turn(game),
        error = function(e) conditionMessage(e)
      )
      if (is.character(result)) {
        state$message <- result
        return()
      }
      state$selected <- NA_character_
      state$game <- rk_run_ai(result, human, input$strategy)
      state$message <- if (identical(state$game$phase, "over")) {
        "The game is over."
      } else {
        "Your turn: place your reinforcements."
      }
    })

    output$map <- shiny::renderPlot({
      shiny::req(state$game)
      tryCatch(
        risikoR::rk_plot_map(state$game, labels = isTRUE(input$labels)),
        error = function(e) NULL
      )
    }, res = RK_RES)

    output$standings <- shiny::renderUI({
      shiny::req(state$game)
      standings <- as.data.frame(summary(state$game))
      standings <- standings[order(-standings$territories), ]
      standings$alive <- ifelse(standings$alive, "in play", "out")
      rk_table(
        standings,
        labels = c(
          player = "player", territories = "territories", armies = "armies",
          continents = "continents", reinforcements = "next reinforcements",
          alive = "status"
        ),
        first_is_player = TRUE
      )
    })

    output$battle <- shiny::renderUI({
      shiny::req(state$game)
      battle <- state$game$last_battle
      lines <- if (battle$rounds > 0L) {
        format(battle)
      } else {
        "No battle fought yet."
      }
      shiny::tagList(
        shiny::p(class = "rk-note", state$message),
        shiny::pre(class = "rk-log", paste(lines, collapse = "\n"))
      )
    })

    output$status <- shiny::renderUI({
      shiny::req(state$game)
      game <- state$game
      if (risikoR::rk_is_winner(game)) {
        winner <- risikoR::rk_winner(game)
        return(rk_status(
          rk_pill("round", game$round),
          rk_pill("winner", winner, tone = "rk-win",
                  colour = rk_player_colour(winner)),
          rk_pill("armies", sum(risikoR::rk_armies(
            game, risikoR::rk_territories(game, winner)
          )))
        ))
      }
      left <- rk_armies_left(game, state$pending, human)
      rk_status(
        rk_pill("round", game$round),
        rk_pill("to move", game$turn, tone = "rk-accent",
                colour = rk_player_colour(game$turn)),
        rk_pill("phase", game$phase),
        if (identical(game$turn, human) && identical(game$phase, "reinforce")) {
          rk_pill("left to place", left)
        },
        if (!is.na(state$selected)) {
          rk_pill("selected", gsub("_", " ", state$selected))
        },
        rk_pill("your territories", length(risikoR::rk_territories(game, human)),
                colour = rk_player_colour(human))
      )
    })
  })
}

# --- helpers ---------------------------------------------------------------

# The territory whose layout position is closest to a click, or NA when the
# click landed in open water. The map claims each patch of ground for the
# nearest layout position, so nearest-position is exactly the territory drawn
# under the cursor; the tolerance only decides how far offshore still counts,
# and is scaled off the board's own spacing rather than hard-coded.
rk_nearest_territory <- function(layout, x, y) {
  if (is.null(x) || is.null(y)) {
    return(NA_character_)
  }
  d <- sqrt((layout$x - x)^2 + (layout$y - y)^2)
  spacing <- stats::median(apply(
    as.matrix(stats::dist(cbind(layout$x, layout$y))), 1L,
    function(z) min(z[z > 0])
  ))
  if (min(d) > 0.65 * spacing) {
    return(NA_character_)
  }
  layout$territory[[which.min(d)]]
}

rk_armies_left <- function(game, pending, player) {
  total <- risikoR::rk_reinforcements(game, player)
  max(0L, total - sum(pending))
}

# Reinforce phase: each click adds one army; the placement is submitted once
# every army has been assigned.
rk_click_reinforce <- function(state, game, territory, human) {
  if (!identical(risikoR::rk_owner(game, territory), human)) {
    state$message <- "You can only reinforce your own territories."
    return(invisible(NULL))
  }
  pending <- state$pending
  current <- if (territory %in% names(pending)) pending[[territory]] else 0L
  pending[[territory]] <- current + 1L
  left <- rk_armies_left(game, pending, human)
  if (left > 0L) {
    state$pending <- pending
    state$message <- paste0(left, " armies left to place.")
    return(invisible(NULL))
  }
  result <- tryCatch(
    risikoR::rk_reinforce(game, human, pending),
    error = function(e) conditionMessage(e)
  )
  if (is.character(result)) {
    state$message <- result
    return(invisible(NULL))
  }
  state$game <- result
  state$pending <- integer(0)
  state$message <- "Reinforcements placed. Attack, move armies or end the turn."
  invisible(NULL)
}

# Attack and fortify phases: the first click selects, the second acts.
rk_click_move <- function(state, game, territory, human) {
  selected <- state$selected
  if (is.na(selected)) {
    if (!identical(risikoR::rk_owner(game, territory), human)) {
      state$message <- "Select one of your own territories first."
      return(invisible(NULL))
    }
    state$selected <- territory
    state$message <- paste0("Selected ", territory, ".")
    return(invisible(NULL))
  }
  if (identical(selected, territory)) {
    state$selected <- NA_character_
    state$message <- "Selection cleared."
    return(invisible(NULL))
  }
  owner <- risikoR::rk_owner(game, territory)
  result <- if (identical(owner, human)) {
    spare <- risikoR::rk_armies(game, selected) - 1L
    tryCatch(
      risikoR::rk_fortify(game, selected, territory, spare),
      error = function(e) conditionMessage(e)
    )
  } else {
    tryCatch(
      risikoR::rk_attack(game, selected, territory),
      error = function(e) conditionMessage(e)
    )
  }
  if (is.character(result)) {
    state$message <- result
    state$selected <- NA_character_
    return(invisible(NULL))
  }
  state$game <- result
  state$selected <- NA_character_
  state$message <- if (identical(owner, human)) {
    paste0("Moved armies from ", selected, " to ", territory, ".")
  } else {
    paste0("Attacked ", territory, " from ", selected, ".")
  }
  invisible(NULL)
}

# Let the AI players take their turns until the human is back on the clock.
rk_run_ai <- function(game, human, strategy) {
  policy <- risikoR::rk_ai(strategy)
  guard <- 0L
  while (!identical(game$phase, "over") &&
         !identical(game$turn, human) &&
         guard < 5000L) {
    guard <- guard + 1L
    stepped <- tryCatch(
      risikoR::rk_step(game, policy = policy),
      error = function(e) NULL
    )
    if (is.null(stepped)) break
    game <- stepped
  }
  game
}
