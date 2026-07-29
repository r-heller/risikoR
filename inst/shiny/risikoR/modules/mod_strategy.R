# Strategy lab tab: tournaments between the built-in agents. The roster
# follows the game currently set up in the Play tab (shared reactive state).

RK_STRATEGIES <- c("random", "aggressive", "cautious")
RK_DEFAULT_STRATEGY <- c(Red = "aggressive", Blue = "cautious",
                         Green = "random", Yellow = "random")

mod_strategy_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      width = 288,
      rk_group("Who plays how"),
      # Generated from the roster: the tab used to offer a "Yellow plays"
      # selector in a three-player game, a control that could not do anything.
      shiny::uiOutput(ns("policies")),
      rk_group("Tournament"),
      shiny::numericInput(ns("n_games"), "Games", 5, min = 1, max = 200,
                          step = 1),
      shiny::numericInput(ns("max_rounds"), "Round cap", 40, min = 1,
                          max = 500, step = 5),
      shiny::numericInput(ns("seed"), "Seed", 1, min = 1, step = 1),
      shiny::actionButton(ns("run"), "Run tournament", class = "btn-primary"),
      rk_hint(
        "The roster follows the game set up in the Play tab. Each game is ",
        "dealt afresh and played to the end or to the round cap."
      )
    ),
    shiny::uiOutput(ns("status")),
    rk_panel(
      "Win rates",
      note = "One bar per player, in its colour on the map",
      # Held behind a placeholder rather than reserving 500 px of blank card:
      # a tournament takes tens of seconds, so the panel is empty until asked.
      shiny::uiOutput(ns("wins_body"))
    ),
    rk_panel(
      "Conquest odds reference",
      note = "How many armies it takes, whoever is playing",
      rk_figure(ns("heatmap"), width_mm = 178, height_mm = 152)
    )
  )
}

mod_strategy_server <- function(id, state) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    roster <- shiny::reactive({
      shiny::req(state$game)
      state$game$players
    })

    output$policies <- shiny::renderUI({
      players <- roster()
      shiny::req(players)
      shiny::tagList(lapply(players, function(p) {
        selected <- if (p %in% names(RK_DEFAULT_STRATEGY)) {
          RK_DEFAULT_STRATEGY[[p]]
        } else {
          "random"
        }
        shiny::selectInput(
          ns(p), paste(p, "plays"), RK_STRATEGIES,
          selected = if (is.null(input[[p]])) selected else input[[p]]
        )
      }))
    })

    output$status <- shiny::renderUI({
      players <- roster()
      shiny::req(players)
      do.call(rk_status, c(
        list(rk_pill("roster", paste(length(players), "players"),
                     tone = "rk-accent")),
        lapply(players, function(p) {
          rk_pill(p, if (is.null(input[[p]])) "—" else input[[p]],
                  colour = rk_player_colour(p))
        })
      ))
    })

    has_run <- shiny::reactiveVal(FALSE)
    shiny::observeEvent(input$run, has_run(TRUE))

    output$wins_body <- shiny::renderUI({
      if (!has_run()) {
        return(rk_hint(
          "Press ", shiny::strong("Run tournament"),
          " to play the roster above against itself. ",
          "A few dozen games take a few seconds each."
        ))
      }
      shiny::tagList(
        rk_figure(ns("wins"), width_mm = 186, height_mm = 118),
        shiny::uiOutput(ns("table"))
      )
    })

    results <- shiny::eventReactive(input$run, {
      shiny::req(input$n_games, input$max_rounds)
      players <- roster()
      policies <- vapply(
        players,
        function(p) if (is.null(input[[p]])) "random" else input[[p]],
        character(1L)
      )
      names(policies) <- players
      tryCatch(
        risikoR::rk_tournament(
          policies,
          n_games = as.integer(input$n_games),
          max_rounds = as.integer(input$max_rounds),
          seed = as.integer(input$seed)
        ),
        error = function(e) NULL
      )
    })

    output$wins <- shiny::renderPlot({
      res <- results()
      shiny::req(res)
      risikoR::rk_plot_tournament(res)
    }, res = RK_RES)

    output$table <- shiny::renderUI({
      res <- results()
      shiny::req(res)
      out <- as.data.frame(res)
      out <- out[order(-out$win_rate), ]
      rk_table(
        out,
        labels = c(
          player = "player", strategy = "strategy", games = "games",
          wins = "wins", win_rate = "win rate",
          mean_territories = "mean territories", mean_rounds = "mean rounds"
        ),
        percent = "win_rate",
        digits = c(mean_territories = 1L, mean_rounds = 1L),
        first_is_player = TRUE
      )
    })

    output$heatmap <- shiny::renderPlot({
      risikoR::rk_plot_odds_heatmap(att_range = 2:15, def_range = 1:15)
    }, res = RK_RES)
  })
}
