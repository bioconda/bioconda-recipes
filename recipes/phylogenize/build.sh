#!/bin/bash
set -e

export DISABLE_AUTOBREW=1
export R_LIBS_USER="${PREFIX}/lib/R/library"
export R_LIBS="${PREFIX}/lib/R/library"

Rscript -e "install.packages('ezknitr', repos='https://cloud.r-project.org')"

cd package/phylogenize

${R} CMD INSTALL --library="${PREFIX}/lib/R/library" . "${R_ARGS}"
