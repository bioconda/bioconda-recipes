#!/bin/bash

# Install gamsel from CRAN since it's not available as a conda package
Rscript -e "install.packages('gamsel', repos='https://stat.ethz.ch/CRAN')"