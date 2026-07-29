# Internal helpers shared across the package. Nothing here is exported.

# Validate a single whole number in [lo, hi] and return it as an integer.
.rk_check_count <- function(x, arg, lo, hi, call = rlang::caller_env()) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) || x != as.integer(x)) {
    cli::cli_abort(
      "{.arg {arg}} must be a single whole number.",
      call = call
    )
  }
  x <- as.integer(x)
  if (x < lo || x > hi) {
    cli::cli_abort(
      c(
        "{.arg {arg}} must be between {lo} and {hi}.",
        "x" = "Got {.val {x}}."
      ),
      call = call
    )
  }
  x
}

# Validate a single non-missing string.
.rk_check_string <- function(x, arg, call = rlang::caller_env()) {
  if (!is.character(x) || length(x) != 1L || is.na(x)) {
    cli::cli_abort(
      "{.arg {arg}} must be a single string.",
      call = call
    )
  }
  x
}

# Validate a character vector without missing values.
.rk_check_chr <- function(x, arg, call = rlang::caller_env()) {
  if (!is.character(x) || anyNA(x)) {
    cli::cli_abort(
      "{.arg {arg}} must be a character vector without missing values.",
      call = call
    )
  }
  x
}

.rk_check_game <- function(x, arg = "game", call = rlang::caller_env()) {
  if (!inherits(x, "rk_game")) {
    cli::cli_abort(
      "{.arg {arg}} must be an {.cls rk_game} object.",
      call = call
    )
  }
  invisible(x)
}

.rk_check_map <- function(x, arg = "map", call = rlang::caller_env()) {
  if (!inherits(x, "rk_map")) {
    cli::cli_abort(
      "{.arg {arg}} must be an {.cls rk_map} object.",
      call = call
    )
  }
  invisible(x)
}

# Validate that every element of `territory` exists on the map.
.rk_check_territory <- function(map, territory, arg, call = rlang::caller_env()) {
  territory <- .rk_check_chr(territory, arg, call = call)
  unknown <- setdiff(territory, map$territories)
  if (length(unknown) > 0L) {
    cli::cli_abort(
      c(
        "{.arg {arg}} must name territories on the map.",
        "x" = "Unknown territor{?y/ies}: {.val {unknown}}."
      ),
      call = call
    )
  }
  territory
}

# Validate that `player` is a single name on the roster.
.rk_check_player <- function(game, player, arg = "player",
                             call = rlang::caller_env()) {
  player <- .rk_check_string(player, arg, call = call)
  if (!player %in% game$players) {
    cli::cli_abort(
      c(
        "{.arg {arg}} must be one of the players in the game.",
        "x" = "{.val {player}} is not playing.",
        "i" = "Players: {.val {game$players}}."
      ),
      call = call
    )
  }
  player
}

# Abort unless the game is in one of `phases`.
.rk_check_phase <- function(game, phases, call = rlang::caller_env()) {
  if (!game$phase %in% phases) {
    cli::cli_abort(
      c(
        "This action needs the {.val {phases}} phase.",
        "x" = "The game is in the {.val {game$phase}} phase."
      ),
      call = call
    )
  }
  invisible(game)
}

# Colour-blind safe qualitative palette (Okabe-Ito), recycled if needed.
.rk_palette <- function(n) {
  base <- c(
    "#0072B2", "#D55E00", "#009E73", "#CC79A7",
    "#E69F00", "#56B4E9", "#F0E442", "#999999"
  )
  rep(base, length.out = n)
}

# Fixed continent colours, also Okabe-Ito derived.
.rk_continent_colours <- function() {
  c(
    North_America = "#0072B2",
    South_America = "#009E73",
    Europe = "#CC79A7",
    Africa = "#E69F00",
    Asia = "#D55E00",
    Australia = "#56B4E9"
  )
}

# The suite accent colour.
.rk_accent <- function() "#5E2C8E"

# Undirected edge table for a map, joined to the layout coordinates.
.rk_edges <- function(map) {
  from <- rep(names(map$adjacency), lengths(map$adjacency))
  to <- unlist(map$adjacency, use.names = FALSE)
  keep <- from < to
  from <- from[keep]
  to <- to[keep]
  lay <- map$layout
  i <- match(from, lay$territory)
  j <- match(to, lay$territory)
  tibble::tibble(
    from = from,
    to = to,
    x = lay$x[i],
    y = lay$y[i],
    xend = lay$x[j],
    yend = lay$y[j]
  )
}

# Territory -> continent lookup as a named character vector.
.rk_territory_continent <- function(map) {
  out <- rep(names(map$continent), lengths(map$continent))
  names(out) <- unlist(map$continent, use.names = FALSE)
  out
}
