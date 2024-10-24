#!/bin/bash -e

set -x

export CARGO_HOME="${BUILD_PREFIX}/.cargo"

cp $RECIPE_DIR/build_htslib.sh d4-hts/build_htslib.sh

cd d4binding 
./install.sh
