library(sdmpredictors)
library(testthat)

test_that("list_datasets works", {
  l <- list_datasets()
  expect_gte(nrow(l), 4)
})

test_that("list_layers works", {
  l <- list_layers()
  expect_gt(nrow(l), 200)
})

test_that("list_layers_future works", {
  l <- list_layers_future()
  expect_gt(nrow(l), 200)
})

test_that("list_layers_paleo works", {
  l <- list_layers_paleo()
  expect_gt(nrow(l), 200)
})

test_that("layer_code is unique", {
  layer_code <- c(list_layers()$layer_code, 
                  list_layers_future()$layer_code, 
                  list_layers_paleo()$layer_code)
  n_duplications <- anyDuplicated(layer_code)
  expect_lte(n_duplications, 0)
  # Explore errors with:
  # list_layers()[layers$layer_code %in% layers$layer_code[n_duplications], ]
})