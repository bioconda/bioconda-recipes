#!/bin/bash
R -e "library(devtools)"
R -e "options(timeout = 600000000) ### set this to avoid timeout error"
R -e "devtools::install_github("dmcable/spacexr", build_vignettes = FALSE)"
R CMD INSTALL --build .