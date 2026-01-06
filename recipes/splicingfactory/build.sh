#!/bin/bash
set -euo pipefail

# Install the R package into the conda environment library
${R} CMD INSTALL --library=${PREFIX}/lib/R/library .
