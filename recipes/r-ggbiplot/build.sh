R -e 'httr::set_config(httr::config(ssl_verifypeer = 0L)); install.packages("devtools", repos="http://mirrors.ebi.ac.uk/CRAN/"); library(devtools); install_github("vqv/ggbiplot"); library(ggbiplot)'

