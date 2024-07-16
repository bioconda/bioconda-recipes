#!/bin/bash
export TAR='/bin/tar'
R -e "library(devtools)"
R -e "options(timeout = 600000000) ### set this to avoid timeout error"
R -e "devtools::install_github('dmcable/spacexr', ref = '0a0861e3d1e16014a20e9b743d0e19d3b42231f3', build_vignettes = FALSE)"
R CMD INSTALL --build .