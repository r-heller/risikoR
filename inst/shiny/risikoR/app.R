# risikoR interactive app. Namespace-qualified throughout; no library() calls.
# Modules live in modules/ and are sourced into this environment.

for (.rk_file in list.files("modules", pattern = "[.][Rr]$", full.names = TRUE)) {
  source(.rk_file, local = TRUE)
}

ui <- bslib::page_navbar(
  title = shiny::tagList(
    shiny::img(
      src = "logo.png", height = "34px",
      alt = "risikoR logo", style = "margin-right: 10px;"
    ),
    "risikoR"
  ),
  theme = bslib::bs_theme(version = 5, primary = "#5E2C8E"),
  bslib::nav_panel("Play", mod_play_ui("play")),
  bslib::nav_panel("Duel analyser", mod_duel_ui("duel")),
  bslib::nav_panel("Battle simulator", mod_battle_ui("battle")),
  bslib::nav_panel("Strategy lab", mod_strategy_ui("strategy")),
  bslib::nav_spacer(),
  bslib::nav_item(
    shiny::tags$a(
      "Documentation",
      href = "https://r-heller.github.io/risikoR/", target = "_blank"
    )
  )
)

server <- function(input, output, session) {
  # Shared cross-tab state.
  state <- shiny::reactiveValues(
    game = risikoR::rk_game(c("Red", "Blue", "Green"), seed = 1),
    selected = NA_character_,
    pending = integer(0),
    message = "Click one of your territories to place reinforcements."
  )

  mod_play_server("play", state)
  mod_duel_server("duel")
  mod_battle_server("battle")
  mod_strategy_server("strategy", state)
}

shiny::shinyApp(ui, server)
