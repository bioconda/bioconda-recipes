library(sdmpredictors)
suppressWarnings({library(raster)})

test_dir <- file.path(tempdir(), "sdmpredictors")
options(sdmpredictors_datadir = test_dir)

check_skip <- function() {
  # skip("skip today")
  skip_on_cran()
  skip_on_ci()
}

context("Load layers")

setup <- function() {
  load_tmp_dir <- file.path(tempdir(),"tmp_load")
  if (dir.exists(load_tmp_dir)) {
    unlink(load_tmp_dir, recursive=TRUE)
  }
  dir.create(load_tmp_dir)
  normalizePath(load_tmp_dir, winslash = "/", mustWork = TRUE)
}
load_tmp_dir <- setup()

load_BO2_temp_test <- function(asdataframe=FALSE, rasterstack=TRUE, equalarea = F) {
  check_skip()
  if (asdataframe) { 
    layercodes <- data.frame(layer_code="BO2_tempmean_ss", stringsAsFactors = FALSE)
  } else {
    layercodes <- "BO2_tempmean_ss"
  }
  rs <- load_layers(layercodes, datadir = load_tmp_dir, equalarea = equalarea, rasterstack = rasterstack)
  if(!rasterstack) {
    rs <- rs[[1]]
  }
  expect_false(is.null(rs))
  expect_equal(nlayers(rs), 1)
  
  expect_equal(names(rs),c("BO2_tempmean_ss"))
  if(equalarea) {
    expect_equal(nrow(rs), 2108)
    print(rs@crs@projargs)
    print(sdmpredictors::equalareaproj@projargs)
    expect_equal(as.character(rs@crs@projargs), as.character(sdmpredictors::equalareaproj@projargs))
  } else {
    expect_equal(nrow(rs), 2160)
    expect_equal(as.character(rs@crs), as.character(sdmpredictors::lonlatproj))
  }
}
test_that("load_layer for one not previously downloaded layercode works", {
  load_BO2_temp_test()
})
test_that("load_layer for a previously downloaded layer works", {
  load_BO2_temp_test(asdataframe=TRUE, rasterstack=FALSE)
})
test_that("load_layer equal area layer works", {
  load_BO2_temp_test(equalarea = TRUE)
})
test_that("load_layer works with different datadir options", {
  normalize <- function(p) {
    suppressWarnings({
      normalizePath(paste0(p,"/"), winslash = "/", mustWork = TRUE)
    })
  }
  rpath <- function(rs) {
    path <- gsub("/vsizip/", "", dirname(raster::raster(rs,1)@file@name), fixed = TRUE)
    normalize(path)
  }
  skip_on_cran()
  op <- options()
  wd <- getwd()
  on.exit({
    options(op)
    setwd(wd)
  })
  
  load_tmp_dir <- normalize(load_tmp_dir)
  rs <- rpath(load_layers("BO2_tempmean_ss", datadir = load_tmp_dir))
  expect_equal(rs, load_tmp_dir)
  
  load_tmp_dir <- normalize(load_tmp_dir)
  rs <- rpath(load_layers("BO2_tempmean_ss", datadir = paste0(load_tmp_dir, "/")))
  expect_equal(rs, load_tmp_dir)
  
  tmp <- file.path(tempdir(), "sdmpredictors")
  options(sdmpredictors_datadir = tmp)
  rs <- rpath(load_layers("BO2_tempmean_ss"))
  expect_equal(rs, normalize(tmp))
  
  options(sdmpredictors_datadir = NULL)
  testthat::expect_warning(load_layers("BO2_tempmean_ss"))
})

test_that("load_layer for dataframe from list_layers works", {
  check_skip()
  layers <- list_layers()
  layers <- layers[layers$layer_code == "BO2_tempmean_ss",]
  rs <- load_layers(layers, datadir = load_tmp_dir, equalarea = F)
  expect_false(is.null(rs))
  expect_equal(nlayers(rs), 1)
  expect_equal(nrow(rs), 2160)
  expect_equal(ncol(rs), 4320)
  expect_equal(names(rs),c("BO2_tempmean_ss"))
})

