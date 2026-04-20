#!/bin/bash
set -e

# Set macOS deployment target to match dependencies (built for 11.0+)
export MACOSX_DEPLOYMENT_TARGET=11.0

# Install gamsel from CRAN since it's not available as a conda package
Rscript -e "install.packages('gamsel', repos='https://stat.ethz.ch/CRAN')"

# Install the TSENAT R package
$R CMD INSTALL --library=$PREFIX/lib/R/library $SRC_DIR