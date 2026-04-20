#!/bin/bash
set -e

# Install gamsel from CRAN since it's not available as a conda package
Rscript -e "install.packages('gamsel', repos='https://stat.ethz.ch/CRAN')"

# Install the TSENAT R package
$R CMD INSTALL --library=$PREFIX/lib/R/library $SRC_DIR