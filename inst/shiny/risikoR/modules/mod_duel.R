# Duel analyser tab: exact odds for a single throw of the dice.

mod_duel_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      width = 300,
      shiny::sliderInput(ns("n_att"), "Attacker dice", 1, 3, 3, step = 1),
      shiny::sliderInput(ns("n_def"), "Defender dice", 1, 2, 2, step = 1),
      shiny::checkboxInput(ns("old_rules"), "Allow three defender dice", FALSE),
      shiny::helpText(
        "Ties go to the defender: the attacker must roll strictly higher."
      )
    ),
    plotly::plotlyOutput(ns("plot"), height = "380px"),
    shiny::h5("Exact outcome distribution"),
    shiny::tableOutput(ns("dist")),
    shiny::h5("Summary"),
    shiny::tableOutput(ns("odds"))
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

    output$plot <- plotly::renderPlotly({
      d <- dice()
      shiny::req(d)
      plotly::ggplotly(
        risikoR::rk_plot_duel(d$n_att, d$n_def, max_def = d$max_def)
      )
    })

    output$dist <- shiny::renderTable({
      d <- dice()
      shiny::req(d)
      tryCatch(
        risikoR::rk_duel_dist(d$n_att, d$n_def, max_def = d$max_def),
        error = function(e) NULL
      )
    }, digits = 4)

    output$odds <- shiny::renderTable({
      d <- dice()
      shiny::req(d)
      tryCatch(
        risikoR::rk_duel_odds(d$n_att, d$n_def, max_def = d$max_def),
        error = function(e) NULL
      )
    }, digits = 4)
  })
}
