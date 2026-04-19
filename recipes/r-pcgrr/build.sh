#!/bin/bash

# PCGRR R package installation script
# This script installs the R package component of PCGR.

cd pcgrr

# The R command to install the package
$R CMD INSTALL --build . ${R_ARGS}
