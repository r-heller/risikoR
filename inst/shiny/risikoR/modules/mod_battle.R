# Battle simulator tab: Monte Carlo against the exact solution.

mod_battle_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      width = 300,
      shiny::numericInput(ns("att"), "Attacker armies", 10, min = 2, step = 1),
      shiny::numericInput(ns("def"), "Defender armies", 8, min = 1, step = 1),
      shiny::numericInput(ns("nsim"), "Simulations", 2000, min = 1, step = 100),
      shiny::numericInput(ns("seed"), "Seed", 1, min = 1, step = 1),
      shiny::actionButton(ns("go"), "Simulate", class = "btn-primary")
    ),
    shiny::h5("Monte Carlo against the exact solution"),
    shiny::tableOutput(ns("compare")),
    shiny::h5("Distribution of surviving armies"),
    shiny::plotOutput(ns("hist"), height = "360px"),
    shiny::h5("A single battle"),
    shiny::plotOutput(ns("path"), height = "320px")
  )
}

mod_battle_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    sim <- shiny::eventReactive(input$go, {
      shiny::req(input$att, input$def, input$nsim)
      att <- as.integer(input$att)
      def <- as.integer(input$def)
      n <- as.integer(input$nsim)
      set.seed(as.integer(input$seed))
      battles <- lapply(seq_len(n), function(i) risikoR::rk_battle(att, def))
      list(
        att = att,
        def = def,
        n = n,
        survivors = data.frame(
          side = rep(c("attacker", "defender"), each = n),
          armies = c(
            vapply(battles, function(b) b$att_remaining, integer(1L)),
            vapply(battles, function(b) b$def_remaining, integer(1L))
          )
        ),
        example = battles[[1L]],
        odds = rbind(
          risikoR::rk_battle_odds(att, def, n = n, method = "mc"),
          risikoR::rk_battle_odds(att, def, method = "exact")
        )
      )
    }, ignoreNULL = FALSE)

    output$compare <- shiny::renderTable({
      s <- sim()
      shiny::req(s)
      s$odds
    }, digits = 4)

    output$hist <- shiny::renderPlot({
      s <- sim()
      shiny::req(s)
      ggplot2::ggplot(
        s$survivors,
        ggplot2::aes(x = rlang::.data$armies, fill = rlang::.data$side)
      ) +
        ggplot2::geom_bar(position = "dodge") +
        ggplot2::scale_fill_manual(
          values = c(attacker = "#5E2C8E", defender = "#D55E00")
        ) +
        ggplot2::labs(
          x = "armies left when the battle ends", y = "battles", fill = NULL,
          title = sprintf("%d attackers against %d defenders", s$att, s$def),
          subtitle = sprintf("%d simulated battles", s$n)
        ) +
        ggplot2::theme_minimal()
    })

    output$path <- shiny::renderPlot({
      s <- sim()
      shiny::req(s)
      tryCatch(
        ggplot2::autoplot(s$example),
        error = function(e) NULL
      )
    })
  })
}
