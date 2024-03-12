test_that("All layer urls are resolvable", {
  skip_on_cran()
  skip_on_ci()
  require(httr2)
  
  url <- c(
    list_layers("Bio-ORACLE")$layer_url,
    list_layers_future("Bio-ORACLE")$layer_url
  )
  
  for(i in 1:length(url)){
    
    req <- httr2::request(url[i]) %>% 
      httr2::req_method("HEAD") %>% 
      httr2::req_user_agent("salvadorf; test sdmpredictors") %>%
      httr2::req_error(is_error = function(resp) FALSE) 
    
    resp <- req %>% httr2::req_perform()
    
    status <- httr2::resp_status(resp)
    
    if(status != 200){
      message(paste0(url[i], " failed with code ", status, "; ", httr2::resp_status_desc(resp)))
    }
    
    Sys.sleep(0.1)
  }
  
})
