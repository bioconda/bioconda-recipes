#!/bin/bash
set -e

# Set macOS deployment target to match dependencies (built for 11.0+)
export MACOSX_DEPLOYMENT_TARGET=11.0

# Install the TSENAT R package
$R CMD INSTALL --library=$PREFIX/lib/R/library $SRC_DIR