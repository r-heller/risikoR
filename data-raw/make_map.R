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
## geographically exact, chosen so that continents form visual clusters and
## adjacency segments stay readable.
coords <- rbind(
  # North America
  c("Alaska",               5, 88),
  c("Northwest_Territory", 14, 89),
  c("Greenland",           30, 93),
  c("Alberta",             13, 79),
  c("Ontario",             21, 79),
  c("Quebec",              29, 79),
  c("Western_US",          14, 69),
  c("Eastern_US",          23, 68),
  c("Central_America",     16, 59),
  # South America
  c("Venezuela",           22, 50),
  c("Peru",                22, 39),
  c("Brazil",              31, 42),
  c("Argentina",           25, 29),
  # Europe
  c("Iceland",             40, 87),
  c("Great_Britain",       39, 77),
  c("Scandinavia",         49, 89),
  c("Northern_Europe",     48, 77),
  c("Western_Europe",      41, 67),
  c("Southern_Europe",     50, 68),
  c("Ukraine",             58, 83),
  # Africa
  c("North_Africa",        45, 54),
  c("Egypt",               53, 58),
  c("East_Africa",         58, 46),
  c("Congo",               51, 40),
  c("South_Africa",        53, 30),
  c("Madagascar",          62, 32),
  # Asia
  c("Ural",                68, 87),
  c("Siberia",             75, 91),
  c("Yakutsk",             84, 93),
  c("Kamchatka",           93, 89),
  c("Irkutsk",             81, 84),
  c("Mongolia",            82, 76),
  c("Japan",               93, 74),
  c("Afghanistan",         68, 74),
  c("China",               79, 67),
  c("Middle_East",         61, 60),
  c("India",               72, 59),
  c("Siam",                81, 57),
  # Australia
  c("Indonesia",           82, 44),
  c("New_Guinea",          92, 45),
  c("Western_Australia",   83, 32),
  c("Eastern_Australia",   93, 33)
)

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
