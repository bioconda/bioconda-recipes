context("Final tests")

test_that("tmp_load does not exist", {
  expect_false(any(grepl("tmp_load", list.files(".", recursive = TRUE))))
})

test_that("~/R/sdmpredictors was not created", {
  if(dir.exists("~/R/sdmpredictors")) {
    skip_on_cran()
    skip_on_ci()
    creation_time <- file.info("~/R/sdmpredictors")[1,"ctime"]
    modified_time <- file.info("~/R/sdmpredictors")[1,"mtime"]
    expect_gt(as.double(difftime(Sys.time(), creation_time, units = "mins")), 20)
    expect_gt(as.double(difftime(Sys.time(), modified_time, units = "mins")), 10)
  } else {
    expect_false(dir.exists("~/R/sdmpredictors"))
  }
})
