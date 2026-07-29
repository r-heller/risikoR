test_that("rk_duel returns consistent losses", {
  withr::local_seed(1)
  d <- rk_duel(3, 2)
  expect_equal(d$att_loss + d$def_loss, 2L)
  expect_true(d$att_loss %in% 0:2)
  expect_length(d$att_roll, 3L)
  expect_length(d$def_roll, 2L)
  expect_false(is.unsorted(rev(d$att_roll)))
})

test_that("rk_duel_odds matches the reference 3v2 values", {
  o <- rk_duel_odds(3, 2)
  # Wikipedia reference: 0.9209 attacker, 1.0791 defender, sd 0.8112
  expect_equal(o$e_att_loss, 0.9209, tolerance = 1e-4)
  expect_equal(o$e_def_loss, 1.0791, tolerance = 1e-4)
  expect_equal(o$sd_loss, 0.8112, tolerance = 1e-4)
})

test_that("the exact 3v2 loss distribution is the known one", {
  d <- rk_duel_dist(3, 2)
  expect_equal(d$att_loss, 0:2)
  expect_equal(d$def_loss, 2:0)
  expect_equal(d$p, c(0.3717, 0.3358, 0.2926), tolerance = 1e-3)
  expect_equal(sum(d$p), 1)
  expect_s3_class(d, "tbl_df")
})

test_that("every dice pairing gives a coherent distribution", {
  for (n_att in 1:3) {
    for (n_def in 1:2) {
      d <- rk_duel_dist(n_att, n_def)
      o <- rk_duel_odds(n_att, n_def)
      pairs <- min(n_att, n_def)
      expect_equal(sum(d$p), 1)
      expect_equal(nrow(d), pairs + 1L)
      expect_equal(o$e_att_loss + o$e_def_loss, pairs)
      expect_equal(o$p_att_wins_all, d$p[d$att_loss == 0L])
      expect_equal(o$p_def_wins_all, d$p[d$att_loss == pairs])
      if (pairs == 1L) {
        expect_equal(o$p_split, 0)
        expect_equal(o$p_att_wins_all + o$p_def_wins_all, 1)
      } else {
        expect_equal(o$p_att_wins_all + o$p_def_wins_all + o$p_split, 1)
      }
    }
  }
})

test_that("ties go to the defender", {
  # With one die each the attacker wins only 15 of the 36 combinations.
  o <- rk_duel_odds(1, 1)
  expect_equal(o$p_att_wins_all, 15 / 36)
  expect_equal(o$p_def_wins_all, 21 / 36)
})

test_that("the three-defender-dice variant is supported", {
  o <- rk_duel_odds(3, 3, max_def = 3L)
  d <- rk_duel_dist(3, 3, max_def = 3L)
  expect_equal(nrow(d), 4L)
  expect_equal(sum(d$p), 1)
  expect_equal(o$e_att_loss + o$e_def_loss, 3)
  expect_gt(o$e_att_loss, rk_duel_odds(3, 2)$e_att_loss)
})

test_that("rk_duel validates its inputs", {
  expect_error(rk_duel(4, 2), "between 1 and 3")
  expect_error(rk_duel(3, 3), "between 1 and 2")
  expect_error(rk_duel(0, 1), "between 1 and 3")
  expect_error(rk_duel(1.5, 1), "whole number")
  expect_error(rk_duel("3", 1), "whole number")
  expect_error(rk_duel(c(1, 2), 1), "whole number")
  expect_error(rk_duel_dist(3, 4, max_def = 4L), "between 1 and 3")
})

test_that("input validation errors read well", {
  expect_snapshot(rk_duel(4, 2), error = TRUE)
  expect_snapshot(rk_duel_dist(1, 1.5), error = TRUE)
})
