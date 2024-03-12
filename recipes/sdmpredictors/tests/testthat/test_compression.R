library(sdmpredictors)
library(tools)

context("Compress/Decompress")

print(getwd())

get_test_file <- function() {
  if (!dir.exists("../data")) {
    dir.create("../data")
  }
  path <- "../data/test_compress.grd"
  if(!file.exists(path)) {
    r <- raster::raster(nrows=180, ncols=360, xmn=-180, xmx=180, ymn=-90, ymx=90, 
           crs=lonlatproj, vals=runif(180*360))
    raster::writeRaster(r, path)
  }
  path
}

test_raster_file <- get_test_file()
test_tmp_dir <- "../tmp_compression"
setup <- function() {
  if (dir.exists(test_tmp_dir)) {
    unlink(test_tmp_dir, recursive=TRUE)
  }
  dir.create(test_tmp_dir)
}
setup()

test_that("compress_file creates a compressed file for valid methods", {
  compress_file_test <- function (method,extension,fileClass) {
    expect_true(file.exists(test_raster_file))
    output <- compress_file(test_raster_file, test_tmp_dir, method, remove = FALSE)
    expect_equal(tools::file_ext(output), extension)
    expect_true(file.exists(output))
    expect_gt(file.size(output), 0)
    expect_lt(file.size(output), file.size(test_raster_file))
    expect_true(R.utils::isCompressedFile(output,method="content",
                                          ext=extension,fileClass=fileClass))
  }
  compress_file_test("gzip","gz","gzfile")
  compress_file_test("bzip2","bz2","bzfile")
})
test_that("compress_file for an unknown method fails", {
  m <- "unsupported_method_xyz"
  expect_error(compress_file(test_raster_file, test_tmp_dir,m),regexp=m)
})

test_that("decompress_file decompresses a file for valid extensions", {
  decompress_file_test <- function (method, extension) {
    input <- paste0(test_tmp_dir,"/", basename(test_raster_file), ".", extension)
    if(!file.exists(input)){
      compress_file(test_raster_file, test_tmp_dir, method)
    }
    inputsize <- file.size(input)
    output <- decompress_file(input, test_tmp_dir)
    expect_true(file.exists(output))
    expect_false(file.exists(input)) # compressed file should be removed
    expect_gt(file.size(output), 0)
    expect_gt(file.size(output), inputsize)
    outputmd5 <- md5sum(output)[[1]]
    originalmd5 <- md5sum(test_raster_file)[[1]]
    expect_equal(outputmd5, originalmd5)
    ## cleanup decompressed otherwise we can't test different decompressions
    file.remove(output)
  }
  decompress_file_test("gzip", "gz")
  decompress_file_test("bzip2", "bz2")
})
test_that("decompress_file for an unknown extension fails", {
 ext <- "invalidextension"
 f <- function(){ decompress_file(paste0(test_raster_file, ".", ext), test_tmp_dir) }
 expect_error(f(),regexp=ext)
})


## TODO test if different remove and overwrite options work

unlink(test_tmp_dir, recursive=TRUE)