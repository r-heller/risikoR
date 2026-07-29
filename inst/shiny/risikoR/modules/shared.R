# Pieces every tab shares: the panel shell, status pills, table formatting and
# aspect-locked plot containers. Namespace-qualified throughout; no library()
# calls, and nothing here reaches into the package's internals.

# A titled card. Everything on a tab lives in one of these rather than floating
# on the page under a bare heading.
rk_panel <- function(title, ..., note = NULL) {
  shiny::div(
    class = "rk-panel",
    shiny::div(
      class = "rk-panel-head",
      shiny::span(class = "rk-panel-title", title),
      if (!is.null(note)) shiny::span(class = "rk-panel-note", note)
    ),
    shiny::div(class = "rk-panel-body", ...)
  )
}

# Sidebar section label.
rk_group <- function(label) shiny::div(class = "rk-group", label)

rk_hint <- function(...) shiny::p(class = "rk-hint", ...)

# Plots are designed for a canvas of a given size in millimetres. Cap the
# container width and pick the pixel height to match, so the plot arrives at the
# aspect ratio it was drawn for instead of being letterboxed across a wide
# panel. `res` is chosen so that a pixel of the output is the same physical size
# the plot was designed at: width_px / res inches should equal width_mm / 25.4.
# Bigger than the 72 dpi Shiny defaults to, so a plot designed at 186 mm arrives
# as roughly 900 screen pixels with text at a comfortable on-screen size, while
# keeping the same physical geometry the print renders were tuned on.
RK_RES <- 124L

rk_figure <- function(output, width_mm, height_mm) {
  width_px <- round(width_mm / 25.4 * RK_RES)
  height_px <- round(height_mm / 25.4 * RK_RES)
  shiny::div(
    class = "rk-figure",
    style = sprintf("max-width: %dpx;", width_px),
    shiny::plotOutput(output, height = paste0(height_px, "px"))
  )
}

# The clickable map needs its click coordinates, so it cannot go through
# rk_figure()'s plain plotOutput.
rk_map_figure <- function(output, click, width_mm, height_mm) {
  width_px <- round(width_mm / 25.4 * RK_RES)
  height_px <- round(height_mm / 25.4 * RK_RES)
  shiny::div(
    class = "rk-figure",
    style = sprintf("max-width: %dpx;", width_px),
    shiny::plotOutput(output, click = click, height = paste0(height_px, "px"))
  )
}

# One status pill: a small caps label and a value.
rk_pill <- function(label, value, tone = NULL, colour = NULL) {
  shiny::span(
    class = paste(c("rk-pill", tone), collapse = " "),
    if (!is.null(colour)) {
      shiny::span(
        class = "rk-swatch",
        style = sprintf("background: %s;", colour)
      )
    },
    shiny::span(class = "rk-pill-label", label),
    shiny::span(class = "rk-pill-value", value)
  )
}

rk_status <- function(...) shiny::div(class = "rk-status", ...)

# The player colours the map uses, so a pill or a table row can carry the same
# colour as the territory it describes. Mirrors the package's own mapping.
RK_PLAYER_COLOURS <- c(
  Red = "#D55E00", Blue = "#0072B2", Green = "#009E73", Yellow = "#F0E442",
  Orange = "#E69F00", Pink = "#CC79A7", Purple = "#5E2C8E", Cyan = "#56B4E9"
)

rk_player_colour <- function(player) {
  hit <- RK_PLAYER_COLOURS[player]
  ifelse(is.na(hit), "#7A7A7A", hit)
}

# Render a data frame as a plain HTML table with human column names and columns
# formatted per type. `renderTable()` on a raw result gives `p_att_wins_all` and
# `0.400`, which is a debugging dump, not a readable table.
rk_table <- function(data, labels = NULL, percent = character(0),
                     percent_digits = 0L, digits = c(),
                     first_is_player = FALSE) {
  data <- as.data.frame(data)
  if (nrow(data) == 0L) {
    return(shiny::p(class = "rk-hint", "Nothing to show yet."))
  }
  cells <- lapply(names(data), function(nm) {
    col <- data[[nm]]
    if (nm %in% percent) {
      return(paste0(
        formatC(100 * col, format = "f", digits = percent_digits), "%"
      ))
    }
    if (nm %in% names(digits)) {
      return(formatC(col, format = "f", digits = digits[[nm]]))
    }
    if (is.numeric(col) && all(col == round(col), na.rm = TRUE)) {
      return(ifelse(is.na(col), "—", formatC(col, format = "d",
                                                  big.mark = " ")))
    }
    if (is.numeric(col)) {
      return(ifelse(is.na(col), "—", formatC(col, format = "f",
                                                  digits = 3L)))
    }
    ifelse(is.na(col), "—", as.character(col))
  })
  names(cells) <- names(data)
  head <- vapply(names(data), function(nm) {
    if (!is.null(labels) && nm %in% names(labels)) labels[[nm]] else nm
  }, character(1L))

  body <- lapply(seq_len(nrow(data)), function(i) {
    shiny::tags$tr(lapply(seq_along(cells), function(j) {
      value <- cells[[j]][[i]]
      if (j == 1L && first_is_player) {
        shiny::tags$td(shiny::span(
          class = "rk-player",
          shiny::span(
            class = "rk-swatch",
            style = sprintf("background: %s;", rk_player_colour(value))
          ),
          value
        ))
      } else {
        shiny::tags$td(value)
      }
    }))
  })
  shiny::tags$table(
    shiny::tags$thead(shiny::tags$tr(lapply(head, shiny::tags$th))),
    shiny::tags$tbody(body)
  )
}

# The app draws one plot the package does not export -- the distribution of
# surviving armies. Keep it in the suite's clothes rather than dropping a
# default-grey ggplot into the middle of the tab.
rk_app_theme <- function(base_size = 11) {
  ink <- "#1B1B1F"
  mid <- "#5A5F66"
  soft <- "#8A9099"
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(
        face = "bold", size = ggplot2::rel(1.15), colour = ink,
        margin = ggplot2::margin(b = 3)
      ),
      plot.subtitle = ggplot2::element_text(
        size = ggplot2::rel(0.92), colour = mid,
        margin = ggplot2::margin(b = 12)
      ),
      plot.caption = ggplot2::element_text(
        size = ggplot2::rel(0.72), colour = soft, hjust = 0,
        margin = ggplot2::margin(t = 12)
      ),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      plot.margin = ggplot2::margin(14, 16, 12, 14),
      axis.title = ggplot2::element_text(size = ggplot2::rel(0.88), colour = mid),
      axis.text = ggplot2::element_text(size = ggplot2::rel(0.82), colour = mid),
      panel.grid.major = ggplot2::element_line(colour = "#E3E5E9",
                                               linewidth = 0.3),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank(),
      legend.position = "bottom",
      legend.justification = "left",
      legend.text = ggplot2::element_text(size = ggplot2::rel(0.82)),
      legend.key.size = grid::unit(9, "pt")
    )
}
