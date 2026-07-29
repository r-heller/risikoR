## Assemble the classic 42-territory Risk world map -> data/risk_map.rda
## Run with: source("data-raw/make_map.R")

adjacency <- list(
  # North America
  Alaska = c("Northwest_Territory", "Alberta", "Kamchatka"),
  Northwest_Territory = c("Alaska", "Alberta", "Ontario", "Greenland"),
  Greenland = c("Northwest_Territory", "Ontario", "Quebec", "Iceland"),
  Alberta = c("Alaska", "Northwest_Territory", "Ontario", "Western_US"),
  Ontario = c("Alberta", "Northwest_Territory", "Greenland", "Quebec",
              "Western_US", "Eastern_US"),
  Quebec = c("Ontario", "Greenland", "Eastern_US"),
  Western_US = c("Alberta", "Ontario", "Eastern_US", "Central_America"),
  Eastern_US = c("Western_US", "Ontario", "Quebec", "Central_America"),
  Central_America = c("Western_US", "Eastern_US", "Venezuela"),
  # South America
  Venezuela = c("Central_America", "Peru", "Brazil"),
  Peru = c("Venezuela", "Brazil", "Argentina"),
  Brazil = c("Venezuela", "Peru", "Argentina", "North_Africa"),
  Argentina = c("Peru", "Brazil"),
  # Europe
  Iceland = c("Greenland", "Scandinavia", "Great_Britain"),
  Great_Britain = c("Iceland", "Scandinavia", "Northern_Europe", "Western_Europe"),
  Scandinavia = c("Iceland", "Great_Britain", "Northern_Europe", "Ukraine"),
  Northern_Europe = c("Great_Britain", "Scandinavia", "Ukraine",
                      "Southern_Europe", "Western_Europe"),
  Western_Europe = c("Great_Britain", "Northern_Europe", "Southern_Europe",
                     "North_Africa"),
  Southern_Europe = c("Western_Europe", "Northern_Europe", "Ukraine",
                      "North_Africa", "Egypt", "Middle_East"),
  Ukraine = c("Scandinavia", "Northern_Europe", "Southern_Europe",
              "Ural", "Afghanistan", "Middle_East"),
  # Africa
  North_Africa = c("Brazil", "Western_Europe", "Southern_Europe", "Egypt",
                   "East_Africa", "Congo"),
  Egypt = c("North_Africa", "Southern_Europe", "Middle_East", "East_Africa"),
  East_Africa = c("North_Africa", "Egypt", "Middle_East", "Congo",
                  "South_Africa", "Madagascar"),
  Congo = c("North_Africa", "East_Africa", "South_Africa"),
  South_Africa = c("Congo", "East_Africa", "Madagascar"),
  Madagascar = c("East_Africa", "South_Africa"),
  # Asia
  Ural = c("Ukraine", "Siberia", "China", "Afghanistan"),
  Siberia = c("Ural", "Yakutsk", "Irkutsk", "Mongolia", "China"),
  Yakutsk = c("Siberia", "Irkutsk", "Kamchatka"),
  Kamchatka = c("Yakutsk", "Irkutsk", "Mongolia", "Japan", "Alaska"),
  Irkutsk = c("Siberia", "Yakutsk", "Kamchatka", "Mongolia"),
  Mongolia = c("Siberia", "Irkutsk", "Kamchatka", "Japan", "China"),
  Japan = c("Kamchatka", "Mongolia"),
  Afghanistan = c("Ukraine", "Ural", "China", "India", "Middle_East"),
  China = c("Ural", "Siberia", "Mongolia", "Afghanistan", "India", "Siam"),
  Middle_East = c("Southern_Europe", "Ukraine", "Afghanistan", "India",
                  "Egypt", "East_Africa"),
  India = c("Afghanistan", "China", "Middle_East", "Siam"),
  Siam = c("India", "China", "Indonesia"),
  # Australia
  Indonesia = c("Siam", "New_Guinea", "Western_Australia"),
  New_Guinea = c("Indonesia", "Western_Australia", "Eastern_Australia"),
  Western_Australia = c("Indonesia", "New_Guinea", "Eastern_Australia"),
  Eastern_Australia = c("Western_Australia", "New_Guinea")
)