load_multiple_test <- function() {
  check_skip()
  rs <- load_layers(c("BO2_tempmean_ss","BO2_dissoxmean_ss"), datadir = load_tmp_dir, equalarea = F)
  expect_false(is.null(rs))
  expect_equal(nlayers(rs), 2)
  expect_equal(nrow(rs), 2160)
  expect_equal(ncol(rs), 4320)
  expect_equal(names(rs),c("BO2_tempmean_ss","BO2_dissoxmean_ss"))
}
test_that("load_layer for multiple not previously downloaded layers works", {
  load_multiple_test()
})
test_that("load_layer for multiple previously downloaded layers works", {
  load_multiple_test()
})

load_multiple_mixed_tif <- function() {
  check_skip()
  rs <- load_layers(c("WC_bio8","ER_annualPET"), datadir = load_tmp_dir, equalarea = F)
  expect_false(is.null(rs))
  expect_equal(nlayers(rs), 2)
  expect_equal(nrow(rs), 1800)
  expect_equal(ncol(rs), 4320)
  expect_equal(names(rs),c("WC_bio8","ER_annualPET"))
}
test_that("load_layer for multiple tif mixed not previously downloaded layers works", {
  load_multiple_mixed_tif()
})
test_that("load_layer for multiple tif mixed previously downloaded layers works", {
  load_multiple_mixed_tif()
})

test_that("load_layer handles special cases", {
  check_skip()
  expect_error(load_layers("blabla"))
  expect_error(load_layers("BO2_tempmean_ss", equalarea = NA))
  expect_error(supressWarnings(load_layers(c("BO2_tempmean_ss", "BO2_dissoxmean_ss"), equalarea = c(T,F))))
  expect_error(load_layers(c("FW_dem_avg","MS_biogeo05_dist_shore_5m"), datadir = load_tmp_dir, equalarea = F))
  expect_warning(load_layers(c("BO2_tempmean_ss", "MS_bathy_21kya"), rasterstack = FALSE))
  expect_error(load_layers(c("BO2_tempmean_ss", "MS_biogeo05_dist_shore_5m"), datadir = load_tmp_dir, rasterstack = TRUE))
})

test_that("load_layer equal area TRUE/FALSE works", {
  check_skip()
  rs_default <- load_layers("BO2_tempmean_ss", datadir = load_tmp_dir)
  rs_equalarea <- load_layers("BO2_tempmean_ss", datadir = load_tmp_dir, equalarea = TRUE)
  rs_lonlat <- load_layers("BO2_tempmean_ss", datadir = load_tmp_dir, equalarea = FALSE)
  
  is_equalarea <- function(rs) {
    expect_equal(names(rs), c("BO2_tempmean_ss"))
    expect_identical(as.character(rs@crs), as.character(sdmpredictors::equalareaproj))
  }
  is_lonlat <- function(rs) {
    expect_equal(nrow(rs), 2160)
    expect_equal(ncol(rs), 4320)
    expect_equal(names(rs), c("BO2_tempmean_ss"))
    expect_identical(as.character(rs@crs), as.character(sdmpredictors::lonlatproj))
  }
  expect_identical(rs_default, rs_lonlat)
  
  is_equalarea(rs_equalarea)
  is_lonlat(rs_default)
  is_lonlat(rs_lonlat)
})

test_that("GDAL virtual file system works to read zipped raster files", {
  skip_if_offline()
  skip_on_cran()
  
  url <- "/vsizip//vsicurl/https://bio-oracle.org/data/2.0/Present.Surface.Iron.Max.tif.zip"
  rs <- raster::raster(url)
  
  expect_equal(class(rs)[1], "RasterLayer")
  expect_false(gdal_is_lower_than_3())
})


unlink(load_tmp_dir, recursive=TRUE)