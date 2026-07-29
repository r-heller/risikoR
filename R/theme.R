# The look of the suite: one theme, one palette, one set of typographic
# choices, so that every plot the package draws reads as part of the same
# family. Nothing here is exported.

# Ink colours, kept in one place.
.rk_ink_dark <- function() "#1B1B1F"
.rk_ink_mid <- function() "#5A5F66"
.rk_ink_soft <- function() "#8A9099"
.rk_rule <- function() "#E3E5E9"
.rk_ocean <- function() "#EDF2F6"
.rk_shore <- function() "#7E96AA"

# The shared ggplot2 theme.
.rk_theme <- function(base_size = 11, grid = c("xy", "x", "y", "none")) {
  grid <- match.arg(grid)
  out <- ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(
        face = "bold", size = ggplot2::rel(1.15), colour = .rk_ink_dark(),
        margin = ggplot2::margin(b = 3)
      ),
      plot.subtitle = ggplot2::element_text(
        size = ggplot2::rel(0.92), colour = .rk_ink_mid(),
        margin = ggplot2::margin(b = 12)
      ),
      plot.caption = ggplot2::element_text(
        size = ggplot2::rel(0.72), colour = .rk_ink_soft(), hjust = 0,
        margin = ggplot2::margin(t = 12)
      ),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      plot.margin = ggplot2::margin(14, 16, 12, 14),
      axis.title = ggplot2::element_text(
        size = ggplot2::rel(0.88), colour = .rk_ink_mid()
      ),
      axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 7)),
      axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 7)),
      axis.text = ggplot2::element_text(
        size = ggplot2::rel(0.82), colour = .rk_ink_mid()
      ),
      panel.grid.major = ggplot2::element_line(
        colour = .rk_rule(), linewidth = 0.3
      ),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "bottom",
      legend.justification = "left",
      legend.title = ggplot2::element_text(
        size = ggplot2::rel(0.82), colour = .rk_ink_mid()
      ),
      legend.text = ggplot2::element_text(size = ggplot2::rel(0.82)),
      legend.key.size = grid::unit(9, "pt"),
      legend.margin = ggplot2::margin(t = 2),
      strip.text = ggplot2::element_text(
        face = "bold", size = ggplot2::rel(0.85), colour = .rk_ink_mid(),
        margin = ggplot2::margin(b = 4)
      )
    )
  drop <- switch(
    grid,
    xy = NULL,
    x = ggplot2::theme(panel.grid.major.y = ggplot2::element_blank()),
    y = ggplot2::theme(panel.grid.major.x = ggplot2::element_blank()),
    none = ggplot2::theme(
      panel.grid = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank()
    )
  )
  if (is.null(drop)) out else out + drop
}

# The map gets no axes at all, and an ocean for a panel.
.rk_theme_map <- function(base_size = 11) {
  .rk_theme(base_size, grid = "none") +
    ggplot2::theme(
      axis.text = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      panel.background = ggplot2::element_rect(
        fill = .rk_ocean(), colour = NA
      ),
      panel.border = ggplot2::element_rect(
        fill = NA, colour = .rk_rule(), linewidth = 0.6
      ),
      plot.margin = ggplot2::margin(14, 14, 10, 14),
      legend.key.size = grid::unit(11, "pt")
    )
}

# Multiply a colour towards black (k < 1) or towards white (k > 1).
.rk_shade <- function(colour, k = 0.7) {
  rgb <- grDevices::col2rgb(colour)
  rgb[] <- if (k <= 1) rgb * k else 255 - (255 - rgb) * (2 - k)
  rgb[] <- pmin(255, pmax(0, rgb))
  out <- grDevices::rgb(rgb[1L, ], rgb[2L, ], rgb[3L, ], maxColorValue = 255)
  stats::setNames(out, names(colour))
}

# Text that stays readable on a given fill.
.rk_contrast <- function(fill, dark = .rk_ink_dark(), light = "#FFFFFF") {
  rgb <- grDevices::col2rgb(fill) / 255
  lin <- ifelse(rgb <= 0.04045, rgb / 12.92, ((rgb + 0.055) / 1.055)^2.4)
  lum <- 0.2126 * lin[1, ] + 0.7152 * lin[2, ] + 0.0722 * lin[3, ]
  ifelse(lum > 0.42, dark, light)
}

# Territory names are stored with underscores; show them with spaces, and
# break the longer ones over two lines so they fit inside their territory.
.rk_label <- function(x) gsub("_", " ", x)

.rk_wrap <- function(x, width = 11L) {
  out <- x
  long <- nchar(gsub("_", " ", x)) > width & grepl("_", x)
  out[long] <- sub("_", "\n", x[long], fixed = TRUE)
  gsub("_", " ", out)
}

# Percent-style probability labels without a trailing zero forest.
.rk_pct <- function(x, digits = 0L) {
  paste0(formatC(100 * x, format = "f", digits = digits), "%")
}

# ggplot2 does not wrap a caption, it just lets it run off the device. Break the
# longer ones ourselves so they survive a smaller canvas.
.rk_caption <- function(x, width = 88L) {
  paste(strwrap(x, width = width), collapse = "\n")
}

# Text with a halo: the same label drawn in the background colour at eight small
# offsets, then once in ink on top. Used where a label has to stay legible over
# the ocean, a coastline and a sea route all at once.
.rk_halo <- function(data, mapping, size, colour, halo = "#FFFFFF",
                     width = 0.085, ...) {
  angles <- seq(0, 2 * pi, length.out = 9L)[-9L]
  ring <- lapply(angles, function(a) {
    ggplot2::geom_text(
      data = data, mapping = mapping, size = size, colour = halo,
      position = ggplot2::position_nudge(
        x = width * size * cos(a), y = width * size * sin(a)
      ),
      show.legend = FALSE, ...
    )
  })
  c(ring, list(ggplot2::geom_text(
    data = data, mapping = mapping, size = size, colour = colour,
    show.legend = FALSE, ...
  )))
}

# Shrink a label until it fits the width it has to live in. `span` is the width
# of the territory in data units; the reference is the typical territory holding
# a typical name, so a long name in a small territory comes down and everything
# else is left alone.
.rk_fit_size <- function(label, span, size, floor = 0.66) {
  chars <- vapply(
    strsplit(label, "\n", fixed = TRUE),
    function(z) max(nchar(z)), integer(1L)
  )
  room <- span / pmax(1L, chars)
  ref <- stats::median(room, na.rm = TRUE)
  if (!is.finite(ref) || ref <= 0) {
    return(rep(size, length(room)))
  }
  pmax(floor * size, pmin(size, size * sqrt(room / ref)))
}