continent <- list(
  North_America = c("Alaska", "Northwest_Territory", "Greenland", "Alberta",
                    "Ontario", "Quebec", "Western_US", "Eastern_US",
                    "Central_America"),
  South_America = c("Venezuela", "Peru", "Brazil", "Argentina"),
  Europe = c("Iceland", "Great_Britain", "Scandinavia", "Northern_Europe",
             "Western_Europe", "Southern_Europe", "Ukraine"),
  Africa = c("North_Africa", "Egypt", "East_Africa", "Congo", "South_Africa",
             "Madagascar"),
  Asia = c("Ural", "Siberia", "Yakutsk", "Kamchatka", "Irkutsk", "Mongolia",
           "Japan", "Afghanistan", "China", "Middle_East", "India", "Siam"),
  Australia = c("Indonesia", "New_Guinea", "Western_Australia",
                "Eastern_Australia")
)

continent_bonus <- c(North_America = 5L, South_America = 2L, Europe = 5L,
                     Africa = 3L, Asia = 7L, Australia = 2L)

## Static 2-D board coordinates for plotting. The layout is a stylised
## equirectangular view of the board on a 0-100 canvas: schematic rather than
## geographically exact.
##
## It is not free-hand, though. `rk_plot_map()` draws each territory as a
## cluster of hexagons claimed by the nearest territory centre, so the layout
## decides which territories end up sharing a border -- and therefore whether
## the picture agrees with `adjacency`. Hand-placed coordinates did not: the
## board drew seven borders between territories that are not neighbours
## (Quebec-Great Britain, Ural-Irkutsk, Irkutsk-Japan and friends) and left ten
## real adjacencies with nothing joining them.
##
## These coordinates come from a spring relaxation of the old schematic:
## neighbours pulled towards a target distance, non-neighbours pushed apart,
## and a weak anchor to the hand-drawn positions so the world stays
## recognisable. `Alaska - Kamchatka` is excluded -- it wraps around the far
## side of the globe and cannot be a shared border on a flat board, so the plot
## draws it as a route.
coords <- rbind(
  # North America
  c("Alaska",                4.0, 61.3),
  c("Northwest_Territory",  14.6, 60.4),
  c("Greenland",            26.1, 58.5),
  c("Alberta",               8.2, 52.1),
  c("Ontario",              18.0, 50.4),
  c("Quebec",               26.4, 47.7),
  c("Western_US",           10.6, 41.8),
  c("Eastern_US",           21.0, 40.2),
  c("Central_America",      15.4, 31.9),
  # South America
  c("Venezuela",            21.6, 22.4),
  c("Peru",                 22.1, 12.4),
  c("Brazil",               31.6, 17.8),
  c("Argentina",            29.2,  5.9),
  # Europe
  c("Iceland",              39.0, 59.4),
  c("Great_Britain",        41.5, 49.2),
  c("Scandinavia",          49.9, 54.7),
  c("Northern_Europe",      48.7, 44.6),
  c("Western_Europe",       41.7, 37.0),
  c("Southern_Europe",      51.5, 34.9),
  c("Ukraine",              58.4, 45.5),
  # Africa
  c("North_Africa",         45.0, 23.9),
  c("Egypt",                55.9, 26.2),
  c("East_Africa",          55.1, 16.2),
  c("Congo",                46.7, 11.8),
  c("South_Africa",         54.1,  5.2),
  c("Madagascar",           63.6,  8.4),
  # Asia
  c("Ural",                 68.3, 51.5),
  c("Siberia",              77.3, 56.0),
  c("Yakutsk",              85.2, 64.3),
  c("Kamchatka",            94.2, 56.7),
  c("Irkutsk",              85.2, 56.9),
  c("Mongolia",             86.2, 48.6),
  c("Japan",                96.0, 45.4),
  c("Afghanistan",          67.8, 42.1),
  c("China",                77.6, 43.1),
  c("Middle_East",          62.3, 34.1),
  c("India",                72.9, 33.7),
  c("Siam",                 82.3, 31.0),
  # Australia
  c("Indonesia",            83.8, 19.0),
  c("New_Guinea",           93.0, 14.3),
  c("Western_Australia",    84.9,  7.9),
  c("Eastern_Australia",    94.5,  4.0)
)

