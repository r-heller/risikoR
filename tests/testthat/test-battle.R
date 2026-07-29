test_that("rk_battle terminates with a decision", {
  withr::local_seed(1)
  b <- rk_battle(10, 8)
  expect_s3_class(b, "rk_battle")
  expect_true(b$conquered || b$att_remaining == 1L)
  expect_equal(b$att_armies, 10L)
  expect_equal(b$def_armies, 8L)
  expect_equal(nrow(b$log), b$rounds)
  expect_equal(b$att_remaining, b$att_armies - sum(b$log$att_loss))
  expect_equal(b$def_remaining, b$def_armies - sum(b$log$def_loss))
  expect_named(b$log, c("round", "att_loss", "def_loss"))
})

test_that("a battle against one defender ends in a single duel", {
  withr::local_seed(2)
  b <- rk_battle(2, 1)
  expect_equal(b$rounds, 1L)
  expect_true(b$att_remaining >= 1L)
})

test_that("rk_battle validates its inputs", {
  expect_error(rk_battle(1, 5), "between 2 and")
  expect_error(rk_battle(5, 0), "between 1 and")
  expect_error(rk_battle(5, 5, max_def = 4L), "between 1 and 3")
})

test_that("rk_battle_odds returns a well formed probability", {
  withr::local_seed(1)
  o <- rk_battle_odds(10, 5, n = 200)
  expect_s3_class(o, "tbl_df")
  expect_named(
    o,
    c("att_armies", "def_armies", "method", "n", "p_conquer",
      "e_att_survivors", "e_def_survivors")
  )
  expect_gte(o$p_conquer, 0)
  expect_lte(o$p_conquer, 1)
  expect_equal(o$n, 200L)
  expect_equal(o$method, "mc")
})

test_that("the exact method agrees with Monte Carlo", {
  exact <- rk_battle_odds(10, 8, method = "exact")
  expect_true(is.na(exact$n))
  expect_equal(exact$method, "exact")
  withr::local_seed(42)
  mc <- rk_battle_odds(10, 8, n = 4000)
  expect_equal(mc$p_conquer, exact$p_conquer, tolerance = 0.05)
  expect_equal(mc$e_att_survivors, exact$e_att_survivors, tolerance = 0.15)
  expect_equal(mc$e_def_survivors, exact$e_def_survivors, tolerance = 0.15)
})

test_that("the exact method is deterministic and sensible", {
  expect_identical(
    rk_battle_odds(8, 6, method = "exact"),
    rk_battle_odds(8, 6, method = "exact")
  )
  expect_equal(rk_battle_odds(2, 1, method = "exact")$p_conquer, 15 / 36)
  expect_gt(
    rk_battle_odds(20, 5, method = "exact")$p_conquer,
    rk_battle_odds(20, 15, method = "exact")$p_conquer
  )
  # A conquest leaves no defenders, a repulse leaves a single attacker.
  odds <- rk_battle_odds(6, 4, method = "exact")
  expect_gt(odds$e_att_survivors, 1)
  expect_gte(odds$e_def_survivors, 0)
})

test_that("rk_odds_table covers the grid in order", {
  tbl <- rk_odds_table(att_range = 2:4, def_range = 1:3)
  expect_s3_class(tbl, "tbl_df")
  expect_equal(nrow(tbl), 9L)
  expect_equal(tbl$att_armies, rep(2:4, each = 3))
  expect_equal(tbl$def_armies, rep(1:3, times = 3))
  expect_true(all(tbl$p_conquer >= 0 & tbl$p_conquer <= 1))
  expect_named(
    tbl,
    c("att_armies", "def_armies", "method", "p_conquer",
      "e_att_survivors", "e_def_survivors")
  )
})

test_that("rk_odds_table validates its ranges", {
  expect_error(rk_odds_table(att_range = numeric(0)), "non-empty")
  expect_error(rk_odds_table(def_range = NA_real_), "non-empty")
  expect_error(rk_odds_table(att_range = 1), "between 2 and")
})

test_that("battles print and format", {
  withr::local_seed(1)
  b <- rk_battle(10, 8)
  expect_type(format(b), "character")
  expect_length(format(b), 2L)
  expect_output(print(b), "rk_battle")
  expect_snapshot(print(b))
})
