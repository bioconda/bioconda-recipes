library(sdmpredictors)
# These tests are discontinued as the stats are a feature that 
# is not used by many people. It will be soon deprecated
context("Statistics")

skip_version <- function(layers, dataset_code, version){
  layer_skip <- subset(layers$layer_code, layers$dataset_code == dataset_code & layers$version == version)
  layers <- subset(layers, !(layers$layer_code %in% layer_skip))
  return(layers)
}

test_that("layer_stats without args returns all layers", {
  # layers <- list_layers()
  # layers <- layers[layers$layer_code != "WC_TODO",]
  layers <- get_layers_info()$common
  stats <- layer_stats()
  expect_gte(length(layers$layer_code), nrow(stats))
  expect_true(all(stats$layer_code %in% layers$layer_code))
})

test_that("layer_stats with one or more existing layercodes works", {
  stats <- layer_stats(data.frame(layer_code="BO_calcite"))
  expect_equal(nrow(stats), 1)
  expect_equal(stats$layer_code, "BO_calcite")
  
  stats <- layer_stats(c("BO_calcite","MS_bathy_5m"))
  expect_equal(nrow(stats), 2)
  expect_true(all(stats$layer_code %in% c("BO_calcite", "MS_bathy_5m")))
})

test_that("layer_stats with non existing layercodes generates a warning", {
  skip_on_cran()
  skip_on_ci()
  
  expect_warning(layer_stats("blabla"), "'blabla'")
  expect_warning(layer_stats(c("BO_calcite", "blabla")), "'blabla'")
  expect_equal(suppressWarnings(nrow(layer_stats(c("BO_calcite", "blabla")))), 1)
  expect_warning(layer_stats(c("blibli", "blabla")), "'blibli', 'blabla'")
})

test_that("layers_correlation without args returns correlations for all layers", {
  ##layers_correlation(layercodes = c())
  skip("stats functionality not maintained")
  layers <- skip_version(list_layers(), "Bio-ORACLE", 2.1)
  layers <- skip_version(layers, "Bio-ORACLE", 2.2)
  corr <- layers_correlation()
  expect_equal(nrow(layers), nrow(corr))
  expect_equal(nrow(layers), ncol(corr))
  expect_true(all(layers$layer_code %in% colnames(corr)))
  expect_true(all(layers$layer_code %in% rownames(corr)))
})

test_that("layers_correlation with one or more existing layercodes works", {
  corr <- layers_correlation(c("BO_calcite","MS_bathy_5m"))
  expect_equal(nrow(corr), 2)
  expect_true(all(c("BO_calcite", "MS_bathy_5m") %in% colnames(corr)))
  
  corr <- layers_correlation(c("BO_calcite","MS_bathy_5m", "BO_sstmax"))
  expect_equal(nrow(corr), 3)
  expect_true(all(c("BO_calcite", "MS_bathy_5m", "BO_sstmax") %in% colnames(corr)))
})

test_that("layers_correlation with non existing layercodes generates a warning", {
  skip_on_cran()
  skip_on_ci()
  
  expect_warning(layers_correlation("abcd"), "'abcd'")
  expect_warning(layers_correlation(c("BO_calcite", "blabla")), "'blabla'")
  expect_equal(suppressWarnings(colnames(layers_correlation(c("BO_calcite", "blabla")))), "BO_calcite")
  expect_equal(suppressWarnings(nrow(layers_correlation(c("BO_calcite", "blabla")))), 1)
  expect_warning(layers_correlation(c("blibli", "blabla")), "'blibli', 'blabla'")
})

expect_group <- function(actual, expected) {
  expect_equal(length(actual), length(expected))
  for (i in 1:length(actual)) {
    expect_true(setequal(actual[[i]], expected[[i]]))
  }
}

test_that("correlation_groups return correct correlation groups", {
  layers_correlation <- data.frame(a=c(1), row.names=c("a"))
  groups <- correlation_groups(layers_correlation)
  expect_group(actual=groups, expected=list("a"))

  layers_correlation <- data.frame(a=c(1,0.8), b=c(0.8,1), row.names=c("a","b"))
  groups <- correlation_groups(layers_correlation)
  expect_group(groups, list(c("a", "b")))
  
  layers_correlation <- data.frame(a=c(1,0.4), b=c(0.4,1), row.names=c("a","b"))
  groups <- correlation_groups(layers_correlation)
  expect_group(groups, list("a", "b"))
  
  layers_correlation <- data.frame(a=c(1,0.4,0.6), b=c(0.4,1,0.3), c=c(0.6,0.3,1), row.names=c("a","b","c"))
  groups <- correlation_groups(layers_correlation)
  expect_group(groups, list("a", "b", "c"))
  groups <- correlation_groups(layers_correlation, max_correlation = 0.5)
  expect_group(groups, list(c("a","c"), "b"))
  groups <- correlation_groups(layers_correlation, max_correlation = 0.35)
  expect_group(groups, list(c("a","b","c")))
})

test_that("plot_correlation works", {
  skip("stats features not maintained")
  skip_on_cran()
  skip_on_ci()
  
  p <- plot_correlation(c("BO_calcite", "BO_sstmax", "MS_bathy_5m"))
  expect_false(any(is.null(p) | is.na(p)))
  
  p <- plot_correlation(c("BO_calcite", "BO_sstmax", "MS_bathy_5m"), list(BO_calcite = "calcite"))
  expect_false(any(is.null(p) | is.na(p)))
  
  p <- plot_correlation(c("BO_calcite", "BO_sstmax", "MS_bathy_5m"), list(BO_calcite = "calcite"), palette = c("blue", "red", "green", "black", "white"))
  expect_false(any(is.null(p) | is.na(p)))
})

test_that("calc_stats returns stats", {
  s <- suppressWarnings(calculate_statistics("mini_raster", raster::raster(matrix(1:100, nrow=10, ncol=10))))
  expect_true(ncol(s) >= 11)
  expect_equal(nrow(s), 1)
})
