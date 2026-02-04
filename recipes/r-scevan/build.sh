#!/bin/bash
R -e "library(devtools)"
R -e "devtools::install_github('miccec/yaGST')"
R CMD INSTALL --build .
