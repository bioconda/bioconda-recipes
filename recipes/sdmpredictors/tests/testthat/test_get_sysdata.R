library(sdmpredictors)

context("Get sysdata")

test_that("get_sysdata has no unnamed list entries", {
  sysdata <- sdmpredictors:::get_sysdata()
  expect_false(any(names(sysdata) == ""))
})

test_that("get_sysdata returns all expected entries", {
  expect_notnull <- function(x) {
    expect_false(is.null(x)) 
  }
  sysdata <- sdmpredictors:::get_sysdata()
  expect_notnull(sysdata$datasetlist)
  expect_notnull(sysdata$layerlist)
  expect_notnull(sysdata$layerlistfuture)
  expect_notnull(sysdata$layerlistpaleo)
  expect_notnull(sysdata$layerstats)
  expect_notnull(sysdata$layerscorrelation)
  expect_notnull(sysdata$urldata)
  expect_notnull(sysdata$urlsysdata)
  expect_notnull(sysdata$bibentries)
  expect_notnull(sysdata$creation)
  expect_gt(length(names(sysdata)), 9)
})

test_that("all urls exists", {
  # This test takes a long time. Better to only run interactively
  skip("Run only interactively")
  sysdata <- sdmpredictors:::get_sysdata()
  
  list_url <- c(sysdata$layerlist$layer_url, 
                sysdata$layerlistfuture$layer_url,
                sysdata$layerlistpaleo$layer_url)
  
  
  results <- data.frame(
    url = NA,
    error = NA,
    message = NA
  )
  n <- 0
  total <- length(list_url)
  
  # Get the HTTP HEAD of each url and paste into an empty dataframe
  check_url_status <- function(url){
    
    head_url <- httr::HEAD(url)
    error <- httr::http_error(head_url)
    messg <- httr::http_status(head_url)$message
    
    results <<- rbind(results, c(
      url, error, messg
    ))

    n <<- n+1

    message(paste0(n, " out of ", total))
    
    Sys.sleep(0.001)
  }
  
  lapply(list_url, check_url_status)
  
  failure <- any(as.logical(results$error[-1]))
  
  if(failure){
    message("The following urls failed: ")
    print(subset(results, as.character(results$error) == TRUE))
    # write.csv(subset(results, as.character(results$error) == TRUE), "error404.csv")
  }
  
  expect_false(failure)
})

















