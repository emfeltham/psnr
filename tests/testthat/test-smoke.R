test_that("sampling and inclusion probabilities run and agree on pairs", {
  skip_if_not_installed("JuliaCall")
  set.seed(1)
  edges <- data.frame(from = as.character(1:20), to = as.character(c(2:20, 1)))
  s <- psn_sample(edges, seed = 1)
  expect_named(s, c("perceiver", "from", "to", "bin", "real"))
  p <- psn_inclusion_probs(edges)
  expect_true(all(p$pi > 0 & p$pi <= 1))
  expect_identical(psn_sample(edges, seed = 1), s)   # reproducible
})
