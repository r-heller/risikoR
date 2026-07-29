# Strategy lab tab: tournaments between the built-in agents. The roster
# follows the game currently set up in the Play tab (shared reactive state).

mod_strategy_ui <- function(id) {
  ns <- shiny::NS(id)
  choices <- c("random", "aggressive", "cautious")
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      width = 300,
      shiny::selectInput(ns("Red"), "Red plays", choices, "aggressive"),
      shiny::selectInput(ns("Blue"), "Blue plays", choices, "cautious"),
      shiny::selectInput(ns("Green"), "Green plays", choices, "random"),
      shiny::selectInput(ns("Yellow"), "Yellow plays", choices, "random"),
      shiny::numericInput(ns("n_games"), "Games", 5, min = 1, max = 200,
                          step = 1),
      shiny::numericInput(ns("max_rounds"), "Round cap", 40, min = 1,
                          max = 500, step = 5),
      shiny::numericInput(ns("seed"), "Seed", 1, min = 1, step = 1),
      shiny::actionButton(ns("run"), "Run tournament", class = "btn-primary"),
      shiny::helpText(
        "The roster follows the game set up in the Play tab. Each game is ",
        "dealt afresh and played to the end or to the round cap."
      )
    ),
    shiny::uiOutput(ns("roster")),
    shiny::h5("Win rates"),
    shiny::plotOutput(ns("wins"), height = "340px"),
    shiny::tableOutput(ns("table")),
    shiny::h5("Conquest odds reference"),
    shiny::plotOutput(ns("heatmap"), height = "420px")
  )
}

mod_strategy_server <- function(id, state) {
  shiny::moduleServer(id, function(input, output, session) {
    roster <- shiny::reactive({
      shiny::req(state$game)
      state$game$players
    })

    output$roster <- shiny::renderUI({
      players <- roster()
      shiny::req(players)
      shiny::div(
        class = "alert alert-secondary",
        "Roster: ", shiny::strong(paste(players, collapse = ", ")),
        shiny::tags$span(
          class = "text-muted",
          paste0(" (", length(players), " players, from the Play tab)")
        )
      )
    })

    results <- shiny::eventReactive(input$run, {
      shiny::req(input$n_games, input$max_rounds)
      players <- roster()
      policies <- vapply(players, function(p) input[[p]], character(1L))
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
    })

    output$table <- shiny::renderTable({
      res <- results()
      shiny::req(res)
      res
    }, digits = 3)

    output$heatmap <- shiny::renderPlot({
      tryCatch(
        risikoR::rk_plot_odds_heatmap(att_range = 2:15, def_range = 1:15),
        error = function(e) NULL
      )
    })
  })
}
