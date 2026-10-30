test_that('invalid army and dice counts fail without coercion warnings', {
  for (bad in list(Inf,-Inf,NA_real_,1.5,.Machine$integer.max+1)) {
    expect_error(rk_duel_dist(bad,2),'whole number')
    expect_error(rk_battle(bad,2),'whole number')
  }
  expect_equal(sum(rk_duel_dist(3,2)$p),1)
})
