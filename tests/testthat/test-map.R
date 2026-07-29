test_that("the world map is the classic board", {
  m <- rk_world()
  expect_s3_class(m, "rk_map")
  expect_length(m$territories, 42L)
  expect_length(m$continent, 6L)
  expect_equal(sum(m$continent_bonus), 24L)
  expect_setequal(unlist(m$continent, use.names = FALSE), m$territories)
  expect_equal(nrow(m$layout), 42L)
  expect_setequal(m$layout$territory, m$territories)
  expect_false(anyNA(m$layout$x))
})

test_that("the world adjacency graph is symmetric and irreflexive", {
  m <- rk_world()
  for (a in m$territories) {
    expect_false(a %in% m$adjacency[[a]])
    for (b in m$adjacency[[a]]) {
      expect_true(a %in% m$adjacency[[b]])
    }
  }
})

test_that("rk_map builds a custom board and lays it out", {
  m <- rk_test_map()
  expect_s3_class(m, "rk_map")
  expect_equal(m$territories, c("A", "B", "C", "D"))
  expect_equal(unname(m$continent_bonus), c(2L, 3L))
  expect_equal(nrow(m$layout), 4L)
  expect_equal(m$layout$territory, m$territories)
  expect_equal(m$layout$continent, c("North", "North", "South", "South"))
})

test_that("rk_map honours a supplied layout", {
  layout <- tibble::tibble(
    territory = c("D", "C", "B", "A"), x = 1:4, y = 4:1
  )
  m <- rk_map(
    territories = c("A", "B", "C", "D"),
    adjacency = list(
      A = c("B", "C"), B = c("A", "D"), C = c("A", "D"), D = c("B", "C")
    ),
    continent = list(Land = c("A", "B", "C", "D")),
    continent_bonus = c(Land = 2),
    layout = layout
  )
  expect_equal(m$layout$territory, c("A", "B", "C", "D"))
  expect_equal(m$layout$x, c(4, 3, 2, 1))
})

test_that("rk_map rejects a broken board", {
  ok_adj <- list(A = c("B", "C"), B = c("A", "D"), C = c("A", "D"),
                 D = c("B", "C"))
  ok_cont <- list(Land = c("A", "B", "C", "D"))
  expect_error(
    rk_map(c("A", "A", "B"), ok_adj, ok_cont, c(Land = 2)),
    "must be unique"
  )
  expect_error(
    rk_map("A", list(A = character(0)), list(Land = "A"), c(Land = 2)),
    "at least two territories"
  )
  asym <- ok_adj
  asym$A <- c("B", "C", "D")
  expect_error(
    rk_map(c("A", "B", "C", "D"), asym, ok_cont, c(Land = 2)),
    "symmetric"
  )
  self <- ok_adj
  self$A <- c("A", "B", "C")
  expect_error(
    rk_map(c("A", "B", "C", "D"), self, ok_cont, c(Land = 2)),
    "cannot neighbour itself"
  )
  unknown <- ok_adj
  unknown$A <- c("B", "C", "Z")
  expect_error(
    rk_map(c("A", "B", "C", "D"), unknown, ok_cont, c(Land = 2)),
    "unknown territories"
  )
  expect_error(
    rk_map(c("A", "B", "C", "D"), ok_adj, list(Land = c("A", "B")),
           c(Land = 2)),
    "exactly one continent"
  )
  expect_error(
    rk_map(c("A", "B", "C", "D"), ok_adj, ok_cont, c(Sea = 2)),
    "one per continent"
  )
  expect_error(
    rk_map(c("A", "B", "C", "D"), ok_adj, ok_cont, c(Land = 2),
           layout = tibble::tibble(territory = "A", x = 1, y = 1)),
    "one row per territory"
  )
})

test_that("rk_neighbors works for maps and games", {
  expect_setequal(
    rk_neighbors(rk_world(), "Egypt"),
    c("North_Africa", "Southern_Europe", "Middle_East", "East_Africa")
  )
  game <- rk_test_game()
  expect_setequal(rk_neighbors(game, "A"), c("B", "C"))
  expect_type(rk_neighbors(game, "A"), "character")
})

test_that("rk_neighbors validates its arguments", {
  expect_error(rk_neighbors(rk_world(), "Atlantis"), "Unknown territor")
  expect_error(rk_neighbors(rk_world(), c("Egypt", "Congo")), "single string")
  expect_error(rk_neighbors(42, "Egypt"), "rk_map")
})

test_that("maps print and format", {
  m <- rk_world()
  expect_type(format(m), "character")
  expect_output(print(m), "rk_map")
  expect_snapshot(print(rk_test_map()))
})
