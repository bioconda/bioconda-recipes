#!/bin/bash

set -euo pipefail

export DISABLE_AUTOBREW=1

# liftOver is a Bioconductor workflow package not available via conda;
# install it from the bundled source before installing splice2neo.
${R} CMD INSTALL "${SRC_DIR}/liftover_src"

# Install splice2neo
${R} CMD INSTALL --build "${SRC_DIR}/splice2neo_src/"
