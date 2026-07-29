#' The classic Risk world map
#'
#' Returns the standard 42-territory, 6-continent Risk map as an `rk_map`
#' object, built from the packaged [risk_map] dataset.
#'
#' @return An S3 object of class `rk_map`; see [rk_map()] for the structure.
#' @export
#' @family map
#'
#' @examples
#' m <- rk_world()
#' m$continent_bonus
#' rk_neighbors(m, "Brazil")
rk_world <- function() {
  structure(risk_map, class = "rk_map")
}

#' Build a Risk map
#'
#' Constructs an `rk_map` from a territory list, an adjacency graph and a
#' continent partition. Use it to play on a custom board; the classic world
#' board is available from [rk_world()].
#'
#' @param territories Character vector of unique territory names.
#' @param adjacency Named list, one element per territory, giving the names of
#'   its neighbours. The graph must be symmetric (if `a` neighbours `b`, then
#'   `b` neighbours `a`) and no territory may neighbour itself.
#' @param continent Named list, one element per continent, giving the
#'   territories it contains. Every territory must belong to exactly one
#'   continent.
#' @param continent_bonus Named numeric vector of bonus armies per continent,
#'   with one entry per element of `continent`.
#' @param layout Optional [tibble::tibble()] of plotting coordinates with
#'   columns `territory`, `x` and `y`. When omitted, territories are arranged
#'   on a circle grouped by continent.
#'
#' @return An S3 object of class `rk_map`: a list with elements `territories`
#'   (character), `adjacency` (named list), `continent` (named list),
#'   `continent_bonus` (named integer) and `layout` (a tibble with columns
#'   `territory`, `x`, `y` and `continent`).
#' @export
#' @family map
#'
#' @examples
#' m <- rk_map(
#'   territories = c("North", "South", "East"),
#'   adjacency = list(
#'     North = c("South", "East"),
#'     South = c("North", "East"),
#'     East = c("North", "South")
#'   ),
#'   continent = list(Land = c("North", "South", "East")),
#'   continent_bonus = c(Land = 2)
#' )
#' m
rk_map <- function(territories, adjacency, continent, continent_bonus,
                   layout = NULL) {
  territories <- .rk_check_chr(territories, "territories")
  if (length(territories) < 2L) {
    cli::cli_abort("{.arg territories} must name at least two territories.")
  }
  if (anyDuplicated(territories) > 0L) {
    dups <- unique(territories[duplicated(territories)])
    cli::cli_abort(c(
      "{.arg territories} must be unique.",
      "x" = "Duplicated: {.val {dups}}."
    ))
  }
  if (!is.list(adjacency) || !setequal(names(adjacency), territories)) {
    cli::cli_abort(
      "{.arg adjacency} must be a named list with one element per territory."
    )
  }
  adjacency <- adjacency[territories]
  for (a in territories) {
    nb <- .rk_check_chr(adjacency[[a]], "adjacency")
    if (a %in% nb) {
      cli::cli_abort("A territory cannot neighbour itself ({.val {a}}).")
    }
    unknown <- setdiff(nb, territories)
    if (length(unknown) > 0L) {
      cli::cli_abort(c(
        "{.arg adjacency} refers to unknown territories.",
        "x" = "{.val {a}} lists {.val {unknown}}."
      ))
    }
    asym <- nb[!vapply(nb, function(b) a %in% adjacency[[b]], logical(1L))]
    if (length(asym) > 0L) {
      cli::cli_abort(c(
        "{.arg adjacency} must be symmetric.",
        "x" = "{.val {a}} neighbours {.val {asym}}, but not the other way round."
      ))
    }
  }
  if (!is.list(continent) || is.null(names(continent))) {
    cli::cli_abort("{.arg continent} must be a named list of territories.")
  }
  members <- unlist(continent, use.names = FALSE)
  if (!setequal(members, territories) || anyDuplicated(members) > 0L) {
    cli::cli_abort(
      "{.arg continent} must assign every territory to exactly one continent."
    )
  }
  if (!is.numeric(continent_bonus) ||
      !setequal(names(continent_bonus), names(continent))) {
    cli::cli_abort(
      "{.arg continent_bonus} must be a named numeric vector, one per continent."
    )
  }
  continent_bonus <- as.integer(continent_bonus)[
    match(names(continent), names(continent_bonus))
  ]
  names(continent_bonus) <- names(continent)

  map <- list(
    territories = territories,
    adjacency = adjacency,
    continent = continent,
    continent_bonus = continent_bonus,
    layout = tibble::tibble(
      territory = character(0), x = numeric(0), y = numeric(0),
      continent = character(0)
    )
  )
  map$layout <- .rk_layout(map, layout)
  structure(map, class = "rk_map")
}

#' Neighbouring territories
#'
#' Returns the territories adjacent to `territory`.
#'
#' @param x An `rk_map` or an `rk_game`.
#' @param territory A single territory name.
#'
#' @return A character vector of neighbouring territory names, in map order.
#' @export
#' @family map
#'
#' @examples
#' rk_neighbors(rk_world(), "Egypt")
rk_neighbors <- function(x, territory) {
  map <- .rk_as_map(x)
  territory <- .rk_check_string(territory, "territory")
  territory <- .rk_check_territory(map, territory, "territory")
  as.character(map$adjacency[[territory]])
}

#' @export
format.rk_map <- function(x, ...) {
  rlang::check_dots_empty()
  bonus <- paste0(names(x$continent_bonus), " +", x$continent_bonus)
  c(
    cli::format_inline(
      "<rk_map> {length(x$territories)} territories, ",
      "{length(x$continent)} continent{?s}"
    ),
    cli::format_inline("Bonuses: {bonus}")
  )
}

#' @export
print.rk_map <- function(x, ...) {
  rlang::check_dots_empty()
  cli::cat_line(format(x))
  invisible(x)
}

# --- internal helpers -------------------------------------------------------

.rk_as_map <- function(x, call = rlang::caller_env()) {
  if (inherits(x, "rk_game")) {
    return(x$map)
  }
  if (inherits(x, "rk_map")) {
    return(x)
  }
  cli::cli_abort(
    "{.arg x} must be an {.cls rk_map} or an {.cls rk_game} object.",
    call = call
  )
}

# Validate a supplied layout, or lay the board out on a circle by continent.
.rk_layout <- function(map, layout, call = rlang::caller_env()) {
  terr_cont <- .rk_territory_continent(map)
  if (is.null(layout)) {
    ord <- order(match(terr_cont[map$territories], names(map$continent)))
    ordered <- map$territories[ord]
    n <- length(ordered)
    angle <- 2 * pi * (seq_len(n) - 1L) / n
    out <- tibble::tibble(
      territory = ordered,
      x = 50 + 40 * cos(angle),
      y = 50 + 40 * sin(angle),
      continent = unname(terr_cont[ordered])
    )
    return(out[match(map$territories, out$territory), ])
  }
  if (!is.data.frame(layout) ||
      !all(c("territory", "x", "y") %in% names(layout))) {
    cli::cli_abort(
      "{.arg layout} must be a data frame with columns {.field territory},
       {.field x} and {.field y}.",
      call = call
    )
  }
  if (!setequal(layout$territory, map$territories)) {
    cli::cli_abort(
      "{.arg layout} must contain one row per territory.",
      call = call
    )
  }
  out <- tibble::tibble(
    territory = as.character(layout$territory),
    x = as.numeric(layout$x),
    y = as.numeric(layout$y),
    continent = unname(terr_cont[as.character(layout$territory)])
  )
  out[match(map$territories, out$territory), ]
}
