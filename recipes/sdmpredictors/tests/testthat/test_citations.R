library(sdmpredictors)

context("Citations")

test_that("layer_citations returns expected citations", {
  ref <- layer_citations("BO_salinity")
  expect_equal(length(ref), 2)
  expect_true(all(grepl("ORACLE", ref)))
  
  ref <- layer_citations("BO_A1B_2100_salinity")
  expect_equal(length(ref), 2)
  expect_true(all(grepl("Tyberghein", ref)))
  
  ref <- layer_citations("MS_biogeo02_aspect_NS_21kya")
  expect_equal(length(ref), 2)
  expect_true(all(grepl("MARSPEC", ref)))
  
  refs <- sapply(layer_citations(astext = FALSE), toBibtex)
  expect_gt(length(refs), 3)
  expect_true(all(sapply(refs, function(r) class(r) == "Bibtex")))
})

test_that("layer_citations returns layer specific citations", {
  testthat::skip_on_ci()
  testthat::skip_on_cran()
  
  lyr_cit <- sdmpredictors:::get_sysdata()$bibentries$lnk_bibentry$layers
  expect_null(lyr_cit)

  if(length(lyr_cit) > 0) {
    fail(message = "IMPLEMENT THIS TEST when there are layer specific bibentries added to bibentry")
  }
})

test_that("each dataset has at least one citation", {
  datasets <- list_datasets()
  for(i in 1:nrow(datasets)) {
    ref <- dataset_citations(datasets[i,])
    expect_gt(length(ref), 0)
  }
})

# Run only once, no need to test more than 1000 layers everytime
# test_that("each layer has at least one citation", {
#   testthat::skip_on_cran()
#   layers <- list_layers()
#   for(i in 1:nrow(layers)) {
#     ref <- layer_citations(layers[i,])
#     testthat::expect_gt(length(ref), 0)
#   }
# })

test_that("citations are returned", {
  lcitations <- layer_citations()
  dcitations <- dataset_citations()
  expect_gt(length(lcitations), 0)
  expect_equal(length(lcitations), length(dcitations))
  lcitations <- lapply(layer_citations(astext = FALSE), toBibtex)
  dcitations <- lapply(dataset_citations(astext = FALSE), toBibtex)
  expect_gt(length(lcitations), 0)
  expect_equal(length(lcitations), length(dcitations))
})