## Links the plot draws as routes rather than as shared borders: `wrap_links`
## go round the far side of the globe, `water_links` are the crossings the board
## itself treats as sea lanes. Both are exempt from the separability check.
wrap_links <- list(c("Alaska", "Kamchatka"))
water_links <- list(c("East_Africa", "Middle_East"))

territory_continent <- unlist(
  lapply(names(continent), function(cn) {
    out <- rep(cn, length(continent[[cn]]))
    names(out) <- continent[[cn]]
    out
  })
)

layout <- tibble::tibble(
  territory = coords[, 1L],
  x = as.numeric(coords[, 2L]),
  y = as.numeric(coords[, 3L]),
  continent = unname(territory_continent[coords[, 1L]])
)

## ---- integrity checks ------------------------------------------------------

territories <- names(adjacency)

stopifnot(
  length(territories) == 42L,
  !anyDuplicated(territories),
  setequal(territories, unlist(continent, use.names = FALSE)),
  setequal(territories, layout$territory),
  setequal(names(continent), names(continent_bonus)),
  all(vapply(adjacency, function(x) all(x %in% territories), logical(1L))),
  !any(is.na(layout$x)),
  !any(is.na(layout$y))
)

## adjacency must be symmetric and irreflexive
for (a in territories) {
  stopifnot(!a %in% adjacency[[a]])
  for (b in adjacency[[a]]) {
    if (!a %in% adjacency[[b]]) {
      stop("Asymmetric adjacency: ", a, " -> ", b, call. = FALSE)
    }
  }
}

## Whether two territories end up sharing a drawn border is decided by the
## layout, so the layout is part of the map's correctness and not only its
## looks. The exact check needs the tiling itself and therefore lives with the
## plots, in `tests/testthat/test-plot.R`: every adjacency except the links
## listed above must show up as a shared border, and no border may appear
## between territories that are not neighbours.
##
## What is worth checking here is the property the game depends on: every
## continent has to be connected under its own internal adjacencies, or holding
## one would not be a coherent goal.
for (cn in names(continent)) {
  members <- continent[[cn]]
  seen <- members[[1L]]
  repeat {
    grown <- unique(c(seen, intersect(unlist(adjacency[seen]), members)))
    if (length(grown) == length(seen)) break
    seen <- grown
  }
  if (!setequal(seen, members)) {
    stop(cn, " is not connected: ", paste(setdiff(members, seen), collapse = ", "),
         " cannot be reached from ", members[[1L]], call. = FALSE)
  }
}

## And that the layout keeps continents apart as blocks: the widest gap inside
## a continent should not dwarf the whole board.
pos <- lapply(seq_len(nrow(coords)), function(i) as.numeric(coords[i, 2:3]))
names(pos) <- coords[, 1L]
span <- max(
  diff(range(vapply(pos, `[`, numeric(1L), 1L))),
  diff(range(vapply(pos, `[`, numeric(1L), 2L)))
)
for (cn in names(continent)) {
  wide <- max(dist(do.call(rbind, pos[continent[[cn]]])))
  if (wide > 0.62 * span) {
    stop(cn, " is spread over ", round(wide), " units of a ", round(span),
         "-unit board; it will not read as one block.", call. = FALSE)
  }
}

## keep the layout row order aligned with `territories`
layout <- layout[match(territories, layout$territory), ]

risk_map <- list(
  territories = territories,
  adjacency = adjacency,
  continent = continent,
  continent_bonus = continent_bonus,
  layout = layout
)

dir.create("data", showWarnings = FALSE)
save(risk_map, file = "data/risk_map.rda", compress = "xz", version = 2L)
