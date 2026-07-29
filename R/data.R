#' The classic Risk world board
#'
#' The standard 42-territory, 6-continent Risk board: which territories exist,
#' which of them border one another, how they group into continents, the bonus
#' armies each continent is worth, and static coordinates for drawing the
#' board. [rk_world()] wraps this dataset into an `rk_map` object.
#'
#' @format A list with five elements:
#' \describe{
#'   \item{`territories`}{Character vector of the 42 territory names, in board
#'     order (North America, South America, Europe, Africa, Asia, Australia).}
#'   \item{`adjacency`}{Named list with one element per territory, each a
#'     character vector of the territories it borders. The graph is symmetric
#'     and no territory borders itself.}
#'   \item{`continent`}{Named list with one element per continent, each a
#'     character vector of its territories. Every territory belongs to exactly
#'     one continent.}
#'   \item{`continent_bonus`}{Named integer vector of the extra armies a player
#'     receives for holding each continent: North America 5, South America 2,
#'     Europe 5, Africa 3, Asia 7, Australia 2.}
#'   \item{`layout`}{A [tibble::tibble()] with 42 rows and columns `territory`
#'     (character), `x` and `y` (double plotting coordinates on a 0-100
#'     canvas) and `continent` (character).}
#' }
#'
#' @source The territory, adjacency and continent structure of the standard
#'   Risk board; assembled by `data-raw/make_map.R`. The plotting coordinates
#'   are a schematic layout, not a geographic projection.
#'
#' @family map
#'
#' @examples
#' risk_map$continent_bonus
#' risk_map$adjacency$Brazil
"risk_map"
