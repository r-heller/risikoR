# Battle simulator tab: Monte Carlo against the exact solution.

mod_battle_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      width = 288,
      rk_group("The attack"),
      shiny::numericInput(ns("att"), "Attacker armies", 10, min = 2, step = 1),
      shiny::numericInput(ns("def"), "Defender armies", 8, min = 1, step = 1),
      rk_group("Simulation"),
      shiny::numericInput(ns("nsim"), "Battles to simulate", 2000, min = 1,
                          step = 100),
      shiny::numericInput(ns("seed"), "Seed", 1, min = 1, step = 1),
      shiny::actionButton(ns("go"), "Simulate", class = "btn-primary"),
      rk_hint(
        "The attacker keeps throwing until the territory falls or fewer than ",
        "two armies are left to attack with. The exact row comes from the ",
        "Markov chain, so the two should agree to within sampling error."
      )
    ),
    shiny::uiOutput(ns("status")),
    rk_panel(
      "Monte Carlo against the exact solution",
      note = "Two routes to the same number",
      shiny::uiOutput(ns("compare"))
    ),
    rk_panel(
      "Where the battle ends",
      note = "Armies left standing across every simulated battle",
      rk_figure(ns("hist"), width_mm = 186, height_mm = 118)
    ),
    rk_panel(
      "One battle, duel by duel",
      note = "The first of the simulated battles",
      rk_figure(ns("path"), width_mm = 186, height_mm = 118)
    )
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
          side = factor(
            rep(c("attacker", "defender"), each = n),
            levels = c("attacker", "defender")
          ),
          armies = c(
            vapply(battles, function(b) b$att_remaining, integer(1L)),
            vapply(battles, function(b) b$def_remaining, integer(1L))
          )
        ),
        taken = mean(vapply(battles, function(b) b$conquered, logical(1L))),
        example = battles[[1L]],
        odds = rbind(
          risikoR::rk_battle_odds(att, def, n = n, method = "mc"),
          risikoR::rk_battle_odds(att, def, method = "exact")
        )
      )
    }, ignoreNULL = FALSE)

    output$status <- shiny::renderUI({
      s <- sim()
      shiny::req(s)
      rk_status(
        rk_pill("attack", sprintf("%d v %d", s$att, s$def), tone = "rk-accent"),
        rk_pill("battles", format(s$n, big.mark = " ")),
        rk_pill(
          "territory taken",
          paste0(formatC(100 * s$taken, format = "f", digits = 1L), "%")
        )
      )
    })

    output$compare <- shiny::renderUI({
      s <- sim()
      shiny::req(s)
      out <- as.data.frame(s$odds)
      out$method <- ifelse(out$method == "mc", "Monte Carlo", "exact")
      out <- out[, c("method", "n", "p_conquer", "e_att_survivors",
                     "e_def_survivors")]
      rk_table(
        out,
        labels = c(
          method = "method", n = "battles", p_conquer = "P(conquer)",
          e_att_survivors = "attacker survivors",
          e_def_survivors = "defender survivors"
        ),
        # One decimal, not none: the whole point of the panel is that the two
        # rows agree, and 64% against 65% reads as a disagreement.
        percent = "p_conquer", percent_digits = 1L,
        digits = c(e_att_survivors = 2L, e_def_survivors = 2L)
      )
    })

    # This panel used to render "Error: [object Object]". Its aesthetics were
    # written as `rlang::.data$armies`, and reaching for the pronoun through
    # `::` returns the placeholder object rather than the one bound to the data
    # mask, which throws as soon as it is subset.
    output$hist <- shiny::renderPlot({
      s <- sim()
      shiny::req(s)
      breaks <- function(limits) {
        lo <- ceiling(min(limits))
        hi <- floor(max(limits))
        seq(lo, hi, by = max(1L, ceiling((hi - lo) / 8L)))
      }
      ggplot2::ggplot(s$survivors) +
        ggplot2::geom_bar(
          ggplot2::aes(x = armies, fill = side),
          position = "dodge", width = 0.85
        ) +
        ggplot2::scale_fill_manual(
          values = c(attacker = "#5E2C8E", defender = "#D55E00"), name = NULL
        ) +
        ggplot2::scale_x_continuous(breaks = breaks) +
        ggplot2::scale_y_continuous(
          expand = ggplot2::expansion(mult = c(0, 0.06))
        ) +
        ggplot2::labs(
          x = "armies left when the battle ends", y = "battles",
          title = sprintf(
            "%d attacking armies against %d defending", s$att, s$def
          ),
          subtitle = sprintf(
            "%s simulated battles; a defender on zero means the territory fell",
            format(s$n, big.mark = " ")
          )
        ) +
        rk_app_theme()
    }, res = RK_RES)

    output$path <- shiny::renderPlot({
      s <- sim()
      shiny::req(s)
      tryCatch(
        ggplot2::autoplot(s$example),
        error = function(e) NULL
      )
    }, res = RK_RES)
  })
}
