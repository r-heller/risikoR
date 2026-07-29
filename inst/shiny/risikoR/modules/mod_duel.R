# Duel analyser tab: exact odds for a single throw of the dice.

mod_duel_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      width = 288,
      rk_group("The throw"),
      shiny::sliderInput(ns("n_att"), "Attacker dice", 1, 3, 3, step = 1),
      shiny::sliderInput(ns("n_def"), "Defender dice", 1, 2, 2, step = 1),
      rk_group("House rule"),
      shiny::checkboxInput(ns("old_rules"), "Allow three defender dice", FALSE),
      rk_hint(
        "Ties go to the defender: the attacker has to roll strictly higher. ",
        "The highest die of each side is compared with the other's highest, ",
        "the second with the second, and so on."
      )
    ),
    shiny::uiOutput(ns("status")),
    rk_panel(
      "One exchange",
      note = "Exact distribution, not a simulation",
      rk_figure(ns("plot"), width_mm = 186, height_mm = 124)
    ),
    bslib::layout_columns(
      col_widths = c(6, 6),
      rk_panel("Every outcome", shiny::uiOutput(ns("dist"))),
      rk_panel("Summary", shiny::uiOutput(ns("odds")))
    )
  )
}

mod_duel_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    max_def <- shiny::reactive({
      if (isTRUE(input$old_rules)) 3L else 2L
    })

    shiny::observeEvent(input$old_rules, {
      shiny::updateSliderInput(
        session, "n_def",
        max = max_def(), value = min(input$n_def, max_def())
      )
    })

    dice <- shiny::reactive({
      shiny::req(input$n_att, input$n_def)
      list(
        n_att = as.integer(input$n_att),
        n_def = min(as.integer(input$n_def), max_def()),
        max_def = max_def()
      )
    })

    odds <- shiny::reactive({
      d <- dice()
      shiny::req(d)
      tryCatch(
        risikoR::rk_duel_odds(d$n_att, d$n_def, max_def = d$max_def),
        error = function(e) NULL
      )
    })

    output$status <- shiny::renderUI({
      o <- odds()
      shiny::req(o)
      rk_status(
        rk_pill("dice", sprintf("%d v %d", o$n_att, o$n_def),
                tone = "rk-accent"),
        rk_pill("attacker loses", sprintf("%.4f", o$e_att_loss)),
        rk_pill("defender loses", sprintf("%.4f", o$e_def_loss)),
        rk_pill(
          "attacker takes all",
          paste0(formatC(100 * o$p_att_wins_all, format = "f", digits = 1L), "%")
        )
      )
    })

    # A static plot, not a plotly widget: converting this one dropped the
    # subtitle and the caption, shifted every bar label off its bar and laid a
    # twelve-button modebar over the title.
    output$plot <- shiny::renderPlot({
      d <- dice()
      shiny::req(d)
      risikoR::rk_plot_duel(d$n_att, d$n_def, max_def = d$max_def)
    }, res = RK_RES)

    output$dist <- shiny::renderUI({
      d <- dice()
      shiny::req(d)
      dist <- tryCatch(
        risikoR::rk_duel_dist(d$n_att, d$n_def, max_def = d$max_def),
        error = function(e) NULL
      )
      shiny::req(dist)
      dist <- as.data.frame(dist)[, c("att_loss", "def_loss", "p")]
      rk_table(
        dist,
        labels = c(att_loss = "attacker loses", def_loss = "defender loses",
                   p = "probability"),
        digits = c(p = 4L)
      )
    })

    output$odds <- shiny::renderUI({
      o <- odds()
      shiny::req(o)
      pct <- function(x) {
        paste0(formatC(100 * x, format = "f", digits = 1L), "%")
      }
      out <- data.frame(
        quantity = c(
          "Expected attacker losses", "Expected defender losses",
          "Standard deviation", "Attacker takes every die",
          "Defender takes every die", "Losses split"
        ),
        value = c(
          sprintf("%.4f", o$e_att_loss), sprintf("%.4f", o$e_def_loss),
          sprintf("%.4f", o$sd_loss), pct(o$p_att_wins_all),
          pct(o$p_def_wins_all), pct(o$p_split)
        )
      )
      rk_table(out, labels = c(quantity = "", value = "value"))
    })
  })
}
